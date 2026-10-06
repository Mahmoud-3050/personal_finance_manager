import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_settings.dart';
import '../repositories/backup_repository.dart';

class RunAutomaticBackupParams extends Params {
  const RunAutomaticBackupParams({required this.now, this.cancellation});

  final DateTime now;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'now': now.toIso8601String(),
  };

  @override
  List<Object?> get props => <Object?>[now, cancellation];
}

class RunAutomaticBackupUseCase
    extends UseCase<BackupSettings, RunAutomaticBackupParams> {
  RunAutomaticBackupUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, BackupSettings>> call(
    RunAutomaticBackupParams params,
  ) {
    return _repository.runAutomaticBackup(now: params.now);
  }
}
