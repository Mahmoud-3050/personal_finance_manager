import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/backup_settings.dart';
import '../../../domain/usecases/set_backup_schedule_use_case.dart';

part 'set_backup_schedule_states.dart';

class SetBackupScheduleCubit extends Cubit<SetBackupScheduleState> {
  SetBackupScheduleCubit(this._useCase)
    : super(const ApiCallHolding<BackupSettings>());

  final SetBackupScheduleUseCase _useCase;

  Future<void> fSetBackupSchedule(BackupSchedule schedule) async {
    emit(const ApiCallLoading<BackupSettings>());
    final result = await _useCase(SetBackupScheduleParams(schedule: schedule));
    result.fold(
      (failure) =>
          emit(ApiCallError<BackupSettings>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<BackupSettings>(data: data)),
    );
  }
}
