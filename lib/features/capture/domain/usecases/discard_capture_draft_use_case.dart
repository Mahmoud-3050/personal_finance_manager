import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/capture_repository.dart';

class DiscardCaptureDraftUseCase extends UseCase<bool, NoParams> {
  DiscardCaptureDraftUseCase({required CaptureRepository repository})
    : _repository = repository;

  final CaptureRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    final Either<Failure, void> cleared = await _repository.clear();
    return cleared.map((_) => true);
  }
}
