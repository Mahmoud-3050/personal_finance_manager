import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_capture_failure.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_capture_outcome.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_image_source.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_read_gate.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_reading.dart';
import 'package:finzomanager/features/capture/domain/repositories/receipt_capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/delete_receipt_photo_use_case.dart';
import 'package:finzomanager/features/capture/domain/usecases/pick_receipt_image_use_case.dart';
import 'package:finzomanager/features/capture/domain/usecases/read_receipt_use_case.dart';
import 'package:finzomanager/features/capture/presentation/controller/start_receipt_capture/start_receipt_capture_cubit.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ReceiptPhoto photo = ReceiptPhoto(path: '/tmp/receipt.jpg');

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'an empty on-device reading emits a proposal with three uncertain fields',
    build: () => _cubit(
      _FakeReceiptRepository(
        photo: photo,
        gate: const ReceiptReadOnDevice(reading: ReceiptReading()),
      ),
    ),
    act: (StartReceiptCaptureCubit cubit) =>
        cubit.fStartReceiptCapture(ReceiptImageSource.camera),
    expect: () => <Object>[
      isA<ApiCallLoading<ReceiptCaptureOutcome>>(),
      isA<ApiCallSuccess<ReceiptCaptureOutcome>>(),
    ],
    verify: (StartReceiptCaptureCubit cubit) {
      final ApiCallSuccess<ReceiptCaptureOutcome> state =
          cubit.state as ApiCallSuccess<ReceiptCaptureOutcome>;
      final ReceiptProposalReady ready = state.data as ReceiptProposalReady;
      expect(ready.draft.uncertainFields, <CaptureField>{
        CaptureField.amount,
        CaptureField.date,
        CaptureField.shopName,
      });
      expect(ready.draft.amountMinor, isNull);
      expect(ready.draft.date, CalendarDate.today());
    },
  );

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'a cancelled pick emits cancelled and no draft',
    build: () => _cubit(_FakeReceiptRepository(photo: null)),
    act: (StartReceiptCaptureCubit cubit) =>
        cubit.fStartReceiptCapture(ReceiptImageSource.gallery),
    expect: () => <Object>[
      isA<ApiCallLoading<ReceiptCaptureOutcome>>(),
      isA<ApiCallSuccess<ReceiptCaptureOutcome>>().having(
        (ApiCallSuccess<ReceiptCaptureOutcome> state) => state.data,
        'outcome',
        isA<ReceiptCaptureCancelled>(),
      ),
    ],
  );

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'accept reads after consent and skip returns a blank draft',
    build: () {
      final _FakeReceiptRepository repository = _FakeReceiptRepository(
        photo: photo,
        gate: const ReceiptReadNeedsConsent(),
        reading: const ReceiptReading(
          amountMinor: 1800,
          date: CalendarDate(2026, 4, 1),
          shopName: 'Bakery',
        ),
      );
      return _cubit(repository);
    },
    act: (StartReceiptCaptureCubit cubit) async {
      await cubit.fStartReceiptCapture(ReceiptImageSource.camera);
      await cubit.fAcceptOffDeviceReading();
    },
    verify: (StartReceiptCaptureCubit cubit) {
      final ApiCallSuccess<ReceiptCaptureOutcome> state =
          cubit.state as ApiCallSuccess<ReceiptCaptureOutcome>;
      expect(state.data, isA<ReceiptProposalReady>());
    },
  );

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'skip deletes the photo and emits a hand-started draft',
    build: () => _cubit(
      _FakeReceiptRepository(
        photo: photo,
        gate: const ReceiptReadNeedsConsent(),
      ),
    ),
    act: (StartReceiptCaptureCubit cubit) async {
      await cubit.fStartReceiptCapture(ReceiptImageSource.camera);
      await cubit.fSkipToBlankDraft();
    },
    verify: (StartReceiptCaptureCubit cubit) {
      final ApiCallSuccess<ReceiptCaptureOutcome> state =
          cubit.state as ApiCallSuccess<ReceiptCaptureOutcome>;
      final ReceiptBlankReady blank = state.data as ReceiptBlankReady;
      expect(blank.draft.uncertainFields, isEmpty);
      expect(blank.draft.shopName, isNull);
    },
  );

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'accept emits an error when reading fails',
    build: () => _cubit(
      _FakeReceiptRepository(
        photo: photo,
        gate: const ReceiptReadNeedsConsent(),
        readFailure: const CacheFailure(
          message: ReceiptCaptureFailure.readFailed,
        ),
      ),
    ),
    act: (StartReceiptCaptureCubit cubit) async {
      await cubit.fStartReceiptCapture(ReceiptImageSource.camera);
      await cubit.fAcceptOffDeviceReading();
    },
    verify: (StartReceiptCaptureCubit cubit) {
      expect(cubit.state, isA<ApiCallError<ReceiptCaptureOutcome>>());
    },
  );

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'access denied emits an error and does not propose a draft',
    build: () => _cubit(
      _FakeReceiptRepository(
        pickFailure: const CacheFailure(
          message: ReceiptCaptureFailure.accessDenied,
        ),
      ),
    ),
    act: (StartReceiptCaptureCubit cubit) =>
        cubit.fStartReceiptCapture(ReceiptImageSource.camera),
    expect: () => <Object>[
      isA<ApiCallLoading<ReceiptCaptureOutcome>>(),
      isA<ApiCallError<ReceiptCaptureOutcome>>().having(
        (ApiCallError<ReceiptCaptureOutcome> state) => state.message,
        'message',
        ReceiptCaptureFailure.accessDenied,
      ),
    ],
  );

  blocTest<StartReceiptCaptureCubit, StartReceiptCaptureState>(
    'a failed reading emits an error and deletes the photo',
    build: () {
      final _FakeReceiptRepository repository = _FakeReceiptRepository(
        photo: photo,
        prepareFailure: const CacheFailure(
          message: ReceiptCaptureFailure.readFailed,
        ),
      );
      return _TrackedCubit(repository);
    },
    act: (StartReceiptCaptureCubit cubit) =>
        cubit.fStartReceiptCapture(ReceiptImageSource.camera),
    verify: (StartReceiptCaptureCubit cubit) {
      expect(cubit.state, isA<ApiCallError<ReceiptCaptureOutcome>>());
      expect(
        (cubit.state as ApiCallError<ReceiptCaptureOutcome>).message,
        ReceiptCaptureFailure.readFailed,
      );
      expect((cubit as _TrackedCubit).repository.deleteCalls, 1);
    },
  );
}

StartReceiptCaptureCubit _cubit(_FakeReceiptRepository repository) {
  return StartReceiptCaptureCubit(
    pickReceiptImage: PickReceiptImageUseCase(repository: repository),
    readReceipt: ReadReceiptUseCase(repository: repository),
    deleteReceiptPhoto: DeleteReceiptPhotoUseCase(repository: repository),
  );
}

class _TrackedCubit extends StartReceiptCaptureCubit {
  _TrackedCubit(_FakeReceiptRepository repository)
    : repository = repository,
      super(
        pickReceiptImage: PickReceiptImageUseCase(repository: repository),
        readReceipt: ReadReceiptUseCase(repository: repository),
        deleteReceiptPhoto: DeleteReceiptPhotoUseCase(repository: repository),
      );

  final _FakeReceiptRepository repository;
}

class _FakeReceiptRepository implements ReceiptCaptureRepository {
  _FakeReceiptRepository({
    this.photo,
    this.gate,
    this.reading = const ReceiptReading(),
    this.pickFailure,
    this.prepareFailure,
    this.readFailure,
    this.deleteFailure,
  });

  final ReceiptPhoto? photo;
  final ReceiptReadGate? gate;
  final ReceiptReading reading;
  final Failure? pickFailure;
  final Failure? prepareFailure;
  final Failure? readFailure;
  final Failure? deleteFailure;
  int deleteCalls = 0;

  @override
  bool get sendsImageOffDevice => gate is ReceiptReadNeedsConsent;

  @override
  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source) async {
    final Failure? failure = pickFailure;
    if (failure != null) {
      return Left<Failure, ReceiptPhoto?>(failure);
    }
    return Right<Failure, ReceiptPhoto?>(photo);
  }

  @override
  Future<Either<Failure, ReceiptReadGate>> prepare(ReceiptPhoto photo) async {
    final Failure? failure = prepareFailure;
    if (failure != null) {
      return Left<Failure, ReceiptReadGate>(failure);
    }
    return Right<Failure, ReceiptReadGate>(
      gate ?? const ReceiptReadOnDevice(reading: ReceiptReading()),
    );
  }

  @override
  Future<Either<Failure, ReceiptReading>> read(ReceiptPhoto photo) async {
    final Failure? failure = readFailure;
    if (failure != null) {
      return Left<Failure, ReceiptReading>(failure);
    }
    return Right<Failure, ReceiptReading>(reading);
  }

  @override
  Future<Either<Failure, void>> delete(ReceiptPhoto photo) async {
    deleteCalls += 1;
    final Failure? failure = deleteFailure;
    if (failure != null) {
      return Left<Failure, void>(failure);
    }
    return const Right<Failure, void>(null);
  }
}
