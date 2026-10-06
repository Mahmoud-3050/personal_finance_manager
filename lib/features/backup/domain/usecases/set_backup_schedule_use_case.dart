import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_settings.dart';
import '../repositories/backup_repository.dart';

class SetBackupScheduleParams extends Params {
  const SetBackupScheduleParams({required this.schedule, this.cancellation});

  final BackupSchedule schedule;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'schedule': schedule.name};

  @override
  List<Object?> get props => <Object?>[schedule, cancellation];
}

class SetBackupScheduleUseCase
    extends UseCase<BackupSettings, SetBackupScheduleParams> {
  SetBackupScheduleUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, BackupSettings>> call(SetBackupScheduleParams params) {
    return _repository.setSchedule(params.schedule);
  }
}
