import 'package:drift/drift.dart';

part 'finance_database.g.dart';

class AccountRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get bankName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  IntColumn get openingBalanceMinor => integer()();
  TextColumn get openingDate => text()();
  BoolColumn get isActive => boolean()();
  BoolColumn get includeInTotal => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class CategoryRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class SubcategoryRows extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class TransactionRows extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get date => text()();
  TextColumn get accountId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get subcategoryId => text().nullable()();
  TextColumn get fromAccountId => text().nullable()();
  TextColumn get toAccountId => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[AccountRows, CategoryRows, SubcategoryRows, TransactionRows],
)
class FinanceDatabase extends _$FinanceDatabase {
  FinanceDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
