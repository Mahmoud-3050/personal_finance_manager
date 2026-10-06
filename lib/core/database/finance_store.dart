import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../shared/domain/finance_records.dart';
import 'finance_database.dart';
import 'finance_record_mapper.dart';

class FinanceStore {
  FinanceStore({required this.mapper, File? databaseFile})
    : _databaseFile = databaseFile;

  final FinanceRecordMapper mapper;
  final File? _databaseFile;
  FinanceDatabase? _database;

  Future<FinanceDatabase> open() async {
    if (_database != null) {
      return _database!;
    }
    final File file = _databaseFile ?? await _defaultFile();
    _database = FinanceDatabase(NativeDatabase(file));
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<FinanceRecords> load() async {
    final FinanceDatabase database = await open();
    final List<AccountRow> accountRows = await database
        .select(database.accountRows)
        .get();
    final List<CategoryRow> categoryRows = await database
        .select(database.categoryRows)
        .get();
    final List<SubcategoryRow> subcategoryRows = await database
        .select(database.subcategoryRows)
        .get();
    final List<TransactionRow> transactionRows = await database
        .select(database.transactionRows)
        .get();
    return FinanceRecords(
      accounts: mapper.readAccounts(accountRows),
      categories: mapper.readCategories(categoryRows),
      subcategories: mapper.readSubcategories(subcategoryRows),
      transactions: mapper.readTransactions(transactionRows),
    ).seedIfNeeded(DateTime.now());
  }

  Future<void> save(FinanceRecords book) async {
    final FinanceDatabase database = await open();
    await database.transaction(() async {
      await database.delete(database.accountRows).go();
      await database.delete(database.categoryRows).go();
      await database.delete(database.subcategoryRows).go();
      await database.delete(database.transactionRows).go();
      await database.batch((Batch batch) {
        batch.insertAll(
          database.accountRows,
          mapper.writeAccounts(book.accounts),
        );
        batch.insertAll(
          database.categoryRows,
          mapper.writeCategories(book.categories),
        );
        batch.insertAll(
          database.subcategoryRows,
          mapper.writeSubcategories(book.subcategories),
        );
        batch.insertAll(
          database.transactionRows,
          mapper.writeTransactions(book.transactions),
        );
      });
    });
  }

  Future<File> _defaultFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'finance.sqlite'));
  }
}
