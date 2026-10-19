import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/domain/services/percentage_commission.dart';

abstract interface class AccountsRepository {
  Future<Either<Failure, FinanceRecords>> load();

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
    int defaultCommissionMinor = 0,
    CommissionBasis defaultCommissionBasis = CommissionBasis.fixed,
    int defaultCommissionRateMinor = 0,
  });

  Future<Either<Failure, FinanceRecords>> deactivateAccount(String id);

  Future<Either<Failure, FinanceRecords>> reactivateAccount(String id);

  Future<Either<Failure, FinanceRecords>> deleteAccount(String id);
}
