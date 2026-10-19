import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:finzomanager/features/accounts/domain/usecases/save_account_use_case.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements AccountsRepository {
  _Repo(this.book);

  FinanceRecords book;

  @override
  Future<Either<Failure, FinanceRecords>> load() async => Right(book);

  @override
  Future<Either<Failure, FinanceRecords>> deactivateAccount(String id) async {
    return Right(book);
  }

  @override
  Future<Either<Failure, FinanceRecords>> reactivateAccount(String id) async {
    return Right(book);
  }

  @override
  Future<Either<Failure, FinanceRecords>> deleteAccount(String id) async {
    return Right(book);
  }

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
    int defaultCommissionMinor = 0,
    CommissionBasis defaultCommissionBasis = CommissionBasis.fixed,
    int defaultCommissionRateMinor = 0,
  }) async {
    final Either<Failure, FinanceRecords> next = book.saveAccount(
      id: id,
      name: name,
      type: type,
      openingBalanceMinor: openingBalanceMinor,
      openingDate: openingDate,
      includeInTotal: includeInTotal,
      now: DateTime(2026, 10, 6, 4),
      bankName: bankName,
      accountNumber: accountNumber,
      phoneNumber: phoneNumber,
      defaultCommissionMinor: defaultCommissionMinor,
      defaultCommissionBasis: defaultCommissionBasis,
      defaultCommissionRateMinor: defaultCommissionRateMinor,
    );
    return next.map((FinanceRecords value) {
      book = value;
      return value;
    });
  }
}

void main() {
  test('save account passes a 1% usual fee through as rate 100', () async {
    final _Repo repository = _Repo(FinanceRecords.empty());
    final FinanceRecords saved = (await SaveAccountUseCase(repository)(
      const SaveAccountParams(
        name: 'Vodafone',
        type: AccountType.eWallet,
        openingBalanceMinor: 0,
        openingDate: CalendarDate(2026, 10, 1),
        defaultCommissionBasis: CommissionBasis.percentage,
        defaultCommissionRateMinor: 100,
      ),
    )).rightOrNull!;
    expect(
      saved.accounts.single.defaultCommissionBasis,
      CommissionBasis.percentage,
    );
    expect(saved.accounts.single.defaultCommissionRateMinor, 100);
    expect(saved.accounts.single.defaultCommissionMinor, 0);
  });
}
