import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/finance/account_mark.dart';
import '../../../../shared/widgets/finance/summary_card.dart';
import '../../../../shared/widgets/confirm_action_dialog.dart';
import '../../domain/entities/account_list_data.dart';
import '../../../dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../domain/usecases/deactivate_account_use_case.dart';
import '../../domain/usecases/delete_account_use_case.dart';
import '../../domain/usecases/reactivate_account_use_case.dart';
import '../controller/deactivate_account/deactivate_account_cubit.dart';
import '../controller/delete_account/delete_account_cubit.dart';
import '../controller/get_accounts/get_accounts_cubit.dart';
import '../controller/reactivate_account/reactivate_account_cubit.dart';

class AccountListPage extends StatelessWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<DeactivateAccountCubit, ApiCallState<FinanceRecords>>(
          listener: _refreshAfterSuccess,
        ),
        BlocListener<ReactivateAccountCubit, ApiCallState<FinanceRecords>>(
          listener: _refreshAfterSuccess,
        ),
        BlocListener<DeleteAccountCubit, ApiCallState<FinanceRecords>>(
          listener: _refreshAfterSuccess,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.fenzoAccounts,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: BlocBuilder<GetAccountsCubit, ApiCallState<AccountListData>>(
          builder: (BuildContext context, ApiCallState<AccountListData> state) {
            if (state is! ApiCallSuccess<AccountListData> ||
                state.data.records.accounts.isEmpty) {
              return Center(
                child: Text(Strings.fenzoEmpty, style: TextStyles.of(size: 16)),
              );
            }
            final AccountListData data = state.data;
            final FinanceRecords book = data.records;
            return ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 88.h),
              children: book.accounts
                  .map(
                    (Account account) => SummaryCard(
                      title: account.name,
                      subtitle: account.isActive
                          ? null
                          : Strings.fenzoDeactivate,
                      amount: account.isActive
                          ? Money(data.balances[account.id] ?? 0).format()
                          : null,
                      amountColor: context.colors.success,
                      leading: AccountMark(type: account.type),
                      onTap: () =>
                          context.push(AppRoutes.accountForm, extra: account),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String action) =>
                            _onAction(context, account, action),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              if (account.isActive)
                                PopupMenuItem<String>(
                                  value: 'deactivate',
                                  child: Text(
                                    Strings.fenzoDeactivate,
                                    style: TextStyles.of(size: 14),
                                  ),
                                ),
                              if (!account.isActive)
                                PopupMenuItem<String>(
                                  value: 'reactivate',
                                  child: Text(
                                    Strings.fenzoReactivate,
                                    style: TextStyles.of(size: 14),
                                  ),
                                ),
                              if (!_hasMovement(book, account.id))
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text(
                                    Strings.fenzoDelete,
                                    style: TextStyles.of(size: 14),
                                  ),
                                ),
                            ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.accountForm),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _refreshAfterSuccess(
    BuildContext context,
    ApiCallState<FinanceRecords> state,
  ) {
    if (state is! ApiCallSuccess<FinanceRecords>) {
      return;
    }
    context.read<GetAccountsCubit>().fGetAccounts();
    context.read<GetDashboardCubit>().fGetDashboard();
  }

  Future<void> _onAction(
    BuildContext context,
    Account account,
    String action,
  ) async {
    final String message = switch (action) {
      'reactivate' => Strings.fenzoReactivate,
      'delete' => Strings.fenzoDelete,
      _ => Strings.fenzoDeactivate,
    };
    final bool confirmed = await confirmAccountAction(
      context,
      message: message,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    switch (action) {
      case 'deactivate':
        context.read<DeactivateAccountCubit>().fDeactivateAccount(
          DeactivateAccountParams(account.id),
        );
      case 'reactivate':
        context.read<ReactivateAccountCubit>().fReactivateAccount(
          ReactivateAccountParams(account.id),
        );
      case 'delete':
        context.read<DeleteAccountCubit>().fDeleteAccount(
          DeleteAccountParams(account.id),
        );
    }
  }
}

bool _hasMovement(FinanceRecords book, String accountId) {
  return book.transactions.any(
    (MoneyTransaction item) =>
        item.accountId == accountId ||
        item.fromAccountId == accountId ||
        item.toAccountId == accountId,
  );
}
