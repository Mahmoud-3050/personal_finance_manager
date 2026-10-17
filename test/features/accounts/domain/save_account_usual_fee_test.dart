import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:finzomanager/features/accounts/domain/usecases/save_account_use_case.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
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
    );
    return next.map((FinanceRecords value) {
      book = value;
      return value;
    });
  }
}

void main() {
  test(
    'save account passes the usual fee through, including a clear to zero',
    () async {
      final _Repo repository = _Repo(FinanceRecords.empty());
      final FinanceRecords saved = (await SaveAccountUseCase(repository)(
        const SaveAccountParams(
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: CalendarDate(2026, 10, 1),
          defaultCommissionMinor: 300,
        ),
      )).rightOrNull!;
      expect(saved.accounts.single.defaultCommissionMinor, 300);
      final FinanceRecords cleared = (await SaveAccountUseCase(repository)(
        SaveAccountParams(
          id: saved.accounts.single.id,
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: const CalendarDate(2026, 10, 1),
        ),
      )).rightOrNull!;
      expect(cleared.accounts.single.defaultCommissionMinor, 0);
    },
  );
}
