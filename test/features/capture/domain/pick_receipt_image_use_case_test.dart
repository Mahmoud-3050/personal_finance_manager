import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_capture_failure.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_image_source.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_read_gate.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_reading.dart';
import 'package:finzomanager/features/capture/domain/repositories/receipt_capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/pick_receipt_image_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a cancelled pick is not a failure', () async {
    final PickReceiptImageUseCase useCase = PickReceiptImageUseCase(
      repository: _PickRepository(photo: null),
    );
    final Either<Failure, ReceiptPhoto?> result = await useCase(
      const PickReceiptImageParams(source: ReceiptImageSource.camera),
    );
    expect(result.isRight, isTrue);
    expect(result.rightOrNull, isNull);
  });

  test('an access failure is Left with the access-denied message', () async {
    final PickReceiptImageUseCase useCase = PickReceiptImageUseCase(
      repository: _PickRepository(
        failure: const CacheFailure(
          message: ReceiptCaptureFailure.accessDenied,
        ),
      ),
    );
    final Either<Failure, ReceiptPhoto?> result = await useCase(
      const PickReceiptImageParams(source: ReceiptImageSource.gallery),
    );
    expect(result.leftOrNull?.message, ReceiptCaptureFailure.accessDenied);
  });
}

class _PickRepository implements ReceiptCaptureRepository {
  _PickRepository({this.photo, this.failure});

  final ReceiptPhoto? photo;
  final Failure? failure;

  @override
  bool get sendsImageOffDevice => false;

  @override
  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source) async {
    final Failure? error = failure;
    if (error != null) {
      return Left<Failure, ReceiptPhoto?>(error);
    }
    return Right<Failure, ReceiptPhoto?>(photo);
  }

  @override
  Future<Either<Failure, ReceiptReadGate>> prepare(ReceiptPhoto photo) async {
    return const Right<Failure, ReceiptReadGate>(
      ReceiptReadOnDevice(reading: ReceiptReading()),
    );
  }

  @override
  Future<Either<Failure, ReceiptReading>> read(ReceiptPhoto photo) async {
    return const Right<Failure, ReceiptReading>(ReceiptReading());
  }

  @override
  Future<Either<Failure, void>> delete(ReceiptPhoto photo) async {
    return const Right<Failure, void>(null);
  }
}
