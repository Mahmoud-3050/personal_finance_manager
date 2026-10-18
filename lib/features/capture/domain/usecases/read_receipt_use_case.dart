import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../entities/capture_draft.dart';
import '../entities/receipt_capture_failure.dart';
import '../entities/receipt_capture_outcome.dart';
import '../entities/receipt_photo.dart';
import '../entities/receipt_read_gate.dart';
import '../entities/receipt_reading.dart';
import '../repositories/receipt_capture_repository.dart';

enum ReceiptReadStep { prepare, accept }

class ReadReceiptParams extends Params {
  const ReadReceiptParams({
    required this.photo,
    required this.step,
    this.cancellation,
  });

  final ReceiptPhoto photo;
  final ReceiptReadStep step;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'path': photo.path,
    'step': step.name,
  };

  @override
  List<Object?> get props => <Object?>[photo, step, cancellation];
}

class ReadReceiptUseCase
    extends UseCase<ReceiptCaptureOutcome, ReadReceiptParams> {
  ReadReceiptUseCase({required ReceiptCaptureRepository repository})
    : _repository = repository;

  final ReceiptCaptureRepository _repository;

  @override
  Future<Either<Failure, ReceiptCaptureOutcome>> call(
    ReadReceiptParams params,
  ) {
    return switch (params.step) {
      ReceiptReadStep.prepare => _prepare(params.photo),
      ReceiptReadStep.accept => _accept(params.photo),
    };
  }

  Future<Either<Failure, ReceiptCaptureOutcome>> _prepare(
    ReceiptPhoto photo,
  ) async {
    final Either<Failure, ReceiptReadGate> gate = await _repository.prepare(
      photo,
    );
    final Failure? failure = gate.leftOrNull;
    if (failure != null) {
      return Left<Failure, ReceiptCaptureOutcome>(failure);
    }
    final ReceiptReadGate? prepared = gate.rightOrNull;
    if (prepared == null) {
      return const Left<Failure, ReceiptCaptureOutcome>(
        ValidationFailure(message: ReceiptCaptureFailure.readFailed),
      );
    }
    return switch (prepared) {
      ReceiptReadOnDevice(:final reading) =>
        Right<Failure, ReceiptCaptureOutcome>(
          ReceiptProposalReady(draft: draftFromReading(reading), photo: photo),
        ),
      ReceiptReadNeedsConsent() => Right<Failure, ReceiptCaptureOutcome>(
        ReceiptConsentRequired(photo: photo),
      ),
      ReceiptReadOffline() => _blank(photo),
    };
  }

  Future<Either<Failure, ReceiptCaptureOutcome>> _accept(
    ReceiptPhoto photo,
  ) async {
    final Either<Failure, ReceiptReading> reading = await _repository.read(
      photo,
    );
    return reading.map(
      (ReceiptReading value) =>
          ReceiptProposalReady(draft: draftFromReading(value), photo: photo),
    );
  }

  Future<Either<Failure, ReceiptCaptureOutcome>> _blank(
    ReceiptPhoto photo,
  ) async {
    final Either<Failure, void> deleted = await _repository.delete(photo);
    final Failure? failure = deleted.leftOrNull;
    if (failure != null) {
      return Left<Failure, ReceiptCaptureOutcome>(failure);
    }
    return Right<Failure, ReceiptCaptureOutcome>(
      ReceiptBlankReady(draft: CaptureDraft.handStarted()),
    );
  }
}

CaptureDraft draftFromReading(ReceiptReading reading) {
  final Set<CaptureField> uncertain = <CaptureField>{};
  final int? returnedAmount = reading.amountMinor;
  final bool amountMissing = returnedAmount == null || returnedAmount <= 0;
  if (amountMissing || reading.unsure.contains(CaptureField.amount)) {
    uncertain.add(CaptureField.amount);
  }

  final CalendarDate? returnedDate = reading.date;
  if (returnedDate == null || reading.unsure.contains(CaptureField.date)) {
    uncertain.add(CaptureField.date);
  }

  final String trimmedShop = reading.shopName?.trim() ?? '';
  final String? shopName = trimmedShop.isEmpty ? null : trimmedShop;
  if (shopName == null || reading.unsure.contains(CaptureField.shopName)) {
    uncertain.add(CaptureField.shopName);
  }

  return CaptureDraft(
    kind: CaptureKind.expense,
    date: returnedDate ?? CalendarDate.today(),
    amountMinor: amountMissing ? null : returnedAmount,
    shopName: shopName,
    uncertainFields: uncertain,
  );
}
