import 'package:either/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/finance_ledger.dart';
import '../../../../shared/widgets/finance_menu_field.dart';
import '../../../accounts/domain/entities/account_list_data.dart';
import '../../../accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import '../../../categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../../dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../domain/usecases/save_expense_use_case.dart';
import '../../domain/usecases/save_income_use_case.dart';
import '../../domain/usecases/save_transfer_use_case.dart';
import '../../domain/usecases/update_transaction_use_case.dart';
import '../controller/save_expense/save_expense_cubit.dart';
import '../controller/save_income/save_income_cubit.dart';
import '../controller/save_transfer/save_transfer_cubit.dart';
import '../controller/update_transaction/update_transaction_cubit.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({this.existing, super.key});

  final MoneyTransaction? existing;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.existing == null
        ? ''
        : Money(widget.existing!.amountMinor).format(),
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.existing?.notes ?? widget.existing?.description ?? '',
  );
  late MoneyTransactionType _type =
      widget.existing?.type ?? MoneyTransactionType.expense;
  late CalendarDate _date = widget.existing?.date ?? CalendarDate.today();
  late String? _accountId = widget.existing?.accountId;
  late String? _categoryId = widget.existing?.categoryId;
  late String? _subcategoryId = widget.existing?.subcategoryId;
  late String? _fromAccountId = widget.existing?.fromAccountId;
  late String? _toAccountId = widget.existing?.toAccountId;
  String? _message;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<SaveIncomeCubit, ApiCallState<FinanceRecords>>(
          listener: _onSaved,
        ),
        BlocListener<SaveExpenseCubit, ApiCallState<FinanceRecords>>(
          listener: _onSaved,
        ),
        BlocListener<SaveTransferCubit, ApiCallState<FinanceRecords>>(
          listener: _onSaved,
        ),
        BlocListener<UpdateTransactionCubit, ApiCallState<FinanceRecords>>(
          listener: _onSaved,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: BlocBuilder<GetAccountsCubit, ApiCallState<AccountListData>>(
          builder:
              (
                BuildContext context,
                ApiCallState<AccountListData> accountsState,
              ) {
                final FinanceRecords? accountsBook =
                    accountsState is ApiCallSuccess<AccountListData>
                    ? accountsState.data.records
                    : null;
                return BlocBuilder<
                  GetCategoriesCubit,
                  ApiCallState<FinanceRecords>
                >(
                  builder:
                      (
                        BuildContext context,
                        ApiCallState<FinanceRecords> categoriesState,
                      ) {
                        final List<Account> activeAccounts =
                            accountsBook?.accounts
                                .where((Account item) => item.isActive)
                                .toList() ??
                            const <Account>[];
                        if (activeAccounts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                Strings.fenzoEmpty,
                                style: TextStyles.of(size: 16),
                              ),
                            ),
                          );
                        }
                        final FinanceRecords? categoryBook =
                            categoriesState is ApiCallSuccess<FinanceRecords>
                            ? categoriesState.data
                            : null;
                        return _FormBody(
                          type: _type,
                          typeLocked: widget.existing != null,
                          amount: _amount,
                          notes: _notes,
                          date: _date,
                          accounts: activeAccounts,
                          categories: _matchingCategories(categoryBook),
                          subcategories: _matchingSubcategories(categoryBook),
                          accountId: _accountId,
                          categoryId: _categoryId,
                          subcategoryId: _subcategoryId,
                          fromAccountId: _fromAccountId,
                          toAccountId: _toAccountId,
                          onTypeChanged: (MoneyTransactionType value) {
                            setState(() {
                              _type = value;
                              _categoryId = null;
                              _subcategoryId = null;
                            });
                          },
                          onAccountChanged: (String? value) =>
                              setState(() => _accountId = value),
                          onCategoryChanged: (String? value) {
                            setState(() {
                              _categoryId = value;
                              _subcategoryId = null;
                            });
                          },
                          onSubcategoryChanged: (String? value) =>
                              setState(() => _subcategoryId = value),
                          onFromChanged: (String? value) =>
                              setState(() => _fromAccountId = value),
                          onToChanged: (String? value) =>
                              setState(() => _toAccountId = value),
                          onPickDate: _pickDate,
                          onSave: _save,
                          message: _message,
                        );
                      },
                );
              },
        ),
      ),
    );
  }

  String get _title => switch (_type) {
    MoneyTransactionType.income => Strings.fenzoIncome,
    MoneyTransactionType.expense => Strings.fenzoExpense,
    MoneyTransactionType.transfer => Strings.fenzoTransfer,
  };

  List<Category> _matchingCategories(FinanceRecords? book) {
    if (book == null || _type == MoneyTransactionType.transfer) {
      return const <Category>[];
    }
    final CategoryKind kind = _type == MoneyTransactionType.income
        ? CategoryKind.income
        : CategoryKind.expense;
    return book.categories
        .where((Category item) => item.isActive && item.kind == kind)
        .toList();
  }

  List<Subcategory> _matchingSubcategories(FinanceRecords? book) {
    final String? categoryId = _categoryId;
    if (book == null || categoryId == null) {
      return const <Subcategory>[];
    }
    return book.subcategories
        .where(
          (Subcategory item) => item.categoryId == categoryId && item.isActive,
        )
        .toList();
  }

  void _onSaved(BuildContext context, ApiCallState<FinanceRecords> state) {
    if (state is! ApiCallSuccess<FinanceRecords>) {
      return;
    }
    context.read<GetAccountsCubit>().fGetAccounts();
    context.read<GetDashboardCubit>().fGetDashboard();
    context.pop();
  }

  String? _transferMessage() {
    if (_fromAccountId == null || _toAccountId == null) {
      return Strings.fenzoTransferAccountMissing;
    }
    if (_fromAccountId == _toAccountId) {
      return Strings.fenzoTransferSameAccount;
    }
    final ApiCallState<AccountListData> state = context
        .read<GetAccountsCubit>()
        .state;
    if (state is! ApiCallSuccess<AccountListData>) {
      return Strings.fenzoTransferAccountMissing;
    }
    final Iterable<Account> chosen = state.data.records.accounts.where(
      (Account account) =>
          account.id == _fromAccountId || account.id == _toAccountId,
    );
    if (chosen.length < 2 ||
        chosen.any((Account account) => !account.isActive)) {
      return Strings.fenzoTransferAccountMissing;
    }
    return null;
  }

  bool _dateIsBeforeOpening() {
    final ApiCallState<AccountListData> state = context
        .read<GetAccountsCubit>()
        .state;
    if (state is! ApiCallSuccess<AccountListData>) {
      return false;
    }
    bool earlierThan(String? accountId) {
      if (accountId == null) {
        return false;
      }
      final Iterable<Account> matches = state.data.records.accounts.where(
        (Account account) => account.id == accountId,
      );
      if (matches.isEmpty) {
        return false;
      }
      return _date.isBefore(matches.first.openingDate);
    }

    if (_type == MoneyTransactionType.transfer) {
      return earlierThan(_fromAccountId) || earlierThan(_toAccountId);
    }
    return earlierThan(_accountId);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _date = CalendarDate.fromDateTime(picked));
  }

  void _save() {
    final Either<Failure, Money> parsed = Money.parse(
      _amount.text,
      allowNegative: false,
      allowZero: false,
    );
    final String? amountMessage = parsed.fold(
      (Failure failure) => _validationCopy(failure.message),
      (_) => null,
    );
    if (amountMessage != null) {
      setState(() => _message = amountMessage);
      return;
    }
    if (_dateIsBeforeOpening()) {
      setState(() => _message = Strings.fenzoDateBeforeOpening);
      return;
    }
    setState(() => _message = null);
    final Money money = parsed.rightOrNull!;
    final String? notes = _notes.text.trim().isEmpty
        ? null
        : _notes.text.trim();
    final MoneyTransaction? existing = widget.existing;
    if (existing != null) {
      context.read<UpdateTransactionCubit>().fUpdateTransaction(
        UpdateTransactionParams(
          id: existing.id,
          type: existing.type,
          amountMinor: money.minor,
          date: _date,
          accountId: _accountId,
          categoryId: _categoryId,
          subcategoryId: _subcategoryId,
          fromAccountId: _fromAccountId,
          toAccountId: _toAccountId,
          notes: notes,
        ),
      );
      return;
    }
    switch (_type) {
      case MoneyTransactionType.income:
        if (_accountId == null || _categoryId == null) {
          return;
        }
        context.read<SaveIncomeCubit>().fSaveIncome(
          SaveIncomeParams(
            amountMinor: money.minor,
            date: _date,
            accountId: _accountId,
            categoryId: _categoryId,
            subcategoryId: _subcategoryId,
            notes: notes,
          ),
        );
      case MoneyTransactionType.expense:
        if (_accountId == null || _categoryId == null) {
          return;
        }
        context.read<SaveExpenseCubit>().fSaveExpense(
          SaveExpenseParams(
            amountMinor: money.minor,
            date: _date,
            accountId: _accountId,
            categoryId: _categoryId,
            subcategoryId: _subcategoryId,
            notes: notes,
          ),
        );
      case MoneyTransactionType.transfer:
        {
          final String? transferMessage = _transferMessage();
          if (transferMessage != null) {
            setState(() => _message = transferMessage);
            return;
          }
          context.read<SaveTransferCubit>().fSaveTransfer(
            SaveTransferParams(
              amountMinor: money.minor,
              date: _date,
              fromAccountId: _fromAccountId,
              toAccountId: _toAccountId,
              notes: notes,
            ),
          );
        }
    }
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.type,
    required this.typeLocked,
    required this.amount,
    required this.notes,
    required this.date,
    required this.accounts,
    required this.categories,
    required this.subcategories,
    required this.accountId,
    required this.categoryId,
    required this.subcategoryId,
    required this.fromAccountId,
    required this.toAccountId,
    required this.onTypeChanged,
    required this.onAccountChanged,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onPickDate,
    required this.onSave,
    required this.message,
  });

  final MoneyTransactionType type;
  final bool typeLocked;
  final TextEditingController amount;
  final TextEditingController notes;
  final CalendarDate date;
  final List<Account> accounts;
  final List<Category> categories;
  final List<Subcategory> subcategories;
  final String? accountId;
  final String? categoryId;
  final String? subcategoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final ValueChanged<MoneyTransactionType> onTypeChanged;
  final ValueChanged<String?> onAccountChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onSubcategoryChanged;
  final ValueChanged<String?> onFromChanged;
  final ValueChanged<String?> onToChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSave;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: <Widget>[
        if (message != null)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(message!, style: TextStyles.of(size: 14)),
          ),
        FinanceMenuField<MoneyTransactionType>(
          value: type,
          items: MoneyTransactionType.values
              .map(
                (MoneyTransactionType item) =>
                    DropdownMenuItem<MoneyTransactionType>(
                      value: item,
                      child: Text(
                        _movementLabel(item),
                        style: TextStyles.of(size: 16),
                      ),
                    ),
              )
              .toList(),
          onChanged: typeLocked
              ? null
              : (MoneyTransactionType? value) {
                  if (value != null) {
                    onTypeChanged(value);
                  }
                },
        ),
        SizedBox(height: 12.h),
        AppTextFormField(
          controller: amount,
          labelText: Strings.fenzoAmount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 12.h),
        if (type == MoneyTransactionType.transfer) ...<Widget>[
          _accountDropdown(
            label: Strings.fenzoFromAccount,
            value: fromAccountId,
            onChanged: onFromChanged,
          ),
          SizedBox(height: 12.h),
          _accountDropdown(
            label: Strings.fenzoToAccount,
            value: toAccountId,
            onChanged: onToChanged,
          ),
        ] else ...<Widget>[
          _accountDropdown(
            label: Strings.fenzoAccount,
            value: accountId,
            onChanged: onAccountChanged,
          ),
          SizedBox(height: 12.h),
          AppDropdown<String>(
            value: categoryId,
            values: categories.map((Category item) => item.id).toList(),
            names: categories.map((Category item) => item.name).toList(),
            hintText: Strings.fenzoCategory,
            labelText: Strings.fenzoCategory,
            onChanged: onCategoryChanged,
          ),
          SizedBox(height: 12.h),
          AppDropdown<String>(
            value: subcategoryId,
            values: subcategories.map((Subcategory item) => item.id).toList(),
            names: subcategories.map((Subcategory item) => item.name).toList(),
            hintText: Strings.fenzoSubcategory,
            labelText: Strings.fenzoSubcategory,
            isOptional: true,
            onChanged: onSubcategoryChanged,
          ),
        ],
        FinanceLedgerRow(
          title: Strings.fenzoDate,
          subtitle: date.toIso(),
          onTap: onPickDate,
        ),
        AppTextFormField(controller: notes, labelText: Strings.fenzoNotes),
        SizedBox(height: 16.h),
        AppElevatedButton(text: Strings.fenzoSave, onPressed: onSave),
      ],
    );
  }

  Widget _accountDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return AppDropdown<String>(
      value: value,
      values: accounts.map((Account item) => item.id).toList(),
      names: accounts.map((Account item) => item.name).toList(),
      hintText: label,
      labelText: label,
      onChanged: onChanged,
    );
  }
}

String _validationCopy(String? code) => switch (code) {
  'amount_scale' => Strings.fenzoAmountScale,
  'amount_positive' => Strings.fenzoAmountPositive,
  _ => Strings.fenzoAmountInvalid,
};

String _movementLabel(MoneyTransactionType type) => switch (type) {
  MoneyTransactionType.income => Strings.fenzoIncome,
  MoneyTransactionType.expense => Strings.fenzoExpense,
  MoneyTransactionType.transfer => Strings.fenzoTransfer,
};
