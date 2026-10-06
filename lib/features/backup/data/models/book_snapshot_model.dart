import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/subcategory_model.dart';
import '../../../transactions/data/models/money_transaction_model.dart';
import '../../domain/entities/backup_settings.dart';

class BookSnapshotModel {
  const BookSnapshotModel({
    required this.formatVersion,
    required this.createdAt,
    required this.origin,
    required this.records,
  });

  static const int currentVersion = 1;

  final int formatVersion;
  final DateTime createdAt;
  final BackupOrigin origin;
  final FinanceRecords records;

  factory BookSnapshotModel.fromRecords({
    required FinanceRecords records,
    required DateTime createdAt,
    required BackupOrigin origin,
  }) {
    return BookSnapshotModel(
      formatVersion: currentVersion,
      createdAt: createdAt,
      origin: origin,
      records: records,
    );
  }

  factory BookSnapshotModel.fromJson(Map<String, dynamic> json) {
    if (json['formatVersion'] != currentVersion) {
      throw const ValidationException(message: 'unsupported_backup');
    }
    final Object? createdRaw = json['createdAt'];
    final Object? sourceRaw = json['source'];
    if (createdRaw is! String || sourceRaw is! String) {
      throw const ValidationException(message: 'invalid_backup');
    }
    final BackupOrigin origin;
    try {
      origin = BackupOrigin.values.byName(sourceRaw);
    } on ArgumentError {
      throw const ValidationException(message: 'invalid_backup');
    }
    return BookSnapshotModel(
      formatVersion: currentVersion,
      createdAt: DateTime.parse(createdRaw),
      origin: origin,
      records: FinanceRecords(
        accounts: _maps(json['accounts']).map(AccountModel.fromJson).toList(),
        categories: _maps(
          json['categories'],
        ).map(CategoryModel.fromJson).toList(),
        subcategories: _maps(
          json['subcategories'],
        ).map(SubcategoryModel.fromJson).toList(),
        transactions: _maps(
          json['transactions'],
        ).map(MoneyTransactionModel.fromJson).toList(),
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'formatVersion': formatVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'source': origin.name,
    'accounts': records.accounts
        .map((account) => AccountModel.fromEntity(account).toJson())
        .toList(),
    'categories': records.categories
        .map((category) => CategoryModel.fromEntity(category).toJson())
        .toList(),
    'subcategories': records.subcategories
        .map((subcategory) => SubcategoryModel.fromEntity(subcategory).toJson())
        .toList(),
    'transactions': records.transactions
        .map(
          (transaction) =>
              MoneyTransactionModel.fromEntity(transaction).toJson(),
        )
        .toList(),
  };

  String encode() => jsonEncode(toJson());

  static BookSnapshotModel decode(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const ValidationException(message: 'invalid_backup');
    }
    return BookSnapshotModel.fromJson(Map<String, dynamic>.from(decoded));
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    if (value is! List) {
      throw const ValidationException(message: 'invalid_backup');
    }
    return value.map((Object? item) {
      if (item is! Map) {
        throw const ValidationException(message: 'invalid_backup');
      }
      return Map<String, dynamic>.from(item);
    }).toList();
  }
}
