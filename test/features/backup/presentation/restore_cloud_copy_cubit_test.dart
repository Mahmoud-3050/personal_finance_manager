import 'package:bloc_test/bloc_test.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/backup/domain/usecases/restore_cloud_copy_use_case.dart';
import 'package:finzomanager/features/backup/presentation/controller/restore_cloud_copy/restore_cloud_copy_cubit.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  blocTest<RestoreCloudCopyCubit, ApiCallState<FinanceRecords>>(
    'restore emits loading then success',
    build: () => RestoreCloudCopyCubit(
      RestoreCloudCopyUseCase(ScriptedBackupRepository()),
    ),
    act: (RestoreCloudCopyCubit cubit) =>
        cubit.fRestoreCloudCopy(copyId: 'copy-1', confirmed: true),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );

  blocTest<RestoreCloudCopyCubit, ApiCallState<FinanceRecords>>(
    'restore emits loading then error',
    build: () => RestoreCloudCopyCubit(
      RestoreCloudCopyUseCase(
        ScriptedBackupRepository(error: const CacheFailure(message: 'missing')),
      ),
    ),
    act: (RestoreCloudCopyCubit cubit) =>
        cubit.fRestoreCloudCopy(copyId: 'copy-1', confirmed: true),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallError<FinanceRecords>>(),
    ],
  );
}
