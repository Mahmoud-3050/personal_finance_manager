import 'dart:io';

import 'package:finzomanager/core/database/finance_store.dart';
import 'package:finzomanager/features/accounts/data/datasources/finance_record_mapper_impl.dart';
import 'package:finzomanager/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'an account is still there after the database file is reopened',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'fenzo-account',
      );
      final File file = File('${directory.path}/fenzo.sqlite');
      final FinanceStore source = FinanceStore(
        mapper: const FinanceRecordMapperImpl(),
        databaseFile: file,
      );
      await AccountsRepositoryImpl(source).saveAccount(
        id: null,
        name: 'Bank ABC',
        type: AccountType.bank,
        openingBalanceMinor: 2500000,
        openingDate: const CalendarDate(2026, 10, 1),
        includeInTotal: true,
        bankName: 'ABC',
      );
      await source.close();
      final FinanceStore reopened = FinanceStore(
        mapper: const FinanceRecordMapperImpl(),
        databaseFile: file,
      );
      final loaded = await AccountsRepositoryImpl(reopened).load();
      expect(loaded.rightOrNull!.accounts.single.name, 'Bank ABC');
      expect(loaded.rightOrNull!.accounts.single.bankName, 'ABC');
      await reopened.close();
      await directory.delete(recursive: true);
    },
  );
}
