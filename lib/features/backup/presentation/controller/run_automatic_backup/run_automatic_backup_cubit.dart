import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/backup_settings.dart';
import '../../../domain/usecases/run_automatic_backup_use_case.dart';

part 'run_automatic_backup_states.dart';

class RunAutomaticBackupCubit extends Cubit<RunAutomaticBackupState> {
  RunAutomaticBackupCubit(this._useCase)
    : super(const ApiCallHolding<BackupSettings>());

  final RunAutomaticBackupUseCase _useCase;

  Future<void> fRunAutomaticBackup({DateTime? now}) async {
    emit(const ApiCallLoading<BackupSettings>());
    final result = await _useCase(
      RunAutomaticBackupParams(now: now ?? DateTime.now()),
    );
    result.fold(
      (failure) =>
          emit(ApiCallError<BackupSettings>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<BackupSettings>(data: data)),
    );
  }
}
