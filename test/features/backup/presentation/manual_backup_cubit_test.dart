import 'package:bloc_test/bloc_test.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/core/usecases/usecase.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/usecases/get_backup_status_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/run_manual_backup_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/sign_in_for_backup_use_case.dart';
import 'package:finzomanager/features/backup/presentation/controller/get_backup_status/get_backup_status_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/run_manual_backup/run_manual_backup_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/sign_in_for_backup/sign_in_for_backup_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  blocTest<RunManualBackupCubit, ApiCallState<BackupSettings>>(
    'manual backup emits loading then success',
    build: () => RunManualBackupCubit(
      RunManualBackupUseCase(ScriptedBackupRepository()),
    ),
    act: (RunManualBackupCubit cubit) =>
        cubit.fRunManualBackup(now: DateTime.utc(2026, 10, 6)),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallSuccess<BackupSettings>>(),
    ],
  );

  blocTest<RunManualBackupCubit, ApiCallState<BackupSettings>>(
    'manual backup emits loading then error',
    build: () => RunManualBackupCubit(
      RunManualBackupUseCase(
        ScriptedBackupRepository(
          error: const NetworkFailure(message: 'offline'),
        ),
      ),
    ),
    act: (RunManualBackupCubit cubit) => cubit.fRunManualBackup(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallError<BackupSettings>>(),
    ],
  );

  blocTest<SignInForBackupCubit, ApiCallState<BackupSettings>>(
    'sign-in emits loading then success',
    build: () => SignInForBackupCubit(
      SignInForBackupUseCase(ScriptedBackupRepository()),
    ),
    act: (SignInForBackupCubit cubit) => cubit.fSignInForBackup(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallSuccess<BackupSettings>>(),
    ],
  );

  blocTest<SignInForBackupCubit, ApiCallState<BackupSettings>>(
    'sign-in emits loading then error',
    build: () => SignInForBackupCubit(
      SignInForBackupUseCase(
        ScriptedBackupRepository(error: const SocialSignInCancelledFailure()),
      ),
    ),
    act: (SignInForBackupCubit cubit) => cubit.fSignInForBackup(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallError<BackupSettings>>(),
    ],
  );

  blocTest<GetBackupStatusCubit, ApiCallState<BackupSettings>>(
    'status emits loading then success',
    build: () => GetBackupStatusCubit(
      GetBackupStatusUseCase(ScriptedBackupRepository()),
    ),
    act: (GetBackupStatusCubit cubit) => cubit.fGetBackupStatus(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallSuccess<BackupSettings>>(),
    ],
  );

  blocTest<GetBackupStatusCubit, ApiCallState<BackupSettings>>(
    'status emits loading then error',
    build: () => GetBackupStatusCubit(
      GetBackupStatusUseCase(
        ScriptedBackupRepository(error: const CacheFailure(message: 'prefs')),
      ),
    ),
    act: (GetBackupStatusCubit cubit) => cubit.fGetBackupStatus(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallError<BackupSettings>>(),
    ],
  );
}
