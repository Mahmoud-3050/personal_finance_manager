import 'package:either/either.dart';

import '../data/repository_guard.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../../shared/domain/finance_records.dart';
import 'finance_store.dart';

mixin FinanceCommand on RepositoryGuard {
  FinanceStore get financeStore;

  Future<Either<Failure, FinanceRecords>> changeRecords(
    String operation,
    Either<Failure, FinanceRecords> Function(FinanceRecords records) change,
  ) {
    return guard(() async {
      final FinanceRecords current = await financeStore.load();
      final Either<Failure, FinanceRecords> next = change(current);
      if (next.isLeft) {
        throw ValidationException(message: next.leftOrNull?.message);
      }
      final FinanceRecords saved = next.rightOrNull!;
      await financeStore.save(saved);
      return saved;
    }, operation);
  }

  Future<Either<Failure, FinanceRecords>> readRecords(String operation) {
    return guard(() async {
      final FinanceRecords records = await financeStore.load();
      await financeStore.save(records);
      return records;
    }, operation);
  }
}
