import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/capture_draft.dart';
import '../../domain/repositories/capture_repository.dart';
import '../datasources/capture_draft_data_source.dart';

class CaptureRepositoryImpl with RepositoryGuard implements CaptureRepository {
  CaptureRepositoryImpl({required CaptureDraftDataSource source})
    : _source = source;

  final CaptureDraftDataSource _source;

  @override
  Future<Either<Failure, CaptureDraft?>> read() {
    return guard(() async => _source.read(), 'readCaptureDraft');
  }

  @override
  Future<Either<Failure, CaptureDraft>> hold(CaptureDraft draft) {
    return guard(() async {
      _source.hold(draft);
      return draft;
    }, 'holdCaptureDraft');
  }

  @override
  Future<Either<Failure, void>> clear() {
    return guard(() async => _source.clear(), 'clearCaptureDraft');
  }

  @override
  Future<Either<Failure, bool>> isFinished() {
    return guard(() async => _source.isFinished, 'captureDraftFinished');
  }

  @override
  Future<Either<Failure, void>> markFinished() {
    return guard(() async => _source.markFinished(), 'finishCaptureDraft');
  }
}
