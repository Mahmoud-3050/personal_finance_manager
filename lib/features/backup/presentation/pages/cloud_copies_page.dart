import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/confirm_action_dialog.dart';
import '../../domain/entities/backup_copy.dart';
import '../../domain/entities/backup_settings.dart';
import '../controller/list_cloud_copies/list_cloud_copies_cubit.dart';
import '../controller/restore_cloud_copy/restore_cloud_copy_cubit.dart';
import '../controller/sign_in_for_backup/sign_in_for_backup_cubit.dart';
import '../widgets/reload_finance_book.dart';

class CloudCopiesPage extends StatefulWidget {
  const CloudCopiesPage({super.key});

  @override
  State<CloudCopiesPage> createState() => _CloudCopiesPageState();
}

class _CloudCopiesPageState extends State<CloudCopiesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCopies());
  }

  Future<void> _loadCopies() async {
    if (!mounted) {
      return;
    }
    await context.read<SignInForBackupCubit>().fSignInForBackup();
    if (!mounted) {
      return;
    }
    if (context.read<SignInForBackupCubit>().state
        is! ApiCallSuccess<BackupSettings>) {
      Navigator.of(context).maybePop();
      return;
    }
    await context.read<ListCloudCopiesCubit>().fListCloudCopies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.backupCopies, style: TextStyles.of(size: 18)),
      ),
      body: BlocBuilder<SignInForBackupCubit, SignInForBackupState>(
        builder: (BuildContext context, SignInForBackupState signIn) {
          if (signIn case ApiCallError(:final message)) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(message, style: TextStyles.of(size: 14)),
            );
          }
          return BlocBuilder<ListCloudCopiesCubit, ListCloudCopiesState>(
            builder: (BuildContext context, ListCloudCopiesState state) {
              return switch (state) {
                ApiCallLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ApiCallSuccess(:final data) => ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final BackupCopy copy = data[index];
                    return ListTile(
                      key: ValueKey<String>(copy.id),
                      title: Text(
                        copy.createdAt.toIso8601String(),
                        style: TextStyles.of(size: 14),
                      ),
                      subtitle: Text(
                        Strings.backupCloud,
                        style: TextStyles.of(size: 13),
                      ),
                      trailing: TextButton(
                        onPressed: () => _restore(context, copy),
                        child: Text(
                          Strings.backupRestore,
                          style: TextStyles.of(size: 14),
                        ),
                      ),
                    );
                  },
                ),
                ApiCallError(:final message) => Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(message, style: TextStyles.of(size: 14)),
                ),
                _ => const SizedBox.shrink(),
              };
            },
          );
        },
      ),
    );
  }

  Future<void> _restore(BuildContext context, BackupCopy copy) async {
    final bool confirmed = await confirmAccountAction(
      context,
      message:
          '${Strings.backupConfirmRestore}\n${copy.createdAt.toIso8601String()}',
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    await context.read<RestoreCloudCopyCubit>().fRestoreCloudCopy(
      copyId: copy.id,
      confirmed: true,
    );
    if (!context.mounted) {
      return;
    }
    if (context.read<RestoreCloudCopyCubit>().state
        is ApiCallSuccess<FinanceRecords>) {
      reloadFinanceBook(context);
    }
  }
}
