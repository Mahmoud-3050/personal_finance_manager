import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/database/finance_command.dart';
import '../../../../core/database/finance_store.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/domain/services/balance_calculator.dart';
import '../../../../shared/domain/services/report_calculator.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_data_model.dart';

class DashboardRepositoryImpl
    with RepositoryGuard, FinanceCommand
    implements DashboardRepository {
  DashboardRepositoryImpl(this.financeStore);

  @override
  final FinanceStore financeStore;

  @override
  Future<Either<Failure, DashboardData>> getDashboard() async {
    final Either<Failure, FinanceRecords> loaded = await readRecords(
      'getDashboard',
    );
    return loaded.map((FinanceRecords book) {
      final DateRange month = CalendarDate.monthContaining(
        CalendarDate.today(),
      );
      final figures = periodFigures(
        range: month,
        accounts: book.accounts,
        categories: book.categories,
        subcategories: book.subcategories,
        transactions: book.transactions,
      );
      final List<Account> activeAccounts = book.accounts
          .where((Account item) => item.isActive)
          .toList();
      return DashboardDataModel(
        totalMoneyMinor: totalMoneyMinor(book.accounts, book.transactions),
        incomeMinor: figures.incomeMinor,
        expenseMinor: figures.expenseMinor,
        netMinor: figures.netMinor,
        accounts: activeAccounts,
        accountBalances: <String, int>{
          for (final Account account in activeAccounts)
            account.id: accountBalanceMinor(account, book.transactions),
        },
        expenseShares: figures.expenseShares,
        recent: newestTransactions(book.transactions),
      );
    });
  }
}
