import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:finzomanager/core/database/finance_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('a version 1 book gains commission_minor as zero', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'fenzo-migrate',
    );
    final File file = File('${directory.path}/book.sqlite');
    final Database raw = sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE account_rows (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        bank_name TEXT,
        account_number TEXT,
        phone_number TEXT,
        opening_balance_minor INTEGER NOT NULL,
        opening_date TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        include_in_total INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute('''
      CREATE TABLE transaction_rows (
        id TEXT NOT NULL PRIMARY KEY,
        type TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        date TEXT NOT NULL,
        account_id TEXT,
        category_id TEXT,
        subcategory_id TEXT,
        from_account_id TEXT,
        to_account_id TEXT,
        description TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute(
      'INSERT INTO transaction_rows (id, type, amount_minor, date, created_at, updated_at) '
      "VALUES ('tx', 'expense', 100, '2026-10-02', 0, 0)",
    );
    raw.execute('PRAGMA user_version = 1');
    raw.close();

    final FinanceDatabase database = FinanceDatabase(NativeDatabase(file));
    final List<QueryRow> rows = await database
        .customSelect('SELECT commission_minor FROM transaction_rows')
        .get();
    expect(rows.single.read<int>('commission_minor'), 0);
    await database.close();
    await directory.delete(recursive: true);
  });

  test('a version 2 book gains default_commission_minor as zero', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'fenzo-migrate-v2',
    );
    final File file = File('${directory.path}/book.sqlite');
    final Database raw = sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE account_rows (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        bank_name TEXT,
        account_number TEXT,
        phone_number TEXT,
        opening_balance_minor INTEGER NOT NULL,
        opening_date TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        include_in_total INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute('''
      CREATE TABLE transaction_rows (
        id TEXT NOT NULL PRIMARY KEY,
        type TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        date TEXT NOT NULL,
        account_id TEXT,
        category_id TEXT,
        subcategory_id TEXT,
        from_account_id TEXT,
        to_account_id TEXT,
        description TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        commission_minor INTEGER NOT NULL DEFAULT 0
      )
    ''');
    raw.execute(
      'INSERT INTO account_rows (id, name, type, opening_balance_minor, opening_date, is_active, include_in_total, created_at, updated_at) '
      "VALUES ('bank', 'Bank', 'bank', 2500000, '2026-10-01', 1, 1, 0, 0)",
    );
    raw.execute(
      'INSERT INTO transaction_rows (id, type, amount_minor, date, commission_minor, created_at, updated_at) '
      "VALUES ('tx', 'expense', 20000, '2026-10-02', 500, 0, 0)",
    );
    raw.execute('PRAGMA user_version = 2');
    raw.close();

    final FinanceDatabase database = FinanceDatabase(NativeDatabase(file));
    final List<QueryRow> accounts = await database
        .customSelect('SELECT default_commission_minor FROM account_rows')
        .get();
    final List<QueryRow> transactions = await database
        .customSelect('SELECT commission_minor FROM transaction_rows')
        .get();
    expect(accounts.single.read<int>('default_commission_minor'), 0);
    expect(transactions.single.read<int>('commission_minor'), 500);
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'a version 3 book gains commission_basis fixed and commission_rate_minor zero',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'fenzo-migrate-v3',
      );
      final File file = File('${directory.path}/book.sqlite');
      final Database raw = sqlite3.open(file.path);
      raw.execute('''
      CREATE TABLE account_rows (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        bank_name TEXT,
        account_number TEXT,
        phone_number TEXT,
        opening_balance_minor INTEGER NOT NULL,
        default_commission_minor INTEGER NOT NULL DEFAULT 0,
        opening_date TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        include_in_total INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
      raw.execute('''
      CREATE TABLE transaction_rows (
        id TEXT NOT NULL PRIMARY KEY,
        type TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        date TEXT NOT NULL,
        account_id TEXT,
        category_id TEXT,
        subcategory_id TEXT,
        from_account_id TEXT,
        to_account_id TEXT,
        description TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        commission_minor INTEGER NOT NULL DEFAULT 0
      )
    ''');
      raw.execute(
        'INSERT INTO transaction_rows (id, type, amount_minor, date, commission_minor, created_at, updated_at) '
        "VALUES ('tx', 'transfer', 100000, '2026-10-02', 500, 0, 0)",
      );
      raw.execute('PRAGMA user_version = 3');
      raw.close();

      final FinanceDatabase database = FinanceDatabase(NativeDatabase(file));
      final List<QueryRow> rows = await database
          .customSelect(
            'SELECT commission_minor, commission_basis, commission_rate_minor '
            'FROM transaction_rows',
          )
          .get();
      expect(rows.single.read<int>('commission_minor'), 500);
      expect(rows.single.read<String>('commission_basis'), 'fixed');
      expect(rows.single.read<int>('commission_rate_minor'), 0);
      await database.close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'a version 4 book gains default_commission_basis fixed and rate zero',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'fenzo-migrate-v4',
      );
      final File file = File('${directory.path}/book.sqlite');
      final Database raw = sqlite3.open(file.path);
      raw.execute('''
      CREATE TABLE account_rows (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        bank_name TEXT,
        account_number TEXT,
        phone_number TEXT,
        opening_balance_minor INTEGER NOT NULL,
        default_commission_minor INTEGER NOT NULL DEFAULT 0,
        opening_date TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        include_in_total INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
      raw.execute('''
      CREATE TABLE transaction_rows (
        id TEXT NOT NULL PRIMARY KEY,
        type TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        date TEXT NOT NULL,
        account_id TEXT,
        category_id TEXT,
        subcategory_id TEXT,
        from_account_id TEXT,
        to_account_id TEXT,
        description TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        commission_minor INTEGER NOT NULL DEFAULT 0,
        commission_basis TEXT NOT NULL DEFAULT 'fixed',
        commission_rate_minor INTEGER NOT NULL DEFAULT 0
      )
    ''');
      raw.execute(
        'INSERT INTO account_rows (id, name, type, opening_balance_minor, '
        'default_commission_minor, opening_date, is_active, include_in_total, '
        'created_at, updated_at) '
        "VALUES ('bank', 'Bank', 'bank', 2500000, 300, '2026-10-01', 1, 1, 0, 0)",
      );
      raw.execute('PRAGMA user_version = 4');
      raw.close();

      final FinanceDatabase database = FinanceDatabase(NativeDatabase(file));
      final List<QueryRow> rows = await database
          .customSelect(
            'SELECT default_commission_minor, default_commission_basis, '
            'default_commission_rate_minor FROM account_rows',
          )
          .get();
      expect(rows.single.read<int>('default_commission_minor'), 300);
      expect(rows.single.read<String>('default_commission_basis'), 'fixed');
      expect(rows.single.read<int>('default_commission_rate_minor'), 0);
      await database.close();
      await directory.delete(recursive: true);
    },
  );
}
