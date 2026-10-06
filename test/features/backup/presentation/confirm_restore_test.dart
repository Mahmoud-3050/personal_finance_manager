import 'package:finzomanager/config/language/strings.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/features/backup/domain/usecases/export_book_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/get_backup_status_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/import_book_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/list_cloud_copies_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/preview_import_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/restore_cloud_copy_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/run_manual_backup_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/set_backup_schedule_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/sign_in_for_backup_use_case.dart';
import 'package:finzomanager/features/backup/presentation/controller/export_book/export_book_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/get_backup_status/get_backup_status_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/list_cloud_copies/list_cloud_copies_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/import_book/import_book_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/preview_import/preview_import_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/restore_cloud_copy/restore_cloud_copy_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/run_manual_backup/run_manual_backup_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/set_backup_schedule/set_backup_schedule_cubit.dart';
import 'package:finzomanager/features/backup/presentation/controller/sign_in_for_backup/sign_in_for_backup_cubit.dart';
import 'package:finzomanager/features/backup/presentation/pages/backup_status_page.dart';
import 'package:finzomanager/features/backup/presentation/pages/cloud_copies_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_util/screen_util.dart';

import '../support/memory_backup.dart';

void main() {
  testWidgets('cancelling restore leaves the book unchanged', (
    WidgetTester tester,
  ) async {
    final ScriptedBackupRepository repository = ScriptedBackupRepository();
    await tester.pumpWidget(
      ScreenUtilInit(
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<SignInForBackupCubit>(
                create: (_) =>
                    SignInForBackupCubit(SignInForBackupUseCase(repository)),
              ),
              BlocProvider<ListCloudCopiesCubit>(
                create: (_) =>
                    ListCloudCopiesCubit(ListCloudCopiesUseCase(repository)),
              ),
              BlocProvider<RestoreCloudCopyCubit>(
                create: (_) =>
                    RestoreCloudCopyCubit(RestoreCloudCopyUseCase(repository)),
              ),
            ],
            child: const CloudCopiesPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.backupRestore));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.fenzoCancel));
    await tester.pumpAndSettle();

    expect(repository.restores, 0);
  });

  testWidgets('cancelling import leaves the book unchanged', (
    WidgetTester tester,
  ) async {
    final ScriptedBackupRepository repository = ScriptedBackupRepository();
    await tester.pumpWidget(
      ScreenUtilInit(
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<GetBackupStatusCubit>(
                create: (_) =>
                    GetBackupStatusCubit(GetBackupStatusUseCase(repository))
                      ..fGetBackupStatus(),
              ),
              BlocProvider<SignInForBackupCubit>(
                create: (_) =>
                    SignInForBackupCubit(SignInForBackupUseCase(repository)),
              ),
              BlocProvider<RunManualBackupCubit>(
                create: (_) =>
                    RunManualBackupCubit(RunManualBackupUseCase(repository)),
              ),
              BlocProvider<SetBackupScheduleCubit>(
                create: (_) => SetBackupScheduleCubit(
                  SetBackupScheduleUseCase(repository),
                ),
              ),
              BlocProvider<ExportBookCubit>(
                create: (_) => ExportBookCubit(ExportBookUseCase(repository)),
              ),
              BlocProvider<ImportBookCubit>(
                create: (_) => ImportBookCubit(ImportBookUseCase(repository)),
              ),
              BlocProvider<PreviewImportCubit>(
                create: (_) =>
                    PreviewImportCubit(PreviewImportUseCase(repository)),
              ),
            ],
            child: const BackupStatusPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Strings.backupImport));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.backupImport));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.fenzoCancel));
    await tester.pumpAndSettle();

    expect(repository.imports, 0);
  });

  testWidgets('export refreshes the last attempt on the status screen', (
    WidgetTester tester,
  ) async {
    final ScriptedBackupRepository repository = ScriptedBackupRepository();
    await tester.pumpWidget(
      ScreenUtilInit(
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<GetBackupStatusCubit>(
                create: (_) =>
                    GetBackupStatusCubit(GetBackupStatusUseCase(repository))
                      ..fGetBackupStatus(),
              ),
              BlocProvider<SignInForBackupCubit>(
                create: (_) =>
                    SignInForBackupCubit(SignInForBackupUseCase(repository)),
              ),
              BlocProvider<RunManualBackupCubit>(
                create: (_) =>
                    RunManualBackupCubit(RunManualBackupUseCase(repository)),
              ),
              BlocProvider<SetBackupScheduleCubit>(
                create: (_) => SetBackupScheduleCubit(
                  SetBackupScheduleUseCase(repository),
                ),
              ),
              BlocProvider<ExportBookCubit>(
                create: (_) => ExportBookCubit(ExportBookUseCase(repository)),
              ),
              BlocProvider<ImportBookCubit>(
                create: (_) => ImportBookCubit(ImportBookUseCase(repository)),
              ),
              BlocProvider<PreviewImportCubit>(
                create: (_) =>
                    PreviewImportCubit(PreviewImportUseCase(repository)),
              ),
            ],
            child: const BackupStatusPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(Strings.backupNone), findsOneWidget);
    await tester.ensureVisible(find.text(Strings.backupExport));
    await tester.tap(find.text(Strings.backupExport));
    await tester.pumpAndSettle();

    expect(find.text(Strings.backupSucceeded), findsOneWidget);
    expect(find.text(Strings.backupExport), findsNWidgets(2));
  });

  testWidgets('cancelled identification returns to the status screen', (
    WidgetTester tester,
  ) async {
    final ScriptedBackupRepository repository = ScriptedBackupRepository(
      error: const SocialSignInCancelledFailure(),
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => MultiBlocProvider(
                        providers: <BlocProvider<dynamic>>[
                          BlocProvider<SignInForBackupCubit>(
                            create: (_) => SignInForBackupCubit(
                              SignInForBackupUseCase(repository),
                            ),
                          ),
                          BlocProvider<ListCloudCopiesCubit>(
                            create: (_) => ListCloudCopiesCubit(
                              ListCloudCopiesUseCase(repository),
                            ),
                          ),
                          BlocProvider<RestoreCloudCopyCubit>(
                            create: (_) => RestoreCloudCopyCubit(
                              RestoreCloudCopyUseCase(repository),
                            ),
                          ),
                        ],
                        child: const CloudCopiesPage(),
                      ),
                    ),
                  );
                },
                child: const Text('status'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('status'));
    await tester.pumpAndSettle();

    expect(find.text('status'), findsOneWidget);
    expect(find.text(Strings.backupCopies), findsNothing);
    expect(repository.restores, 0);
  });
}
