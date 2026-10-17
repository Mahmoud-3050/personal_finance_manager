import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/capture/data/datasources/capture_draft_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/repositories/capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/discard_capture_draft_use_case.dart';
import 'package:finzomanager/features/capture/presentation/controller/discard_capture_draft/discard_capture_draft_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  blocTest<DiscardCaptureDraftCubit, DiscardCaptureDraftState>(
    'discard emits loading then success',
    build: () => DiscardCaptureDraftCubit(
      DiscardCaptureDraftUseCase(
        repository: CaptureRepositoryImpl(
          source: MemoryCaptureDraftDataSource(),
        ),
      ),
    ),
    act: (DiscardCaptureDraftCubit cubit) => cubit.fDiscardCaptureDraft(),
    expect: () => <Object>[
      isA<ApiCallLoading<bool>>(),
      isA<ApiCallSuccess<bool>>(),
    ],
  );

  blocTest<DiscardCaptureDraftCubit, DiscardCaptureDraftState>(
    'discard emits loading then error',
    build: () => DiscardCaptureDraftCubit(
      DiscardCaptureDraftUseCase(repository: _FailingCaptureRepository()),
    ),
    act: (DiscardCaptureDraftCubit cubit) => cubit.fDiscardCaptureDraft(),
    expect: () => <Object>[
      isA<ApiCallLoading<bool>>(),
      isA<ApiCallError<bool>>(),
    ],
  );
}

class _FailingCaptureRepository implements CaptureRepository {
  @override
  Future<Either<Failure, void>> clear() async =>
      const Left(CacheFailure(message: 'gone'));

  @override
  Future<Either<Failure, CaptureDraft>> hold(CaptureDraft draft) async =>
      Right(draft);

  @override
  Future<Either<Failure, bool>> isFinished() async => const Right(false);

  @override
  Future<Either<Failure, void>> markFinished() async => const Right(null);

  @override
  Future<Either<Failure, CaptureDraft?>> read() async => const Right(null);
}
