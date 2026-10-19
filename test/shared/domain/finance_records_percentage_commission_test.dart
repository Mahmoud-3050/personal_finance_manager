import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 6);
  const CalendarDate date = CalendarDate(2026, 10, 2);

  FinanceRecords twoAccounts() {
    return FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: const CalendarDate(2026, 10, 1),
          includeInTotal: true,
          now: DateTime(2026, 10, 6, 1),
        )
        .rightOrNull!
        .saveAccount(
          id: null,
          name: 'Wallet',
          type: AccountType.eWallet,
          openingBalanceMinor: 0,
          openingDate: const CalendarDate(2026, 10, 1),
          includeInTotal: true,
          now: DateTime(2026, 10, 6, 2),
        )
        .rightOrNull!;
  }

  test('1% of 1000 EGP stores percentage basis, rate 100, and 10 EGP', () {
    final FinanceRecords book = twoAccounts();
    final Either<Failure, FinanceRecords> saved = book.saveMovement(
      id: null,
      type: MoneyTransactionType.transfer,
      amountMinor: 100000,
      date: date,
      now: now,
      fromAccountId: book.accounts.first.id,
      toAccountId: book.accounts.last.id,
      commissionBasis: CommissionBasis.percentage,
      commissionRateMinor: 100,
      commissionMinor: 999999,
    );
    final MoneyTransaction row = saved.rightOrNull!.transactions.single;
    expect(row.commissionBasis, CommissionBasis.percentage);
    expect(row.commissionRateMinor, 100);
    expect(row.commissionMinor, 1000);
  });

  test('changing only the moved amount recalculates a percentage fee', () {
    final FinanceRecords book = twoAccounts();
    final FinanceRecords withFee = book
        .saveMovement(
          id: null,
          type: MoneyTransactionType.transfer,
          amountMinor: 100000,
          date: date,
          now: now,
          fromAccountId: book.accounts.first.id,
          toAccountId: book.accounts.last.id,
          commissionBasis: CommissionBasis.percentage,
          commissionRateMinor: 100,
        )
        .rightOrNull!;
    final String id = withFee.transactions.single.id;
    final MoneyTransaction row = withFee
        .saveMovement(
          id: id,
          type: MoneyTransactionType.transfer,
          amountMinor: 50000,
          date: date,
          now: DateTime(2026, 10, 6, 3),
          fromAccountId: book.accounts.first.id,
          toAccountId: book.accounts.last.id,
          commissionBasis: CommissionBasis.percentage,
          commissionRateMinor: 100,
        )
        .rightOrNull!
        .transactions
        .single;
    expect(row.commissionRateMinor, 100);
    expect(row.commissionMinor, 500);
  });

  test('a fixed transfer keeps its typed fee when the amount changes', () {
    final FinanceRecords book = twoAccounts();
    final FinanceRecords withFee = book
        .saveMovement(
          id: null,
          type: MoneyTransactionType.transfer,
          amountMinor: 100000,
          date: date,
          now: now,
          fromAccountId: book.accounts.first.id,
          toAccountId: book.accounts.last.id,
          commissionMinor: 500,
        )
        .rightOrNull!;
    final String id = withFee.transactions.single.id;
    final MoneyTransaction row = withFee
        .saveMovement(
          id: id,
          type: MoneyTransactionType.transfer,
          amountMinor: 200000,
          date: date,
          now: DateTime(2026, 10, 6, 3),
          fromAccountId: book.accounts.first.id,
          toAccountId: book.accounts.last.id,
          commissionMinor: 500,
        )
        .rightOrNull!
        .transactions
        .single;
    expect(row.commissionBasis, CommissionBasis.fixed);
    expect(row.commissionRateMinor, 0);
    expect(row.commissionMinor, 500);
  });

  test('a percentage on an expense or income is rejected', () {
    final FinanceRecords book = twoAccounts();
    final String foodId = book.categories
        .firstWhere((category) => category.name == 'طعام')
        .id;
    final Either<Failure, FinanceRecords> expense = book.saveMovement(
      id: null,
      type: MoneyTransactionType.expense,
      amountMinor: 20000,
      date: date,
      now: now,
      accountId: book.accounts.first.id,
      categoryId: foodId,
      commissionBasis: CommissionBasis.percentage,
      commissionRateMinor: 100,
    );
    expect(expense.leftOrNull, isA<ValidationFailure>());
    expect(book.transactions, isEmpty);
  });

  test('a blank rate stores commission zero', () {
    final FinanceRecords book = twoAccounts();
    final MoneyTransaction row = book
        .saveMovement(
          id: null,
          type: MoneyTransactionType.transfer,
          amountMinor: 100000,
          date: date,
          now: now,
          fromAccountId: book.accounts.first.id,
          toAccountId: book.accounts.last.id,
          commissionBasis: CommissionBasis.percentage,
        )
        .rightOrNull!
        .transactions
        .single;
    expect(row.commissionMinor, 0);
    expect(row.commissionBasis, CommissionBasis.percentage);
  });

  test('a negative rate is rejected', () {
    final FinanceRecords book = twoAccounts();
    final Either<Failure, FinanceRecords> saved = book.saveMovement(
      id: null,
      type: MoneyTransactionType.transfer,
      amountMinor: 100000,
      date: date,
      now: now,
      fromAccountId: book.accounts.first.id,
      toAccountId: book.accounts.last.id,
      commissionBasis: CommissionBasis.percentage,
      commissionRateMinor: -1,
    );
    expect(saved.leftOrNull, isA<ValidationFailure>());
    expect(book.transactions, isEmpty);
  });

  test('a fixed basis forces the rate to zero', () {
    final FinanceRecords book = twoAccounts();
    final MoneyTransaction row = book
        .saveMovement(
          id: null,
          type: MoneyTransactionType.transfer,
          amountMinor: 100000,
          date: date,
          now: now,
          fromAccountId: book.accounts.first.id,
          toAccountId: book.accounts.last.id,
          commissionMinor: 500,
          commissionRateMinor: 100,
        )
        .rightOrNull!
        .transactions
        .single;
    expect(row.commissionBasis, CommissionBasis.fixed);
    expect(row.commissionRateMinor, 0);
    expect(row.commissionMinor, 500);
  });
}
