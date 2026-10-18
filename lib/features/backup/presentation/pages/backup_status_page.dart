import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/fonts.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/widgets/confirm_action_dialog.dart';
import '../../domain/entities/backup_settings.dart';
import '../../domain/entities/import_preview.dart';
import '../controller/export_book/export_book_cubit.dart';
import '../controller/get_backup_status/get_backup_status_cubit.dart';
import '../controller/import_book/import_book_cubit.dart';
import '../controller/preview_import/preview_import_cubit.dart';
import '../../../../shared/widgets/platform/platform_app_bar.dart';
import '../../../../shared/widgets/platform/platform_button.dart';
import '../widgets/reload_finance_book.dart';
import '../controller/run_manual_backup/run_manual_backup_cubit.dart';
import '../controller/set_backup_schedule/set_backup_schedule_cubit.dart';
import '../controller/sign_in_for_backup/sign_in_for_backup_cubit.dart';

class BackupStatusPage extends StatelessWidget {
  const BackupStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformAppBar(
        leading: PlatformBackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(Strings.backup, style: TextStyles.of(size: 18)),
      ),
      body: BlocBuilder<GetBackupStatusCubit, GetBackupStatusState>(
        builder: (BuildContext context, GetBackupStatusState state) {
          final BackupSettings settings = switch (state) {
            ApiCallSuccess(:final data) => data,
            _ => const BackupSettings(),
          };
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            children: <Widget>[
              Text(
                _scheduleLabel(settings.schedule),
                style: TextStyles.of(
                  size: 28,
                  weight: TextStyles.semibold,
                  fontFamily: Fonts.display,
                  letterSpacing: Fonts.tracking(-0.6),
                  fontVariations: Fonts.usesArabic
                      ? null
                      : const <FontVariation>[FontVariation.weight(600)],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                settings.lastOutcome == null
                    ? Strings.backupNone
                    : _outcomeLabel(settings.lastOutcome!),
                style: TextStyles.of(
                  size: 15,
                  color: context.colors.textSecondary,
                ),
              ),
              if (settings.lastAttemptAt != null)
                Text(
                  settings.lastAttemptAt!.toIso8601String(),
                  style: TextStyles.of(size: 13, color: context.colors.hint),
                ),
              if (settings.lastOrigin != null)
                Text(
                  _originLabel(settings.lastOrigin!),
                  style: TextStyles.of(size: 13, color: context.colors.hint),
                ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: <Widget>[
                  for (final BackupSchedule schedule in BackupSchedule.values)
                    _scheduleButton(context, settings, schedule),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: PlatformButton(
                  label: Strings.backupNow,
                  onPressed: () => _backupNow(context),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: PlatformButton(
                  label: Strings.backupCopies,
                  filled: false,
                  onPressed: () => context.push(AppRoutes.cloudCopies),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: PlatformButton(
                  label: Strings.backupExport,
                  filled: false,
                  onPressed: () => _export(context),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: PlatformButton(
                  label: Strings.backupImport,
                  filled: false,
                  onPressed: () => _import(context),
                ),
              ),
              BlocBuilder<SignInForBackupCubit, SignInForBackupState>(
                builder: (BuildContext context, SignInForBackupState signIn) {
                  if (signIn case ApiCallError(:final message)) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(message, style: TextStyles.of(size: 13)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<PreviewImportCubit, PreviewImportState>(
                builder: (BuildContext context, PreviewImportState preview) {
                  if (preview case ApiCallError(:final message)) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(message, style: TextStyles.of(size: 13)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<ImportBookCubit, ImportBookState>(
                builder: (BuildContext context, ImportBookState imported) {
                  if (imported case ApiCallError(:final message)) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(message, style: TextStyles.of(size: 13)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<RunManualBackupCubit, RunManualBackupState>(
                builder: (BuildContext context, RunManualBackupState manual) {
                  if (manual case ApiCallError(:final message)) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(message, style: TextStyles.of(size: 13)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scheduleButton(
    BuildContext context,
    BackupSettings settings,
    BackupSchedule schedule,
  ) {
    return PlatformButton(
      label: _scheduleLabel(schedule),
      filled: settings.schedule == schedule,
      onPressed: () => _setSchedule(context, schedule),
    );
  }

  Future<void> _setSchedule(
    BuildContext context,
    BackupSchedule schedule,
  ) async {
    await context.read<SetBackupScheduleCubit>().fSetBackupSchedule(schedule);
    if (!context.mounted) {
      return;
    }
    await context.read<GetBackupStatusCubit>().fGetBackupStatus();
  }

  Future<void> _backupNow(BuildContext context) async {
    await context.read<SignInForBackupCubit>().fSignInForBackup();
    if (!context.mounted) {
      return;
    }
    if (context.read<SignInForBackupCubit>().state
        is! ApiCallSuccess<BackupSettings>) {
      return;
    }
    await context.read<RunManualBackupCubit>().fRunManualBackup();
    if (!context.mounted) {
      return;
    }
    await context.read<GetBackupStatusCubit>().fGetBackupStatus();
  }

  Future<void> _export(BuildContext context) async {
    await context.read<ExportBookCubit>().fExportBook();
    if (!context.mounted) {
      return;
    }
    if (context.read<ExportBookCubit>().state
        is ApiCallSuccess<BackupSettings>) {
      await context.read<GetBackupStatusCubit>().fGetBackupStatus();
    }
  }

  Future<void> _import(BuildContext context) async {
    await context.read<PreviewImportCubit>().fPreviewImport();
    if (!context.mounted) {
      return;
    }
    final PreviewImportState preview = context.read<PreviewImportCubit>().state;
    if (preview is! ApiCallSuccess<ImportPreview>) {
      return;
    }
    final bool confirmed = await confirmAccountAction(
      context,
      message:
          '${Strings.backupConfirmImport}\n${preview.data.createdAt.toIso8601String()}',
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    await context.read<ImportBookCubit>().fImportBook(
      confirmed: true,
      replacement: preview.data.records,
    );
    if (!context.mounted) {
      return;
    }
    if (context.read<ImportBookCubit>().state is ApiCallSuccess) {
      reloadFinanceBook(context);
    }
  }

  String _scheduleLabel(BackupSchedule schedule) => switch (schedule) {
    BackupSchedule.off => Strings.backupOff,
    BackupSchedule.daily => Strings.backupDaily,
    BackupSchedule.weekly => Strings.backupWeekly,
    BackupSchedule.monthly => Strings.backupMonthly,
  };

  String _originLabel(BackupOrigin origin) => switch (origin) {
    BackupOrigin.manualCloud => Strings.backupManual,
    BackupOrigin.automaticCloud => Strings.backupAutomatic,
    BackupOrigin.export => Strings.backupExport,
  };

  String _outcomeLabel(BackupOutcome outcome) => switch (outcome) {
    BackupOutcome.succeeded => Strings.backupSucceeded,
    BackupOutcome.failed => Strings.backupFailed,
    BackupOutcome.waiting => Strings.backupWaiting,
  };
}
