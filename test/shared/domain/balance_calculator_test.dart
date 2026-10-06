import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/services/balance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 6);
  final Account bank = Account(
    id: 'bank',
    name: 'Bank',
    type: AccountType.bank,
    openingBalanceMinor: 2500000,
    openingDate: const CalendarDate(2026, 10, 1),
    isActive: true,
    includeInTotal: true,
    createdAt: now,
    updatedAt: now,
  );
  final Account wallet = Account(
    id: 'wallet',
    name: 'Wallet',
    type: AccountType.eWallet,
    openingBalanceMinor: 0,
    openingDate: const CalendarDate(2026, 10, 1),
    isActive: true,
    includeInTotal: true,
    createdAt: now,
    updatedAt: now,
  );

  test('opening balance is not income and a transfer does not change total money', () {
    expect(accountBalanceMinor(bank, const <MoneyTransaction>[]), 2500000);
    final MoneyTransaction transfer = MoneyTransaction(
      id: 't1',
      type: MoneyTransactionType.transfer,
      amountMinor: 100000,
      date: const CalendarDate(2026, 10, 2),
      fromAccountId: 'bank',
      toAccountId: 'wallet',
      createdAt: now,
      updatedAt: now,
    );
    expect(accountBalanceMinor(bank, <MoneyTransaction>[transfer]), 2400000);
    expect(accountBalanceMinor(wallet, <MoneyTransaction>[transfer]), 100000);
    expect(
      totalMoneyMinor(<Account>[bank, wallet], <MoneyTransaction>[transfer]),
      2500000,
    );
  });
}
