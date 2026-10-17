import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_expense_use_case.dart';
import 'package:finzomanager/features/transactions/domain/usecases/update_transaction_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements TransactionsRepository {
  _Repo(this.book);

  FinanceRecords book;

  @override
  Future<Either<Failure, FinanceRecords>> load() async => Right(book);

  @override
  Future<Either<Failure, FinanceRecords>> deleteTransaction(String id) async {
    return Right(book);
  }

  @override
  Future<Either<Failure, FinanceRecords>> saveMovement({
    required String? id,
    required MoneyTransactionType type,
    required int amountMinor,
    required CalendarDate date,
    String? accountId,
    String? categoryId,
    String? subcategoryId,
    String? fromAccountId,
    String? toAccountId,
    String? description,
    String? notes,
    int commissionMinor = 0,
  }) async {
    final Either<Failure, FinanceRecords> next = book.saveMovement(
      id: id,
      type: type,
      amountMinor: amountMinor,
      date: date,
      now: DateTime(2026, 10, 6, 3),
      accountId: accountId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      description: description,
      notes: notes,
      commissionMinor: commissionMinor,
    );
    return next.map((FinanceRecords value) {
      book = value;
      return value;
    });
  }
}

void main() {
  test('save and update expense pass the commission through', () async {
    final DateTime now = DateTime(2026, 10, 6);
    final FinanceRecords opened = FinanceRecords.empty()
        .seedIfNeeded(now)
        .saveAccount(
          id: null,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 100000,
          openingDate: const CalendarDate(2026, 10, 1),
          includeInTotal: true,
          now: now,
        )
        .rightOrNull!;
    final _Repo repository = _Repo(opened);
    final String categoryId = opened.categories
        .firstWhere((category) => category.name == 'طعام')
        .id;
    final FinanceRecords saved = (await SaveExpenseUseCase(repository)(
      SaveExpenseParams(
        amountMinor: 20000,
        date: const CalendarDate(2026, 10, 2),
        accountId: opened.accounts.single.id,
        categoryId: categoryId,
        commissionMinor: 300,
      ),
    )).rightOrNull!;
    expect(saved.transactions.single.commissionMinor, 300);
    final FinanceRecords updated = (await UpdateTransactionUseCase(repository)(
      UpdateTransactionParams(
        id: saved.transactions.single.id,
        type: MoneyTransactionType.expense,
        amountMinor: 20000,
        date: const CalendarDate(2026, 10, 2),
        accountId: opened.accounts.single.id,
        categoryId: categoryId,
      ),
    )).rightOrNull!;
    expect(updated.transactions.single.commissionMinor, 0);
  });
}
