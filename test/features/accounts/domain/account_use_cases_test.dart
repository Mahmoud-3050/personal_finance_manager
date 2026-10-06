import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/category.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:finzomanager/features/accounts/domain/usecases/save_account_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAccountsRepository implements AccountsRepository {
  FinanceRecords book = FinanceRecords.empty();

  Future<Either<Failure, FinanceRecords>> _keep(
    Either<Failure, FinanceRecords> next,
  ) async {
    return next.map((FinanceRecords value) {
      book = value;
      return value;
    });
  }

  @override
  Future<Either<Failure, FinanceRecords>> load() async => Right(book);

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
    return _keep(
      book.saveAccount(
        id: id,
        name: name,
        type: type,
        openingBalanceMinor: openingBalanceMinor,
        openingDate: openingDate,
        includeInTotal: includeInTotal,
        now: DateTime(2026, 10, 6),
        bankName: bankName,
        accountNumber: accountNumber,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deactivateAccount(String id) =>
      _keep(book.deactivateAccount(id, DateTime(2026, 10, 6)));

  @override
  Future<Either<Failure, FinanceRecords>> reactivateAccount(String id) =>
      _keep(book.reactivateAccount(id, DateTime(2026, 10, 6)));

  @override
  Future<Either<Failure, FinanceRecords>> deleteAccount(String id) =>
      _keep(book.deleteAccount(id));

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
    return _keep(
      book.saveMovement(
        id: id,
        type: type,
        amountMinor: amountMinor,
        date: date,
        now: DateTime(2026, 10, 6, 1),
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
  Future<Either<Failure, FinanceRecords>> deleteTransaction(String id) =>
      _keep(book.deleteTransaction(id));

  @override
  Future<Either<Failure, FinanceRecords>> saveCategory({
    required String? id,
    required String? parentId,
    required String name,
    required CategoryKind kind,
  }) => _keep(
    book.saveCategory(id: id, parentId: parentId, name: name, kind: kind),
  );

  @override
  Future<Either<Failure, FinanceRecords>> deactivateCategory(String id) =>
      _keep(book.deactivateCategory(id));

  @override
  Future<Either<Failure, FinanceRecords>> deleteCategory(String id) =>
      _keep(book.deleteCategory(id));
}

void main() {
  test(
    'type locks after a transaction and deactivate leaves total excluded',
    () async {
      final _MemoryAccountsRepository repository = _MemoryAccountsRepository();
      final SaveAccountUseCase save = SaveAccountUseCase(repository);
      final Either<Failure, FinanceRecords> created = await save(
        const SaveAccountParams(
          name: 'Bank ABC',
          type: AccountType.bank,
          openingBalanceMinor: 2500000,
          openingDate: CalendarDate(2026, 10, 1),
          bankName: 'ABC',
        ),
      );
      final Account account = created.rightOrNull!.accounts.single;
      expect(account.includeInTotal, isTrue);
      repository.book = repository.book.seedIfNeeded(DateTime(2026));
      await repository.saveMovement(
        id: null,
        type: MoneyTransactionType.expense,
        amountMinor: 100,
        date: const CalendarDate(2026, 10, 2),
        accountId: account.id,
        categoryId: repository.book.categories
            .firstWhere((category) => category.kind == CategoryKind.expense)
            .id,
      );
      final Either<Failure, FinanceRecords> locked = await save(
        SaveAccountParams(
          id: account.id,
          name: account.name,
          type: AccountType.cash,
          openingBalanceMinor: account.openingBalanceMinor,
          openingDate: account.openingDate,
        ),
      );
      expect(locked.leftOrNull, isA<ValidationFailure>());
      final Either<Failure, FinanceRecords> deactivated = await repository
          .deactivateAccount(account.id);
      expect(deactivated.rightOrNull!.accounts.single.includeInTotal, isFalse);
      final Either<Failure, FinanceRecords> reactivated = await repository
          .reactivateAccount(account.id);
      expect(reactivated.rightOrNull!.accounts.single.isActive, isTrue);
      expect(reactivated.rightOrNull!.accounts.single.includeInTotal, isFalse);
    },
  );

  test('an opening date after an existing transaction is rejected', () async {
    final _MemoryAccountsRepository repository = _MemoryAccountsRepository();
    final SaveAccountUseCase save = SaveAccountUseCase(repository);
    final Either<Failure, FinanceRecords> created = await save(
      const SaveAccountParams(
        name: 'Cash',
        type: AccountType.cash,
        openingBalanceMinor: 0,
        openingDate: CalendarDate(2026, 10, 1),
      ),
    );
    final Account account = created.rightOrNull!.accounts.single;
    repository.book = repository.book.seedIfNeeded(DateTime(2026));
    await repository.saveMovement(
      id: null,
      type: MoneyTransactionType.expense,
      amountMinor: 100,
      date: const CalendarDate(2026, 10, 3),
      accountId: account.id,
      categoryId: repository.book.categories
          .firstWhere((category) => category.kind == CategoryKind.expense)
          .id,
    );
    final Either<Failure, FinanceRecords> moved = await save(
      SaveAccountParams(
        id: account.id,
        name: account.name,
        type: account.type,
        openingBalanceMinor: account.openingBalanceMinor,
        openingDate: const CalendarDate(2026, 10, 4),
      ),
    );
    expect(moved.leftOrNull, isA<ValidationFailure>());
    expect(
      repository.book.accounts.single.openingDate,
      const CalendarDate(2026, 10, 1),
    );
  });
}
