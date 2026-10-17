import 'dart:io';

import 'package:finzomanager/core/database/finance_store.dart';
import 'package:finzomanager/features/accounts/data/datasources/finance_record_mapper_impl.dart';
import 'package:finzomanager/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/category.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'seed categories survive closing and reopening the database file',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'fenzo',
      );
      final File file = File('${directory.path}/fenzo.sqlite');
      final FinanceStore source = FinanceStore(
        mapper: const FinanceRecordMapperImpl(),
        databaseFile: file,
      );
      final AccountsRepositoryImpl repository = AccountsRepositoryImpl(source);
      final created = await repository.saveAccount(
        id: null,
        name: 'Cash',
        type: AccountType.cash,
        openingBalanceMinor: 100,
        openingDate: const CalendarDate(2026, 10, 1),
        includeInTotal: true,
      );
      expect(
        created.rightOrNull!.categories.any(
          (item) => item.name == 'وقود' || item.name == 'مواصلات',
        ),
        isTrue,
      );
      expect(created.rightOrNull!.subcategories.single.name, 'وقود');
      await source.close();

      final FinanceStore reopened = FinanceStore(
        mapper: const FinanceRecordMapperImpl(),
        databaseFile: file,
      );
      final loaded = await AccountsRepositoryImpl(reopened).load();
      expect(loaded.rightOrNull!.accounts.single.name, 'Cash');
      await reopened.close();
      await directory.delete(recursive: true);
    },
  );

  test('an existing catalog gains the transfer commission category', () async {
    final Directory directory = await Directory.systemTemp.createTemp('fenzo');
    final File file = File('${directory.path}/fenzo.sqlite');
    final FinanceStore source = FinanceStore(
      mapper: const FinanceRecordMapperImpl(),
      databaseFile: file,
    );
    final AccountsRepositoryImpl repository = AccountsRepositoryImpl(source);
    final created = await repository.saveAccount(
      id: null,
      name: 'Cash',
      type: AccountType.cash,
      openingBalanceMinor: 0,
      openingDate: const CalendarDate(2026, 10, 1),
      includeInTotal: true,
    );
    final FinanceRecords seeded = created.rightOrNull!;
    final FinanceRecords withoutFee = FinanceRecords(
      accounts: seeded.accounts,
      categories: seeded.categories
          .where((Category item) => item.id != transferCommissionCategoryId)
          .toList(),
      subcategories: seeded.subcategories,
      transactions: seeded.transactions,
    );
    await source.save(withoutFee);
    await source.close();

    final FinanceStore reopened = FinanceStore(
      mapper: const FinanceRecordMapperImpl(),
      databaseFile: file,
    );
    final loaded = await AccountsRepositoryImpl(reopened).load();
    final FinanceRecords book = loaded.rightOrNull!;
    expect(
      book.categories.any(
        (Category item) =>
            item.id == transferCommissionCategoryId &&
            item.name == transferCommissionCategoryName,
      ),
      isTrue,
    );
    expect(
      book.categories.any((Category item) => item.name == 'مواصلات'),
      isTrue,
    );
    await reopened.close();
    await directory.delete(recursive: true);
  });
}
