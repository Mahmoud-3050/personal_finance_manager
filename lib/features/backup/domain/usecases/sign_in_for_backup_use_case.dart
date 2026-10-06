import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_settings.dart';
import '../repositories/backup_repository.dart';

class SignInForBackupUseCase extends UseCase<BackupSettings, NoParams> {
  SignInForBackupUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, BackupSettings>> call(NoParams params) {
    return _repository.signIn();
  }
}
