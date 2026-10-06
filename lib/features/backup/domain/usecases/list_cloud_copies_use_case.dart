import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_copy.dart';
import '../repositories/backup_repository.dart';

class ListCloudCopiesUseCase extends UseCase<List<BackupCopy>, NoParams> {
  ListCloudCopiesUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, List<BackupCopy>>> call(NoParams params) {
    return _repository.listCloudCopies();
  }
}
