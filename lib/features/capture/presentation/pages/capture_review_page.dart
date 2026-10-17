import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/finance_menu_field.dart';
import '../../../accounts/domain/entities/account_list_data.dart';
import '../../../accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import '../../../categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../../dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../../transactions/presentation/controller/search_transactions/search_transactions_cubit.dart';
import '../../domain/entities/capture_draft.dart';
import '../controller/confirm_capture_draft/confirm_capture_draft_cubit.dart';
import '../controller/discard_capture_draft/discard_capture_draft_cubit.dart';
import '../widgets/capture_uncertain_mark.dart';

class CaptureReviewPage extends StatefulWidget {
  const CaptureReviewPage({this.supplied, super.key});

  final CaptureDraft? supplied;

  @override
  State<CaptureReviewPage> createState() => _CaptureReviewPageState();
}

class _CaptureReviewPageState extends State<CaptureReviewPage> {
  late CaptureDraft _draft = widget.supplied ?? CaptureDraft.handStarted();
  late final TextEditingController _amount = TextEditingController(
    text: _draft.amountMinor == null ? '' : Money(_draft.amountMinor!).format(),
  );
  late final TextEditingController _notes = TextEditingController(
    text: _draft.notes ?? '',
  );
  late final TextEditingController _commission = TextEditingController(
    text: _openingCommissionText(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<GetAccountsCubit>().fGetAccounts();
      context.read<GetCategoriesCubit>().fGetCategories();
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    _commission.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<ConfirmCaptureDraftCubit, ConfirmCaptureDraftState>(
          listener: _onConfirm,
        ),
        BlocListener<DiscardCaptureDraftCubit, DiscardCaptureDraftState>(
          listener: _onDiscard,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.fenzoCaptureReview,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: BlocBuilder<GetAccountsCubit, GetAccountsState>(
          builder: (BuildContext context, GetAccountsState accountsState) {
            return BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
              builder:
                  (BuildContext context, GetCategoriesState categoriesState) {
                    final List<Account> accounts = _activeAccounts(
                      accountsState,
                    );
                    if (accountsState is! ApiCallSuccess<AccountListData>) {
                      return _accountsPending(accountsState);
                    }
                    if (accounts.isEmpty) {
                      return _noAccounts();
                    }
                    final FinanceRecords? book = _book(categoriesState);
                    return ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                      children: <Widget>[
                        _KindField(
                          kind: _draft.kind,
                          onChanged: (CaptureKind kind) =>
                              _changeKind(kind, book, accounts),
                        ),
                        SizedBox(height: 12.h),
                        _labeled(
                          Strings.fenzoAmount,
                          CaptureField.amount,
                          AppTextFormField(
                            controller: _amount,
                            labelText: Strings.fenzoAmount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _labeled(
                          Strings.fenzoDate,
                          CaptureField.date,
                          TextButton(
                            key: const Key('capture-date'),
                            onPressed: _pickDate,
                            child: Text(_draft.date.toIso()),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _labeled(
                          Strings.fenzoAccount,
                          CaptureField.account,
                          FinanceMenuField<String?>(
                            label: Strings.fenzoAccount,
                            value: _selectedId(accounts, _draft.accountId),
                            items: <DropdownMenuItem<String?>>[
                              for (final Account account in accounts)
                                DropdownMenuItem<String?>(
                                  value: account.id,
                                  child: Text(account.name),
                                ),
                            ],
                            onChanged: (String? id) =>
                                _changeAccount(id, accounts),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _labeled(
                          Strings.fenzoCategory,
                          CaptureField.category,
                          FinanceMenuField<String?>(
                            label: Strings.fenzoCategory,
                            value: _selectedCategoryId(book),
                            items: <DropdownMenuItem<String?>>[
                              for (final Category category in _categories(book))
                                DropdownMenuItem<String?>(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                            ],
                            onChanged: _changeCategory,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _labeled(
                          Strings.fenzoSubcategory,
                          CaptureField.subcategory,
                          FinanceMenuField<String?>(
                            label: Strings.fenzoSubcategory,
                            value: _selectedSubcategoryId(book),
                            items: <DropdownMenuItem<String?>>[
                              for (final Subcategory child in _subcategories(
                                book,
                              ))
                                DropdownMenuItem<String?>(
                                  value: child.id,
                                  child: Text(child.name),
                                ),
                            ],
                            onChanged: (String? id) {
                              setState(() {
                                _draft = id == null
                                    ? _draft.copyWith(clearSubcategory: true)
                                    : _draft.copyWith(subcategoryId: id);
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _labeled(
                          Strings.fenzoNotes,
                          CaptureField.notes,
                          AppTextFormField(
                            controller: _notes,
                            labelText: Strings.fenzoNotes,
                          ),
                        ),
                        if (_draft.feeApplies) ...<Widget>[
                          SizedBox(height: 12.h),
                          _labeled(
                            Strings.fenzoTransferCommission,
                            CaptureField.commission,
                            AppTextFormField(
                              key: const Key('capture-fee'),
                              controller: _commission,
                              labelText: Strings.fenzoTransferCommission,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                        SizedBox(height: 24.h),
                        AppElevatedButton(
                          text: Strings.fenzoCaptureConfirm,
                          onPressed: _confirm,
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () => context
                              .read<DiscardCaptureDraftCubit>()
                              .fDiscardCaptureDraft(),
                          child: Text(Strings.fenzoCaptureDiscard),
                        ),
                      ],
                    );
                  },
            );
          },
        ),
      ),
    );
  }

  Widget _labeled(String label, CaptureField field, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TextStyles.of(size: 14, weight: FontWeight.w600)),
        if (_draft.uncertainFields.contains(field))
          CaptureUncertainMark(field: field),
        child,
      ],
    );
  }

  String _openingCommissionText() {
    final int? fee = _draft.commissionMinor;
    if (!_draft.feeApplies || fee == null || fee == 0) {
      return '';
    }
    return Money(fee).format();
  }

  Future<void> _onConfirm(
    BuildContext context,
    ConfirmCaptureDraftState state,
  ) async {
    if (state is ApiCallSuccess<FinanceRecords>) {
      final SearchTransactionsCubit search = context
          .read<SearchTransactionsCubit>();
      final GetAccountsCubit accounts = context.read<GetAccountsCubit>();
      final GetDashboardCubit dashboard = context.read<GetDashboardCubit>();
      await search.fRepeatLastSearch();
      await accounts.fGetAccounts();
      await dashboard.fGetDashboard();
      if (context.mounted) {
        context.pop();
      }
      return;
    }
    if (state is ApiCallError<FinanceRecords>) {
      _showMessage(captureFailureCopy(state.message));
    }
  }

  void _onDiscard(BuildContext context, DiscardCaptureDraftState state) {
    if (state is ApiCallSuccess<bool>) {
      context.pop();
      return;
    }
    if (state is ApiCallError<bool>) {
      _showMessage(captureFailureCopy(state.message));
    }
  }

  Widget _accountsPending(GetAccountsState state) {
    if (state is ApiCallError<AccountListData>) {
      return Center(child: Text(captureFailureCopy(state.message)));
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _noAccounts() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(Strings.fenzoEmpty, style: TextStyles.of(size: 16)),
      ),
    );
  }

  void _showMessage(String message) {
    showAppSnackBar(context: context, message: message, type: ToastType.error);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _draft.date.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _draft = _draft.copyWith(date: CalendarDate.fromDateTime(picked));
    });
  }

  void _changeKind(
    CaptureKind kind,
    FinanceRecords? book,
    List<Account> accounts,
  ) {
    final Category? category = _category(book);
    final bool keepCategory =
        category != null && category.kind.name == kind.name;
    setState(() {
      _draft = _draft.changeKind(kind: kind, keepCategory: keepCategory);
      _draft = _draft.changeAccount(_account(accounts));
      _commission.text = _openingCommissionText();
    });
  }

  void _changeAccount(String? id, List<Account> accounts) {
    Account? account;
    for (final Account item in accounts) {
      if (item.id == id) {
        account = item;
      }
    }
    setState(() {
      _draft = _draft.changeAccount(account);
      _commission.text = _openingCommissionText();
    });
  }

  void _changeCategory(String? id) {
    setState(() {
      if (id == null) {
        _draft = _draft.copyWith(clearCategory: true, clearSubcategory: true);
        return;
      }
      _draft = _draft.copyWith(categoryId: id, clearSubcategory: true);
    });
  }

  Future<void> _confirm() async {
    final ({int? minor, String? failure}) amount = _parseAmount(_amount.text);
    if (amount.failure != null) {
      _showMessage(amount.failure!);
      return;
    }
    final ({int? minor, String? failure}) fee = _parseFee();
    if (fee.failure != null) {
      _showMessage(fee.failure!);
      return;
    }
    final String notes = _notes.text.trim();
    final CaptureDraft draft = _draft.copyWith(
      amountMinor: amount.minor,
      notes: notes,
      clearNotes: notes.isEmpty,
      commissionMinor: fee.minor,
      clearCommission: !_draft.feeApplies,
    );
    setState(() => _draft = draft);
    await context.read<ConfirmCaptureDraftCubit>().fConfirmCaptureDraft(draft);
  }

  ({int? minor, String? failure}) _parseAmount(String raw) {
    final parsed = Money.parse(raw, allowNegative: false, allowZero: false);
    return parsed.fold(
      (failure) => (minor: null, failure: captureFailureCopy(failure.message)),
      (money) => (minor: money.minor, failure: null),
    );
  }

  ({int? minor, String? failure}) _parseFee() {
    if (!_draft.feeApplies || _commission.text.trim().isEmpty) {
      return (minor: _draft.feeApplies ? 0 : null, failure: null);
    }
    final parsed = Money.parse(
      _commission.text,
      allowNegative: false,
      allowZero: true,
    );
    return parsed.fold(
      (failure) => (minor: null, failure: captureFailureCopy(failure.message)),
      (money) => (minor: money.minor, failure: null),
    );
  }

  List<Account> _activeAccounts(GetAccountsState state) {
    if (state is! ApiCallSuccess<AccountListData>) {
      return const <Account>[];
    }
    return state.data.records.accounts
        .where((Account account) => account.isActive)
        .toList();
  }

  FinanceRecords? _book(GetCategoriesState state) {
    if (state is! ApiCallSuccess<FinanceRecords>) {
      return null;
    }
    return state.data;
  }

  List<Category> _categories(FinanceRecords? book) {
    if (book == null) {
      return const <Category>[];
    }
    final CategoryKind kind = _draft.kind == CaptureKind.income
        ? CategoryKind.income
        : CategoryKind.expense;
    return book.categories
        .where(
          (Category category) =>
              category.isActive &&
              category.kind == kind &&
              category.id != transferCommissionCategoryId,
        )
        .toList();
  }

  List<Subcategory> _subcategories(FinanceRecords? book) {
    final String? categoryId = _draft.categoryId;
    if (book == null || categoryId == null) {
      return const <Subcategory>[];
    }
    return book.subcategories
        .where(
          (Subcategory child) =>
              child.isActive && child.categoryId == categoryId,
        )
        .toList();
  }

  Category? _category(FinanceRecords? book) {
    final String? id = _draft.categoryId;
    if (book == null || id == null) {
      return null;
    }
    for (final Category category in book.categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  Account? _account(List<Account> accounts) {
    for (final Account account in accounts) {
      if (account.id == _draft.accountId) {
        return account;
      }
    }
    return null;
  }

  String? _selectedId(List<Account> accounts, String? id) {
    if (id == null) {
      return null;
    }
    return accounts.any((Account account) => account.id == id) ? id : null;
  }

  String? _selectedCategoryId(FinanceRecords? book) {
    final String? id = _draft.categoryId;
    if (id == null) {
      return null;
    }
    return _categories(book).any((Category category) => category.id == id)
        ? id
        : null;
  }

  String? _selectedSubcategoryId(FinanceRecords? book) {
    final String? id = _draft.subcategoryId;
    if (id == null) {
      return null;
    }
    return _subcategories(book).any((Subcategory child) => child.id == id)
        ? id
        : null;
  }
}

class _KindField extends StatelessWidget {
  const _KindField({required this.kind, required this.onChanged});

  final CaptureKind kind;
  final ValueChanged<CaptureKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return FinanceMenuField<CaptureKind>(
      label: Strings.fenzoCaptureKind,
      value: kind,
      items: <DropdownMenuItem<CaptureKind>>[
        DropdownMenuItem<CaptureKind>(
          value: CaptureKind.expense,
          child: Text(Strings.fenzoExpense),
        ),
        DropdownMenuItem<CaptureKind>(
          value: CaptureKind.income,
          child: Text(Strings.fenzoIncome),
        ),
      ],
      onChanged: (CaptureKind? next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }
}

String captureFailureCopy(String? code) {
  return switch (code) {
    'amount_scale' => Strings.fenzoAmountScale,
    'amount_invalid' => Strings.fenzoAmountInvalid,
    'amount_positive' ||
    'amount_required' ||
    'commission_non_negative' => Strings.fenzoAmountPositive,
    'date_before_opening' => Strings.fenzoDateBeforeOpening,
    'commission_not_allowed' => Strings.fenzoCommissionNotAllowed,
    'account_missing' || 'account_inactive' => Strings.fenzoAccount,
    'category_invalid' => Strings.fenzoCategory,
    'subcategory_invalid' => Strings.fenzoSubcategory,
    _ => Strings.pleaseTryAgainLater,
  };
}
