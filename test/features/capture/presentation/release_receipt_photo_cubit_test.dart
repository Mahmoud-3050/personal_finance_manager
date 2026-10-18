import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_image_source.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_read_gate.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_reading.dart';
import 'package:finzomanager/features/capture/domain/repositories/receipt_capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/delete_receipt_photo_use_case.dart';
import 'package:finzomanager/features/capture/presentation/controller/release_receipt_photo/release_receipt_photo_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ReceiptPhoto photo = ReceiptPhoto(path: '/tmp/receipt.jpg');

  blocTest<ReleaseReceiptPhotoCubit, ReleaseReceiptPhotoState>(
    'release emits loading then success',
    build: () => ReleaseReceiptPhotoCubit(
      DeleteReceiptPhotoUseCase(repository: _ReleaseRepository()),
    ),
    act: (ReleaseReceiptPhotoCubit cubit) => cubit.fReleaseReceiptPhoto(photo),
    expect: () => <Object>[
      isA<ApiCallLoading<bool>>(),
      isA<ApiCallSuccess<bool>>(),
    ],
  );

  blocTest<ReleaseReceiptPhotoCubit, ReleaseReceiptPhotoState>(
    'release emits loading then error',
    build: () => ReleaseReceiptPhotoCubit(
      DeleteReceiptPhotoUseCase(
        repository: _ReleaseRepository(
          failure: const CacheFailure(message: 'missing'),
        ),
      ),
    ),
    act: (ReleaseReceiptPhotoCubit cubit) => cubit.fReleaseReceiptPhoto(photo),
    expect: () => <Object>[
      isA<ApiCallLoading<bool>>(),
      isA<ApiCallError<bool>>(),
    ],
  );
}

class _ReleaseRepository implements ReceiptCaptureRepository {
  _ReleaseRepository({this.failure});

  final Failure? failure;

  @override
  bool get sendsImageOffDevice => false;

  @override
  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source) async {
    return const Right<Failure, ReceiptPhoto?>(null);
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
    final Failure? error = failure;
    if (error != null) {
      return Left<Failure, void>(error);
    }
    return const Right<Failure, void>(null);
  }
}
