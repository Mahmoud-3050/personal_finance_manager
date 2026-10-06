import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/backup_settings.dart';
import '../../../domain/usecases/run_manual_backup_use_case.dart';

part 'run_manual_backup_states.dart';

class RunManualBackupCubit extends Cubit<RunManualBackupState> {
  RunManualBackupCubit(this._useCase)
    : super(const ApiCallHolding<BackupSettings>());

  final RunManualBackupUseCase _useCase;

  Future<void> fRunManualBackup({DateTime? now}) async {
    emit(const ApiCallLoading<BackupSettings>());
    final result = await _useCase(
      RunManualBackupParams(now: now ?? DateTime.now()),
    );
    result.fold(
      (failure) =>
          emit(ApiCallError<BackupSettings>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<BackupSettings>(data: data)),
    );
  }
}
