import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/category.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 6);
  const CalendarDate date = CalendarDate(2026, 10, 2);

  FinanceRecords opened(AccountType type, DateTime stamp, String name) {
    return FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: name,
          type: type,
          openingBalanceMinor: 100000,
          openingDate: const CalendarDate(2026, 10, 1),
          includeInTotal: true,
          now: stamp,
        )
        .rightOrNull!;
  }

  String foodId(FinanceRecords book) {
    return book.categories.firstWhere((category) => category.name == 'طعام').id;
  }

  String incomeId(FinanceRecords book) {
    return book.categories.firstWhere((category) => category.name == 'راتب').id;
  }

  test(
    'a blank commission is stored as zero and keeps the chosen category',
    () {
      final FinanceRecords book = opened(
        AccountType.bank,
        DateTime(2026, 10, 6, 1),
        'Bank',
      );
      final Either<Failure, FinanceRecords> saved = book.saveMovement(
        id: null,
        type: MoneyTransactionType.expense,
        amountMinor: 20000,
        date: date,
        now: now,
        accountId: book.accounts.single.id,
        categoryId: foodId(book),
      );
      final MoneyTransaction row = saved.rightOrNull!.transactions.single;
      expect(row.commissionMinor, 0);
      expect(row.categoryId, foodId(book));
    },
  );

  test('a negative commission is rejected and the book is unchanged', () {
    final FinanceRecords book = opened(
      AccountType.bank,
      DateTime(2026, 10, 6, 1),
      'Bank',
    );
    final Either<Failure, FinanceRecords> saved = book.saveMovement(
      id: null,
      type: MoneyTransactionType.expense,
      amountMinor: 20000,
      date: date,
      now: now,
      accountId: book.accounts.single.id,
      categoryId: foodId(book),
      commissionMinor: -1,
    );
    expect(saved.leftOrNull, isA<ValidationFailure>());
    expect(book.transactions, isEmpty);
  });

  test('a commission larger than the principal is allowed', () {
    final FinanceRecords book = opened(
      AccountType.bank,
      DateTime(2026, 10, 6, 1),
      'Bank',
    );
    final Either<Failure, FinanceRecords> saved = book.saveMovement(
      id: null,
      type: MoneyTransactionType.expense,
      amountMinor: 100,
      date: date,
      now: now,
      accountId: book.accounts.single.id,
      categoryId: foodId(book),
      commissionMinor: 500,
    );
    expect(saved.rightOrNull!.transactions.single.commissionMinor, 500);
  });

  test(
    'income, cash, and other reject a commission and a bank expense accepts it',
    () {
      final FinanceRecords bank = opened(
        AccountType.bank,
        DateTime(2026, 10, 6, 1),
        'Bank',
      );
      final FinanceRecords cash = opened(
        AccountType.cash,
        DateTime(2026, 10, 6, 2),
        'Cash',
      );
      final FinanceRecords other = opened(
        AccountType.other,
        DateTime(2026, 10, 6, 3),
        'Other',
      );
      expect(
        bank
            .saveMovement(
              id: null,
              type: MoneyTransactionType.income,
              amountMinor: 100,
              date: date,
              now: now,
              accountId: bank.accounts.single.id,
              categoryId: incomeId(bank),
              commissionMinor: 10,
            )
            .leftOrNull
            ?.message,
        'commission_not_allowed',
      );
      expect(
        cash
            .saveMovement(
              id: null,
              type: MoneyTransactionType.expense,
              amountMinor: 100,
              date: date,
              now: now,
              accountId: cash.accounts.single.id,
              categoryId: foodId(cash),
              commissionMinor: 10,
            )
            .leftOrNull
            ?.message,
        'commission_not_allowed',
      );
      expect(
        other
            .saveMovement(
              id: null,
              type: MoneyTransactionType.expense,
              amountMinor: 100,
              date: date,
              now: now,
              accountId: other.accounts.single.id,
              categoryId: foodId(other),
              commissionMinor: 10,
            )
            .leftOrNull
            ?.message,
        'commission_not_allowed',
      );
      expect(bank.transactions, isEmpty);
      expect(cash.transactions, isEmpty);
      expect(other.transactions, isEmpty);
      final FinanceRecords wallet = opened(
        AccountType.eWallet,
        DateTime(2026, 10, 6, 4),
        'Wallet',
      );
      expect(
        wallet
            .saveMovement(
              id: null,
              type: MoneyTransactionType.expense,
              amountMinor: 20000,
              date: date,
              now: now,
              accountId: wallet.accounts.single.id,
              categoryId: foodId(wallet),
              commissionMinor: 300,
            )
            .rightOrNull!
            .transactions
            .single
            .commissionMinor,
        300,
      );
      final Either<Failure, FinanceRecords> accepted = bank.saveMovement(
        id: null,
        type: MoneyTransactionType.expense,
        amountMinor: 20000,
        date: date,
        now: now,
        accountId: bank.accounts.single.id,
        categoryId: foodId(bank),
        commissionMinor: 300,
      );
      expect(
        accepted.rightOrNull!.transactions.single.categoryId,
        foodId(bank),
      );
      expect(accepted.rightOrNull!.transactions.single.commissionMinor, 300);
    },
  );

  test(
    'a transfer accepts a commission and a normal expense cannot use the fee category',
    () {
      FinanceRecords book = opened(
        AccountType.cash,
        DateTime(2026, 10, 6, 1),
        'Cash',
      );
      book = book
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
      final String cashId = book.accounts.first.id;
      final String walletId = book.accounts.last.id;
      final Either<Failure, FinanceRecords> transfer = book.saveMovement(
        id: null,
        type: MoneyTransactionType.transfer,
        amountMinor: 100000,
        date: date,
        now: now,
        fromAccountId: cashId,
        toAccountId: walletId,
        commissionMinor: 500,
      );
      expect(transfer.rightOrNull!.transactions.single.commissionMinor, 500);
      expect(transfer.rightOrNull!.transactions.single.categoryId, isNull);
      expect(
        transfer.rightOrNull!
            .search(categoryId: transferCommissionCategoryId)
            .single
            .commissionMinor,
        500,
      );
      expect(
        book
            .saveMovement(
              id: null,
              type: MoneyTransactionType.expense,
              amountMinor: 100,
              date: date,
              now: now,
              accountId: walletId,
              categoryId: transferCommissionCategoryId,
            )
            .leftOrNull
            ?.message,
        'category_invalid',
      );
    },
  );

  test(
    'an existing catalog gains the fee category without renaming the others',
    () {
      const Category food = Category(
        id: 'custom-food',
        name: 'طعام الخاص',
        kind: CategoryKind.expense,
        isActive: true,
      );
      final FinanceRecords book = const FinanceRecords(
        accounts: <Account>[],
        categories: <Category>[food],
        subcategories: [],
        transactions: [],
      ).seedIfNeeded(now);
      expect(
        book.categories.map((Category item) => item.name),
        containsAll(<String>['طعام الخاص', transferCommissionCategoryName]),
      );
      expect(
        book.categories.any(
          (Category item) => item.id == transferCommissionCategoryId,
        ),
        isTrue,
      );
    },
  );
}
