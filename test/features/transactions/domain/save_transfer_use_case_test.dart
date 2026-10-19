import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_transfer_use_case.dart';
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
    CommissionBasis commissionBasis = CommissionBasis.fixed,
    int commissionRateMinor = 0,
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
      commissionBasis: commissionBasis,
      commissionRateMinor: commissionRateMinor,
    );
    return next.map((FinanceRecords value) {
      book = value;
      return value;
    });
  }
}

void main() {
  test('save transfer passes the commission through', () async {
    final DateTime now = DateTime(2026, 10, 6);
    FinanceRecords book = FinanceRecords.empty().seedIfNeeded(now);
    book = book
        .saveAccount(
          id: null,
          name: 'Cash',
          type: AccountType.cash,
          openingBalanceMinor: 200000,
          openingDate: const CalendarDate(2026, 10, 1),
          includeInTotal: true,
          now: DateTime(2026, 10, 6, 1),
        )
        .rightOrNull!;
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
    final FinanceRecords saved = (await SaveTransferUseCase(_Repo(book))(
      SaveTransferParams(
        amountMinor: 100000,
        date: const CalendarDate(2026, 10, 2),
        fromAccountId: book.accounts.first.id,
        toAccountId: book.accounts.last.id,
        commissionMinor: 500,
      ),
    )).rightOrNull!;
    expect(saved.transactions.single.commissionMinor, 500);
  });
}
