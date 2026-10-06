import 'package:field_validator/field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/finance_ledger.dart';
import '../../../../shared/widgets/finance_menu_field.dart';
import '../../../dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../domain/entities/account_list_data.dart';
import '../../domain/usecases/save_account_use_case.dart';
import '../controller/get_accounts/get_accounts_cubit.dart';
import '../controller/save_account/save_account_cubit.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({this.existing, super.key});

  final Account? existing;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _amount = TextEditingController(
    text: Money(widget.existing?.openingBalanceMinor ?? 0).format(),
  );
  late final TextEditingController _bankName = TextEditingController(
    text: widget.existing?.bankName ?? '',
  );
  late final TextEditingController _accountNumber = TextEditingController(
    text: widget.existing?.accountNumber ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.existing?.phoneNumber ?? '',
  );
  late AccountType _type = widget.existing?.type ?? AccountType.cash;
  late CalendarDate _openingDate =
      widget.existing?.openingDate ?? CalendarDate.today();
  late bool _includeInTotal = widget.existing?.includeInTotal ?? true;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _bankName.dispose();
    _accountNumber.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool typeLocked = _typeIsLocked(context);
    return BlocListener<SaveAccountCubit, ApiCallState<FinanceRecords>>(
      listener: (BuildContext context, ApiCallState<FinanceRecords> state) {
        if (state is ApiCallError<FinanceRecords> &&
            state.message == 'opening_date_blocked') {
          setState(() => _message = _blockingMessage());
          return;
        }
        if (state is! ApiCallSuccess<FinanceRecords>) {
          return;
        }
        context.read<GetAccountsCubit>().fGetAccounts();
        context.read<GetDashboardCubit>().fGetDashboard();
        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.fenzoAddAccount,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.w),
          children: <Widget>[
            AppTextFormField(
              controller: _name,
              labelText: Strings.fenzoName,
              validatorType: const EmptyValidator(),
            ),
            SizedBox(height: 12.h),
            FinanceMenuField<AccountType>(
              value: _type,
              label: Strings.fenzoAccount,
              items: AccountType.values
                  .map(
                    (AccountType type) => DropdownMenuItem<AccountType>(
                      value: type,
                      child: Text(
                        _accountTypeLabel(type),
                        style: TextStyles.of(size: 16),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: typeLocked
                  ? null
                  : (AccountType? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _type = value;
                        if (value != AccountType.bank) {
                          _bankName.clear();
                          _accountNumber.clear();
                        }
                        if (value != AccountType.eWallet) {
                          _phone.clear();
                        }
                      });
                    },
            ),
            if (typeLocked)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  Strings.fenzoTypeLocked,
                  style: TextStyles.of(size: 14),
                ),
              ),
            if (_type == AccountType.bank) ...<Widget>[
              SizedBox(height: 12.h),
              AppTextFormField(
                controller: _bankName,
                labelText: Strings.fenzoBankName,
              ),
              SizedBox(height: 12.h),
              AppTextFormField(
                controller: _accountNumber,
                labelText: Strings.fenzoAccountNumber,
              ),
            ],
            if (_type == AccountType.eWallet) ...<Widget>[
              SizedBox(height: 12.h),
              AppTextFormField(
                controller: _phone,
                labelText: Strings.fenzoPhone,
                keyboardType: TextInputType.phone,
              ),
            ],
            SizedBox(height: 12.h),
            AppTextFormField(
              controller: _amount,
              labelText: Strings.fenzoAmount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            SizedBox(height: 12.h),
            FinanceLedgerRow(
              title: Strings.fenzoOpeningDate,
              subtitle: _openingDate.toIso(),
              onTap: _pickOpeningDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                Strings.fenzoIncludeInTotal,
                style: TextStyles.of(size: 16),
              ),
              value: _includeInTotal,
              onChanged: (bool value) =>
                  setState(() => _includeInTotal = value),
            ),
            if (_message != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(_message!, style: TextStyles.of(size: 14)),
              ),
            SizedBox(height: 16.h),
            AppElevatedButton(text: Strings.fenzoSave, onPressed: _save),
          ],
        ),
      ),
    );
  }

  bool _typeIsLocked(BuildContext context) {
    final Account? existing = widget.existing;
    if (existing == null) {
      return false;
    }
    final ApiCallState<AccountListData> state = context
        .watch<GetAccountsCubit>()
        .state;
    if (state is! ApiCallSuccess<AccountListData>) {
      return false;
    }
    return state.data.records.transactions.any(
      (MoneyTransaction item) =>
          item.accountId == existing.id ||
          item.fromAccountId == existing.id ||
          item.toAccountId == existing.id,
    );
  }

  Future<void> _pickOpeningDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _openingDate.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _openingDate = CalendarDate.fromDateTime(picked));
  }

  List<MoneyTransaction> _blockingTransactions() {
    final Account? existing = widget.existing;
    if (existing == null) {
      return const <MoneyTransaction>[];
    }
    final ApiCallState<AccountListData> state = context
        .read<GetAccountsCubit>()
        .state;
    if (state is! ApiCallSuccess<AccountListData>) {
      return const <MoneyTransaction>[];
    }
    return state.data.records.transactions
        .where(
          (MoneyTransaction item) =>
              (item.accountId == existing.id ||
                  item.fromAccountId == existing.id ||
                  item.toAccountId == existing.id) &&
              item.date.isBefore(_openingDate),
        )
        .toList();
  }

  String _blockingMessage() {
    final String lines = _blockingTransactions()
        .map(
          (MoneyTransaction item) =>
              '${item.date.toIso()} ${Money(item.amountMinor).format()}',
        )
        .join('\n');
    return '${Strings.fenzoOpeningDateBlocked}\n$lines';
  }

  void _save() {
    final List<MoneyTransaction> blocking = _blockingTransactions();
    if (blocking.isNotEmpty &&
        widget.existing != null &&
        _openingDate != widget.existing!.openingDate) {
      setState(() => _message = _blockingMessage());
      return;
    }
    final Money? money = Money.parse(
      _amount.text,
      allowNegative: true,
      allowZero: true,
    ).rightOrNull;
    if (money == null || _name.text.trim().isEmpty) {
      return;
    }
    context.read<SaveAccountCubit>().fSaveAccount(
      SaveAccountParams(
        id: widget.existing?.id,
        name: _name.text.trim(),
        type: _type,
        openingBalanceMinor: money.minor,
        openingDate: _openingDate,
        includeInTotal: _includeInTotal,
        bankName: _blankToNull(_bankName.text),
        accountNumber: _blankToNull(_accountNumber.text),
        phoneNumber: _blankToNull(_phone.text),
      ),
    );
  }
}

String? _blankToNull(String value) {
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _accountTypeLabel(AccountType type) => switch (type) {
  AccountType.bank => Strings.fenzoBank,
  AccountType.eWallet => Strings.fenzoWallet,
  AccountType.cash => Strings.fenzoCash,
  AccountType.other => Strings.fenzoOther,
};
