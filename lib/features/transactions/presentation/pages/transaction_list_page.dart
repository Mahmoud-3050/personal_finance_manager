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
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_summary.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/confirm_action_dialog.dart';
import '../../../../shared/widgets/dialogs/show_modal_bottom_sheet.dart';
import '../../../dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../../accounts/domain/entities/account_list_data.dart';
import '../../../accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import '../../../categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../domain/usecases/delete_transaction_use_case.dart';
import '../../domain/usecases/search_transactions_use_case.dart';
import '../controller/delete_transaction/delete_transaction_cubit.dart';
import '../controller/save_expense/save_expense_cubit.dart';
import '../controller/save_income/save_income_cubit.dart';
import '../controller/save_transfer/save_transfer_cubit.dart';
import '../controller/search_transactions/search_transactions_cubit.dart';
import '../controller/update_transaction/update_transaction_cubit.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({this.initialQuery, super.key});

  final SearchTransactionsParams? initialQuery;

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late final TextEditingController _search = TextEditingController(
    text: widget.initialQuery?.query ?? '',
  );
  late String? _accountId = widget.initialQuery?.accountId;
  late MoneyTransactionType? _type = widget.initialQuery?.type;
  late String? _categoryId = widget.initialQuery?.categoryId;
  late String? _subcategoryId = widget.initialQuery?.subcategoryId;

  @override
  void initState() {
    super.initState();
    _searchNow();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ApiCallState<AccountListData> accountsState = context
        .watch<GetAccountsCubit>()
        .state;
    final ApiCallState<FinanceRecords> categoriesState = context
        .watch<GetCategoriesCubit>()
        .state;
    final List<Account> accounts =
        accountsState is ApiCallSuccess<AccountListData>
        ? accountsState.data.records.accounts
        : const <Account>[];
    final List<Category> categories =
        categoriesState is ApiCallSuccess<FinanceRecords>
        ? categoriesState.data.categories
        : const <Category>[];
    final List<Subcategory> subcategories =
        categoriesState is ApiCallSuccess<FinanceRecords>
        ? categoriesState.data.subcategories
        : const <Subcategory>[];
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<DeleteTransactionCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadAfterChange,
        ),
        BlocListener<UpdateTransactionCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadAfterChange,
        ),
        BlocListener<SaveIncomeCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadAfterChange,
        ),
        BlocListener<SaveExpenseCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadAfterChange,
        ),
        BlocListener<SaveTransferCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadAfterChange,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.fenzoSearch,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 4.w, 8.h),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: AppTextFormField(
                      controller: _search,
                      labelText: Strings.fenzoSearch,
                      onChanged: (_) => _searchNow(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openFilters(
                      accounts,
                      categories,
                      subcategories,
                    ),
                    icon: Icon(
                      Icons.tune,
                      color: _filtersActive
                          ? context.colors.primary
                          : context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  BlocBuilder<
                    SearchTransactionsCubit,
                    ApiCallState<List<MoneyTransaction>>
                  >(
                    builder:
                        (
                          BuildContext context,
                          ApiCallState<List<MoneyTransaction>> state,
                        ) {
                          if (state is ApiCallSuccess<List<MoneyTransaction>>) {
                            if (state.data.isEmpty) {
                              final bool hasFilters =
                                  _search.text.trim().isNotEmpty ||
                                  _accountId != null ||
                                  _type != null ||
                                  _categoryId != null ||
                                  _subcategoryId != null ||
                                  widget.initialQuery?.range != null ||
                                  (widget.initialQuery?.excludeTransfers ??
                                      false);
                              return Center(
                                child: Text(
                                  hasFilters || accounts.isNotEmpty
                                      ? Strings.fenzoNoMatches
                                      : Strings.fenzoEmpty,
                                  style: TextStyles.of(size: 16),
                                ),
                              );
                            }
                            return ListView(
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 88.h),
                              children: state.data
                                  .map(
                                    (MoneyTransaction item) =>
                                        TransactionSummary(
                                          item: item,
                                          book:
                                              categoriesState
                                                  is ApiCallSuccess<
                                                    FinanceRecords
                                                  >
                                              ? categoriesState.data
                                              : null,
                                          onTap: () => context.push(
                                            AppRoutes.transactionForm,
                                            extra: item,
                                          ),
                                          trailing: IconButton(
                                            onPressed: () =>
                                                _confirmDelete(context, item),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList(),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                  ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: Strings.fenzoTransactions,
          onPressed: () => context.push(AppRoutes.transactionForm),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  bool get _filtersActive =>
      _accountId != null ||
      _type != null ||
      _categoryId != null ||
      _subcategoryId != null;

  Future<void> _openFilters(
    List<Account> accounts,
    List<Category> categories,
    List<Subcategory> subcategories,
  ) {
    return showAppModalBottomSheet(
      context: context,
      child: TransactionFilterSheet(
        accounts: accounts,
        categories: categories,
        subcategories: subcategories,
        accountId: _accountId,
        type: _type,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        onChanged: (TransactionFilterValue value) {
          setState(() {
            _accountId = value.accountId;
            _type = value.type;
            _categoryId = value.categoryId;
            _subcategoryId = value.subcategoryId;
          });
          _searchNow();
        },
      ),
    );
  }

  void _reloadAfterChange(
    BuildContext context,
    ApiCallState<FinanceRecords> state,
  ) {
    if (state is! ApiCallSuccess<FinanceRecords>) {
      return;
    }
    _searchNow();
    context.read<GetAccountsCubit>().fGetAccounts();
    context.read<GetDashboardCubit>().fGetDashboard();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MoneyTransaction item,
  ) async {
    final bool confirmed = await confirmAccountAction(
      context,
      message: Strings.fenzoDelete,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    context.read<DeleteTransactionCubit>().fDeleteTransaction(
      DeleteTransactionParams(item.id),
    );
  }

  void _searchNow() {
    context.read<SearchTransactionsCubit>().fSearchTransactions(
      SearchTransactionsParams(
        query: _search.text,
        range: widget.initialQuery?.range,
        accountId: _accountId,
        type: _type,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        excludeTransfers: widget.initialQuery?.excludeTransfers ?? false,
      ),
    );
  }
}
