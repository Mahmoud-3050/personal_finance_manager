import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_settings.dart';
import '../repositories/backup_repository.dart';

class GetBackupStatusUseCase extends UseCase<BackupSettings, NoParams> {
  GetBackupStatusUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, BackupSettings>> call(NoParams params) {
    return _repository.getStatus();
  }
}
