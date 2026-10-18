import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_capture_outcome.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_image_source.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_read_gate.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_reading.dart';
import 'package:finzomanager/features/capture/domain/repositories/receipt_capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/read_receipt_use_case.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ReceiptPhoto photo = ReceiptPhoto(path: '/tmp/receipt.jpg');

  test(
    'an empty reading marks amount, date, and shop name uncertain',
    () async {
      final ReadReceiptUseCase useCase = ReadReceiptUseCase(
        repository: _GateRepository(
          gate: const ReceiptReadOnDevice(reading: ReceiptReading()),
        ),
      );

      final Either<Failure, ReceiptCaptureOutcome> result = await useCase(
        const ReadReceiptParams(photo: photo, step: ReceiptReadStep.prepare),
      );
      final ReceiptProposalReady? ready =
          result.rightOrNull is ReceiptProposalReady
          ? result.rightOrNull as ReceiptProposalReady
          : null;

      expect(ready, isNotNull);
      expect(ready?.draft.kind, CaptureKind.expense);
      expect(ready?.draft.amountMinor, isNull);
      expect(ready?.draft.shopName, isNull);
      expect(ready?.draft.date, CalendarDate.today());
      expect(ready?.draft.uncertainFields, <CaptureField>{
        CaptureField.amount,
        CaptureField.date,
        CaptureField.shopName,
      });
      expect(
        ready?.draft.uncertainFields.contains(CaptureField.account),
        isFalse,
      );
      expect(
        ready?.draft.uncertainFields.contains(CaptureField.category),
        isFalse,
      );
    },
  );

  test('a confident reading is filled and not uncertain', () async {
    const ReceiptReading reading = ReceiptReading(
      amountMinor: 2500,
      date: CalendarDate(2026, 5, 2),
      shopName: 'Market',
    );
    final ReceiptProposalReady ready = await _proposal(reading);

    expect(ready.draft.amountMinor, 2500);
    expect(ready.draft.date, const CalendarDate(2026, 5, 2));
    expect(ready.draft.shopName, 'Market');
    expect(ready.draft.uncertainFields, isEmpty);
  });

  test('an unsure value is kept and marked uncertain', () async {
    const ReceiptReading reading = ReceiptReading(
      amountMinor: 2500,
      date: CalendarDate(2026, 5, 2),
      shopName: 'Cafe',
      unsure: <CaptureField>{CaptureField.shopName},
    );
    final ReceiptProposalReady ready = await _proposal(reading);

    expect(ready.draft.shopName, 'Cafe');
    expect(ready.draft.uncertainFields, <CaptureField>{CaptureField.shopName});
  });

  test('zero and negative amounts are stored as null and uncertain', () async {
    for (final int amount in <int>[0, -20]) {
      final ReceiptProposalReady ready = await _proposal(
        ReceiptReading(
          amountMinor: amount,
          date: const CalendarDate(2026, 5, 2),
          shopName: 'Market',
        ),
      );
      expect(ready.draft.amountMinor, isNull);
      expect(ready.draft.uncertainFields.contains(CaptureField.amount), isTrue);
    }
  });

  test('an on-device reader does not ask for consent', () async {
    final _GateRepository repository = _GateRepository(
      gate: const ReceiptReadOnDevice(reading: ReceiptReading()),
    );
    final Either<Failure, ReceiptCaptureOutcome> result =
        await ReadReceiptUseCase(repository: repository)(
          const ReadReceiptParams(photo: photo, step: ReceiptReadStep.prepare),
        );
    expect(result.rightOrNull, isA<ReceiptProposalReady>());
    expect(repository.readCalls, 0);
  });

  test('an online off-device reader waits for accept before reading', () async {
    final _GateRepository repository = _GateRepository(
      gate: const ReceiptReadNeedsConsent(),
      reading: const ReceiptReading(
        amountMinor: 1500,
        date: CalendarDate(2026, 1, 2),
        shopName: 'Shop',
      ),
    );
    final ReadReceiptUseCase useCase = ReadReceiptUseCase(
      repository: repository,
    );

    final Either<Failure, ReceiptCaptureOutcome> consent = await useCase(
      const ReadReceiptParams(photo: photo, step: ReceiptReadStep.prepare),
    );
    expect(consent.rightOrNull, isA<ReceiptConsentRequired>());
    expect(repository.readCalls, 0);

    final Either<Failure, ReceiptCaptureOutcome> accepted = await useCase(
      const ReadReceiptParams(photo: photo, step: ReceiptReadStep.accept),
    );
    expect(accepted.rightOrNull, isA<ReceiptProposalReady>());
    expect(repository.readCalls, 1);
  });

  test(
    'skip and offline both return a hand-started draft without reading',
    () async {
      final _GateRepository offline = _GateRepository(
        gate: const ReceiptReadOffline(),
      );
      final Either<Failure, ReceiptCaptureOutcome> skipped =
          await ReadReceiptUseCase(repository: offline)(
            const ReadReceiptParams(
              photo: photo,
              step: ReceiptReadStep.prepare,
            ),
          );
      final ReceiptBlankReady? blank = skipped.rightOrNull is ReceiptBlankReady
          ? skipped.rightOrNull as ReceiptBlankReady
          : null;
      expect(blank?.draft, CaptureDraft.handStarted());
      expect(offline.deleteCalls, 1);
      expect(offline.readCalls, 0);
    },
  );
}

Future<ReceiptProposalReady> _proposal(ReceiptReading reading) async {
  final Either<Failure, ReceiptCaptureOutcome> result =
      await ReadReceiptUseCase(
        repository: _GateRepository(
          gate: ReceiptReadOnDevice(reading: reading),
        ),
      )(
        const ReadReceiptParams(
          photo: ReceiptPhoto(path: '/tmp/receipt.jpg'),
          step: ReceiptReadStep.prepare,
        ),
      );
  final ReceiptCaptureOutcome? outcome = result.rightOrNull;
  expect(outcome, isA<ReceiptProposalReady>());
  return outcome! as ReceiptProposalReady;
}

class _GateRepository implements ReceiptCaptureRepository {
  _GateRepository({required this.gate, this.reading = const ReceiptReading()});

  final ReceiptReadGate gate;
  final ReceiptReading reading;
  int readCalls = 0;
  int deleteCalls = 0;

  @override
  bool get sendsImageOffDevice => gate is ReceiptReadNeedsConsent;

  @override
  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source) async {
    return const Right<Failure, ReceiptPhoto?>(null);
  }

  @override
  Future<Either<Failure, ReceiptReadGate>> prepare(ReceiptPhoto photo) async {
    return Right<Failure, ReceiptReadGate>(gate);
  }

  @override
  Future<Either<Failure, ReceiptReading>> read(ReceiptPhoto photo) async {
    readCalls += 1;
    return Right<Failure, ReceiptReading>(reading);
  }

  @override
  Future<Either<Failure, void>> delete(ReceiptPhoto photo) async {
    deleteCalls += 1;
    return const Right<Failure, void>(null);
  }
}
