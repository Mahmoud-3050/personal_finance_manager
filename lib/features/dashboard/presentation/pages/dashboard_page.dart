import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/category_share.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../accounts/domain/entities/account_list_data.dart';
import '../../../accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import '../../../categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../../transactions/domain/usecases/search_transactions_use_case.dart';
import '../../domain/entities/dashboard_data.dart';
import '../controller/get_dashboard/get_dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DateRange month = CalendarDate.monthContaining(CalendarDate.today());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.fenzoTitle,
          style: TextStyles.of(size: 18, weight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<GetDashboardCubit, ApiCallState<DashboardData>>(
        builder: (BuildContext context, ApiCallState<DashboardData> state) {
          if (state is ApiCallSuccess<DashboardData>) {
            final DashboardData data = state.data;
            final bool hasAccounts = _hasAccounts(context);
            final FinanceRecords? categories = _categories(context);
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Wrap(
                    spacing: 8.w,
                    children: <Widget>[
                      if (!hasAccounts)
                        OutlinedButton(
                          onPressed: () => context.push(AppRoutes.accountForm),
                          child: Text(
                            Strings.fenzoEmpty,
                            style: TextStyles.of(size: 14),
                          ),
                        ),
                      if (hasAccounts) ...<Widget>[
                        OutlinedButton(
                          onPressed: () => context.push(AppRoutes.accounts),
                          child: Text(
                            Strings.fenzoAccounts,
                            style: TextStyles.of(size: 14),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              context.push(AppRoutes.transactionForm),
                          child: Text(
                            Strings.fenzoTransactions,
                            style: TextStyles.of(size: 14),
                          ),
                        ),
                      ],
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.categories),
                        child: Text(
                          Strings.fenzoCategories,
                          style: TextStyles.of(size: 14),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.reports),
                        child: Text(
                          Strings.fenzoReports,
                          style: TextStyles.of(size: 14),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.backup),
                        child: Text(
                          Strings.backup,
                          style: TextStyles.of(size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                _AmountTile(
                  title: Strings.fenzoTotal,
                  amountMinor: data.totalMoneyMinor,
                  onTap: () => context.push(
                    AppRoutes.transactions,
                    extra: SearchTransactionsParams(
                      range: month,
                      excludeTransfers: true,
                    ),
                  ),
                ),
                _AmountTile(
                  title: Strings.fenzoIncome,
                  amountMinor: data.incomeMinor,
                  onTap: () => _open(
                    context,
                    SearchTransactionsParams(
                      range: month,
                      type: MoneyTransactionType.income,
                    ),
                  ),
                ),
                _AmountTile(
                  title: Strings.fenzoExpense,
                  amountMinor: data.expenseMinor,
                  onTap: () => _open(
                    context,
                    SearchTransactionsParams(
                      range: month,
                      type: MoneyTransactionType.expense,
                    ),
                  ),
                ),
                _AmountTile(
                  title: Strings.fenzoNet,
                  amountMinor: data.netMinor,
                  onTap: () => _open(
                    context,
                    SearchTransactionsParams(
                      range: month,
                      excludeTransfers: true,
                    ),
                  ),
                ),
                for (final Account account in data.accounts)
                  ListTile(
                    title: Text(
                      account.name,
                      style: TextStyles.of(size: 16, weight: FontWeight.w500),
                    ),
                    trailing: Text(
                      Money(data.accountBalances[account.id] ?? 0).format(),
                      style: TextStyles.of(size: 14),
                    ),
                    onTap: () => _open(
                      context,
                      SearchTransactionsParams(
                        range: month,
                        accountId: account.id,
                      ),
                    ),
                  ),
                for (final CategoryShare share in data.expenseShares)
                  ListTile(
                    title: Text(share.name, style: TextStyles.of(size: 16)),
                    subtitle: Text(
                      share.percentageLabel,
                      style: TextStyles.of(size: 13),
                    ),
                    trailing: Text(
                      Money(share.amountMinor).format(),
                      style: TextStyles.of(size: 14),
                    ),
                    onTap: () => _open(
                      context,
                      SearchTransactionsParams(
                        range: month,
                        type: MoneyTransactionType.expense,
                        categoryId: share.id,
                      ),
                    ),
                  ),
                for (final MoneyTransaction item in data.recent)
                  ListTile(
                    title: Text(
                      item.description ??
                          item.notes ??
                          _movementLabel(item.type),
                      style: TextStyles.of(size: 16),
                    ),
                    subtitle: Text(
                      _classification(item, categories, item.date.toIso()),
                      style: TextStyles.of(size: 13),
                    ),
                    trailing: Text(
                      Money(item.amountMinor).format(),
                      style: TextStyles.of(size: 14),
                    ),
                  ),
              ],
            );
          }
          if (state is ApiCallError<DashboardData>) {
            return Center(
              child: Text(state.message, style: TextStyles.of(size: 16)),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _classification(
    MoneyTransaction item,
    FinanceRecords? book,
    String date,
  ) {
    if (book == null) {
      return date;
    }
    final String? category = book.categories
        .where((Category category) => category.id == item.categoryId)
        .map((Category category) => category.name)
        .firstOrNull;
    final String? subcategory = book.subcategories
        .where(
          (Subcategory subcategory) => subcategory.id == item.subcategoryId,
        )
        .map((Subcategory subcategory) => subcategory.name)
        .firstOrNull;
    final String names = <String?>[
      category,
      subcategory,
    ].whereType<String>().join(' / ');
    if (names.isEmpty) {
      return date;
    }
    return '$date\n$names';
  }

  bool _hasAccounts(BuildContext context) {
    final ApiCallState<AccountListData> accounts = context
        .watch<GetAccountsCubit>()
        .state;
    return accounts is ApiCallSuccess<AccountListData> &&
        accounts.data.records.accounts.isNotEmpty;
  }

  FinanceRecords? _categories(BuildContext context) {
    final ApiCallState<FinanceRecords> categories = context
        .watch<GetCategoriesCubit>()
        .state;
    return categories is ApiCallSuccess<FinanceRecords>
        ? categories.data
        : null;
  }

  String _movementLabel(MoneyTransactionType type) => switch (type) {
    MoneyTransactionType.income => Strings.fenzoIncome,
    MoneyTransactionType.expense => Strings.fenzoExpense,
    MoneyTransactionType.transfer => Strings.fenzoTransfer,
  };

  void _open(BuildContext context, SearchTransactionsParams query) {
    context.push(AppRoutes.transactions, extra: query);
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.title,
    required this.amountMinor,
    required this.onTap,
  });

  final String title;
  final int amountMinor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyles.of(size: 16, weight: FontWeight.w500),
      ),
      trailing: Text(
        Money(amountMinor).format(),
        style: TextStyles.of(size: 14),
      ),
      onTap: onTap,
    );
  }
}
