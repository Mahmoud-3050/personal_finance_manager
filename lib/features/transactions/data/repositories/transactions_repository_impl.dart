import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/database/finance_command.dart';
import '../../../../core/database/finance_store.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../domain/repositories/transactions_repository.dart';

class TransactionsRepositoryImpl
    with RepositoryGuard, FinanceCommand
    implements TransactionsRepository {
  TransactionsRepositoryImpl(this.financeStore);

  @override
  final FinanceStore financeStore;

  @override
  Future<Either<Failure, FinanceRecords>> load() =>
      readRecords('loadTransactions');

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
  }) {
    return changeRecords(
      'saveMovement',
      (FinanceRecords records) => records.saveMovement(
        id: id,
        type: type,
        amountMinor: amountMinor,
        date: date,
        now: DateTime.now(),
        accountId: accountId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        description: description,
        notes: notes,
      ),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deleteTransaction(String id) {
    return changeRecords(
      'deleteTransaction',
      (FinanceRecords records) => records.deleteTransaction(id),
    );
  }
}
