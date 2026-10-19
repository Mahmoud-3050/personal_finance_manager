import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CalendarDate opening = CalendarDate(2026, 10, 1);
  const CalendarDate date = CalendarDate(2026, 10, 2);
  final DateTime now = DateTime(2026, 10, 6);

  test('blank or zero percent usual fee is fixed with amount and rate zero', () {
    final FinanceRecords blank = FinanceRecords.empty()
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
    expect(blank.accounts.single.defaultCommissionBasis, CommissionBasis.fixed);
    expect(blank.accounts.single.defaultCommissionMinor, 0);
    expect(blank.accounts.single.defaultCommissionRateMinor, 0);
    expect(blank.accounts.single.openingBalanceMinor, 2500000);

    final FinanceRecords zeroPercent = FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: 'Wallet',
          type: AccountType.eWallet,
          openingBalanceMinor: 0,
          openingDate: opening,
          includeInTotal: true,
          now: now,
          defaultCommissionBasis: CommissionBasis.percentage,
        )
        .rightOrNull!;
    expect(
      zeroPercent.accounts.single.defaultCommissionBasis,
      CommissionBasis.fixed,
    );
    expect(zeroPercent.accounts.single.defaultCommissionMinor, 0);
    expect(zeroPercent.accounts.single.defaultCommissionRateMinor, 0);
  });

  test('a 1% usual fee stores percentage basis, rate 100, and amount 0', () {
    final FinanceRecords saved = FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: 'Vodafone',
          type: AccountType.eWallet,
          openingBalanceMinor: 0,
          openingDate: opening,
          includeInTotal: true,
          now: now,
          defaultCommissionBasis: CommissionBasis.percentage,
          defaultCommissionRateMinor: 100,
          defaultCommissionMinor: 999,
        )
        .rightOrNull!;
    expect(
      saved.accounts.single.defaultCommissionBasis,
      CommissionBasis.percentage,
    );
    expect(saved.accounts.single.defaultCommissionRateMinor, 100);
    expect(saved.accounts.single.defaultCommissionMinor, 0);
    expect(saved.accounts.single.openingBalanceMinor, 0);
  });

  test('a fixed 3.00 EGP usual fee stores fixed basis, amount 300, rate 0', () {
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
          defaultCommissionMinor: 300,
          defaultCommissionRateMinor: 50,
        )
        .rightOrNull!;
    expect(saved.accounts.single.defaultCommissionBasis, CommissionBasis.fixed);
    expect(saved.accounts.single.defaultCommissionMinor, 300);
    expect(saved.accounts.single.defaultCommissionRateMinor, 0);
  });

  test('a negative rate is rejected and the book is unchanged', () {
    final FinanceRecords book = FinanceRecords.empty().seedIfNeeded(now);
    final Either<Failure, FinanceRecords> saved = book.saveAccount(
      id: null,
      name: 'Bank',
      type: AccountType.bank,
      openingBalanceMinor: 2500000,
      openingDate: opening,
      includeInTotal: true,
      now: now,
      defaultCommissionBasis: CommissionBasis.percentage,
      defaultCommissionRateMinor: -1,
    );
    expect(saved.leftOrNull, isA<ValidationFailure>());
    expect(book.accounts, isEmpty);
  });

  test('changing the usual fee does not change a saved commission', () {
    final FinanceRecords created = FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: opening,
          includeInTotal: true,
          now: now,
          defaultCommissionMinor: 300,
        )
        .rightOrNull!;
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
          defaultCommissionBasis: CommissionBasis.percentage,
          defaultCommissionRateMinor: 100,
        )
        .rightOrNull!;
    expect(
      updated.accounts.single.defaultCommissionBasis,
      CommissionBasis.percentage,
    );
    expect(updated.accounts.single.defaultCommissionRateMinor, 100);
    expect(updated.transactions.single.commissionMinor, 300);
  });
}
