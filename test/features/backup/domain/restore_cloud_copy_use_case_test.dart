import 'package:finzomanager/features/backup/data/models/book_snapshot_model.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/usecases/restore_cloud_copy_use_case.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/category.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/shared/domain/services/balance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6);

  FinanceRecords book({required String accountName, required int amountMinor}) {
    final Account account = Account(
      id: 'cash',
      name: accountName,
      type: AccountType.cash,
      openingBalanceMinor: 0,
      openingDate: const CalendarDate(2026, 10, 1),
      isActive: true,
      includeInTotal: true,
      createdAt: now,
      updatedAt: now,
    );
    const Category category = Category(
      id: 'salary',
      name: 'Salary',
      kind: CategoryKind.income,
      isActive: true,
    );
    final MoneyTransaction income = MoneyTransaction(
      id: 'income-1',
      type: MoneyTransactionType.income,
      amountMinor: amountMinor,
      date: const CalendarDate(2026, 10, 2),
      accountId: account.id,
      categoryId: category.id,
      createdAt: now,
      updatedAt: now,
    );
    return FinanceRecords(
      accounts: <Account>[account],
      categories: const <Category>[category],
      subcategories: const [],
      transactions: <MoneyTransaction>[income],
    );
  }

  test('a sixth success drops the oldest copy', () async {
    final BackupHarness harness = BackupHarness();
    for (int day = 1; day <= 6; day++) {
      await harness.repository.runManualBackup(
        now: DateTime.utc(2026, 10, day),
      );
    }

    expect(harness.cloud.stored, hasLength(5));
    expect(
      harness.cloud.stored.containsKey(
        DateTime.utc(2026, 10).toIso8601String(),
      ),
      isFalse,
    );
    expect(
      harness.cloud.stored.containsKey(
        DateTime.utc(2026, 10, 6).toIso8601String(),
      ),
      isTrue,
    );
  });

  test('a cancelled restore does not replace the book', () async {
    final FinanceRecords current = book(accountName: 'Now', amountMinor: 100);
    final BackupHarness harness = BackupHarness(book: current);
    harness.cloud.stored['chosen'] = BookSnapshotModel.fromRecords(
      records: book(accountName: 'Then', amountMinor: 900),
      createdAt: now,
      origin: BackupOrigin.manualCloud,
    );

    final result = await RestoreCloudCopyUseCase(harness.repository)(
      const RestoreCloudCopyParams(copyId: 'chosen', confirmed: false),
    );

    expect(result.isRight, isTrue);
    expect(harness.books.replacements, 0);
    expect(harness.books.records.accounts.single.name, 'Now');
  });

  test('a confirmed restore matches the chosen copy', () async {
    final FinanceRecords chosen = book(accountName: 'Then', amountMinor: 900);
    final BackupHarness harness = BackupHarness(
      book: book(accountName: 'Now', amountMinor: 100),
    );
    harness.cloud.stored['chosen'] = BookSnapshotModel.fromRecords(
      records: chosen,
      createdAt: now,
      origin: BackupOrigin.manualCloud,
    );

    final result = await RestoreCloudCopyUseCase(harness.repository)(
      const RestoreCloudCopyParams(copyId: 'chosen', confirmed: true),
    );

    final FinanceRecords restored = result.fold(
      (_) => fail('expected restore'),
      (FinanceRecords records) => records,
    );
    expect(restored.accounts, chosen.accounts);
    expect(restored.categories, chosen.categories);
    expect(restored.transactions, chosen.transactions);
    expect(
      accountBalanceMinor(restored.accounts.single, restored.transactions),
      accountBalanceMinor(chosen.accounts.single, chosen.transactions),
    );
  });
}
