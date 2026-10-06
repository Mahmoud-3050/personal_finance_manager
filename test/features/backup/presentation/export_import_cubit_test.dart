import 'package:bloc_test/bloc_test.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/usecases/export_book_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/import_book_use_case.dart';
import 'package:finzomanager/features/backup/presentation/controller/export_book/export_book_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/import_book/import_book_cubit.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  blocTest<ExportBookCubit, ApiCallState<BackupSettings>>(
    'export emits loading then success',
    build: () => ExportBookCubit(ExportBookUseCase(ScriptedBackupRepository())),
    act: (ExportBookCubit cubit) =>
        cubit.fExportBook(now: DateTime.utc(2026, 10, 6)),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallSuccess<BackupSettings>>(),
    ],
  );

  blocTest<ExportBookCubit, ApiCallState<BackupSettings>>(
    'export emits loading then error',
    build: () => ExportBookCubit(
      ExportBookUseCase(
        ScriptedBackupRepository(error: const CacheFailure(message: 'file')),
      ),
    ),
    act: (ExportBookCubit cubit) => cubit.fExportBook(),
    expect: () => <Object>[
      isA<ApiCallLoading<BackupSettings>>(),
      isA<ApiCallError<BackupSettings>>(),
    ],
  );

  blocTest<ImportBookCubit, ApiCallState<FinanceRecords>>(
    'import emits loading then success',
    build: () => ImportBookCubit(ImportBookUseCase(ScriptedBackupRepository())),
    act: (ImportBookCubit cubit) => cubit.fImportBook(confirmed: true),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );

  blocTest<ImportBookCubit, ApiCallState<FinanceRecords>>(
    'import emits loading then error',
    build: () => ImportBookCubit(
      ImportBookUseCase(
        ScriptedBackupRepository(
          error: const ValidationFailure(message: 'invalid_backup'),
        ),
      ),
    ),
    act: (ImportBookCubit cubit) => cubit.fImportBook(confirmed: true),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallError<FinanceRecords>>(),
    ],
  );
}
