import 'package:bloc_test/bloc_test.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/usecases/run_automatic_backup_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/set_backup_schedule_use_case.dart';
import 'package:finzomanager/features/backup/presentation/controller/run_automatic_backup/run_automatic_backup_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/set_backup_schedule/set_backup_schedule_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  blocTest<SetBackupScheduleCubit, ApiCallState<BackupSettings>>(
    'setting the schedule emits loading then success',
    build: () => SetBackupScheduleCubit(
      SetBackupScheduleUseCase(ScriptedBackupRepository()),
    ),
    act: (SetBackupScheduleCubit cubit) =>
        cubit.fSetBackupSchedule(BackupSchedule.weekly),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallSuccess<BackupSettings>>(),
    ],
  );

  blocTest<RunAutomaticBackupCubit, ApiCallState<BackupSettings>>(
    'automatic backup emits loading then success',
    build: () => RunAutomaticBackupCubit(
      RunAutomaticBackupUseCase(ScriptedBackupRepository()),
    ),
    act: (RunAutomaticBackupCubit cubit) =>
        cubit.fRunAutomaticBackup(now: DateTime.utc(2026, 10, 6)),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallSuccess<BackupSettings>>(),
    ],
  );

  blocTest<RunAutomaticBackupCubit, ApiCallState<BackupSettings>>(
    'automatic backup emits loading then error',
    build: () => RunAutomaticBackupCubit(
      RunAutomaticBackupUseCase(
        ScriptedBackupRepository(error: const ServerFailure(message: 'cloud')),
      ),
    ),
    act: (RunAutomaticBackupCubit cubit) => cubit.fRunAutomaticBackup(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallError<BackupSettings>>(),
    ],
  );
}
