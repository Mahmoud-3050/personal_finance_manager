import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/database/finance_command.dart';
import '../../../../core/database/finance_store.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../domain/repositories/accounts_repository.dart';

class AccountsRepositoryImpl
    with RepositoryGuard, FinanceCommand
    implements AccountsRepository {
  AccountsRepositoryImpl(this.financeStore);

  @override
  final FinanceStore financeStore;

  @override
  Future<Either<Failure, FinanceRecords>> load() => readRecords('loadAccounts');

  @override
  Future<Either<Failure, FinanceRecords>> saveAccount({
    required String? id,
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required CalendarDate openingDate,
    required bool includeInTotal,
    String? bankName,
    String? accountNumber,
    String? phoneNumber,
  }) {
    return changeRecords(
      'saveAccount',
      (FinanceRecords records) => records.saveAccount(
        id: id,
        name: name,
        type: type,
        openingBalanceMinor: openingBalanceMinor,
        openingDate: openingDate,
        includeInTotal: includeInTotal,
        now: DateTime.now(),
        bankName: bankName,
        accountNumber: accountNumber,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deactivateAccount(String id) {
    return changeRecords(
      'deactivateAccount',
      (FinanceRecords records) => records.deactivateAccount(id, DateTime.now()),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> reactivateAccount(String id) {
    return changeRecords(
      'reactivateAccount',
      (FinanceRecords records) => records.reactivateAccount(id, DateTime.now()),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deleteAccount(String id) {
    return changeRecords(
      'deleteAccount',
      (FinanceRecords records) => records.deleteAccount(id),
    );
  }
}
