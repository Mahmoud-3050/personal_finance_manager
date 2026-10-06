import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';

abstract interface class TransactionsRepository {
  Future<Either<Failure, FinanceRecords>> load();

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
  });

  Future<Either<Failure, FinanceRecords>> deleteTransaction(String id);
}
