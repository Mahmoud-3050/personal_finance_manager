import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/database/finance_command.dart';
import '../../../../core/database/finance_store.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/domain/services/balance_calculator.dart';
import '../../../../shared/domain/services/report_calculator.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/repositories/reports_repository.dart';
import '../models/report_data_model.dart';

class ReportsRepositoryImpl
    with RepositoryGuard, FinanceCommand
    implements ReportsRepository {
  ReportsRepositoryImpl(this.financeStore);

  @override
  final FinanceStore financeStore;

  @override
  Future<Either<Failure, ReportData>> getReport({
    required DateRange range,
  }) async {
    final Either<Failure, FinanceRecords> loaded = await readRecords(
      'getReport',
    );
    return loaded.map((FinanceRecords book) {
      return ReportDataModel(
        figures: periodFigures(
          range: range,
          accounts: book.accounts,
          categories: book.categories,
          subcategories: book.subcategories,
          transactions: book.transactions,
        ),
        totalMoneyMinor: totalMoneyMinor(book.accounts, book.transactions),
      );
    });
  }
}
