import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CalendarDate opening = CalendarDate(2026, 10, 1);
  const CalendarDate date = CalendarDate(2026, 10, 2);
  final DateTime now = DateTime(2026, 10, 6);

  FinanceRecords openBank(FinanceRecords book, {int usualFee = 0}) {
    return book
        .saveAccount(
          id: null,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: opening,
          includeInTotal: true,
          now: now,
          defaultCommissionMinor: usualFee,
        )
        .rightOrNull!;
  }

  test('a blank usual fee is zero and the opening balance is unchanged', () {
    final FinanceRecords saved = FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: opening,
          includeInTotal: true,
          now: now,
        )
        .rightOrNull!;
    expect(saved.accounts.single.defaultCommissionMinor, 0);
    expect(saved.accounts.single.openingBalanceMinor, 2500000);
  });

  test('a negative usual fee is rejected and the book is unchanged', () {
    final FinanceRecords book = FinanceRecords.empty().seedIfNeeded(now);
    final Either<Failure, FinanceRecords> saved = book.saveAccount(
      id: null,
      name: 'Bank',
      type: AccountType.bank,
      openingBalanceMinor: 2500000,
      openingDate: opening,
      includeInTotal: true,
      now: now,
      defaultCommissionMinor: -1,
    );
    expect(saved.leftOrNull, isA<ValidationFailure>());
    expect(book.accounts, isEmpty);
  });

  test('changing the account type keeps the usual fee', () {
    final FinanceRecords created = openBank(
      FinanceRecords.empty().seedIfNeeded(now),
      usualFee: 300,
    );
    final FinanceRecords changed = created
        .saveAccount(
          id: created.accounts.single.id,
          name: 'Bank',
          type: AccountType.cash,
          openingBalanceMinor: 2500000,
          openingDate: opening,
          includeInTotal: true,
          now: DateTime(2026, 10, 6, 1),
          defaultCommissionMinor: 300,
        )
        .rightOrNull!;
    expect(changed.accounts.single.type, AccountType.cash);
    expect(changed.accounts.single.defaultCommissionMinor, 300);
  });

  test('changing the usual fee does not change a saved commission', () {
    final FinanceRecords created = openBank(
      FinanceRecords.empty().seedIfNeeded(now),
      usualFee: 300,
    );
    final String categoryId = created.categories
        .firstWhere((category) => category.name == 'طعام')
        .id;
    final FinanceRecords paid = created
        .saveMovement(
          id: null,
          type: MoneyTransactionType.expense,
          amountMinor: 20000,
          date: date,
          now: DateTime(2026, 10, 6, 2),
          accountId: created.accounts.single.id,
          categoryId: categoryId,
          commissionMinor: 300,
        )
        .rightOrNull!;
    final FinanceRecords updated = paid
        .saveAccount(
          id: created.accounts.single.id,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: opening,
          includeInTotal: true,
          now: DateTime(2026, 10, 6, 3),
          defaultCommissionMinor: 500,
        )
        .rightOrNull!;
    expect(updated.accounts.single.defaultCommissionMinor, 500);
    expect(updated.transactions.single.commissionMinor, 300);
  });
}
