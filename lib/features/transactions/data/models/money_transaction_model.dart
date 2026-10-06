import 'package:drift/drift.dart';

import '../../../../core/database/finance_database.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money_transaction.dart';

final class MoneyTransactionModel extends MoneyTransaction {
  const MoneyTransactionModel({
    required super.id,
    required super.type,
    required super.amountMinor,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.accountId,
    super.categoryId,
    super.subcategoryId,
    super.fromAccountId,
    super.toAccountId,
    super.description,
    super.notes,
  });

  factory MoneyTransactionModel.fromEntity(MoneyTransaction transaction) {
    return MoneyTransactionModel(
      id: transaction.id,
      type: transaction.type,
      amountMinor: transaction.amountMinor,
      date: transaction.date,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      subcategoryId: transaction.subcategoryId,
      fromAccountId: transaction.fromAccountId,
      toAccountId: transaction.toAccountId,
      description: transaction.description,
      notes: transaction.notes,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  factory MoneyTransactionModel.fromRow(TransactionRow row) {
    return MoneyTransactionModel(
      id: row.id,
      type: MoneyTransactionType.values.byName(row.type),
      amountMinor: row.amountMinor,
      date: CalendarDate.parse(row.date),
      accountId: row.accountId,
      categoryId: row.categoryId,
      subcategoryId: row.subcategoryId,
      fromAccountId: row.fromAccountId,
      toAccountId: row.toAccountId,
      description: row.description,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  factory MoneyTransactionModel.fromJson(Map<String, dynamic> json) {
    return MoneyTransactionModel(
      id: json['id'] as String,
      type: MoneyTransactionType.values.byName(json['type'] as String),
      amountMinor: json['amount_minor'] as int,
      date: CalendarDate.parse(json['date'] as String),
      accountId: json['account_id'] as String?,
      categoryId: json['category_id'] as String?,
      subcategoryId: json['subcategory_id'] as String?,
      fromAccountId: json['from_account_id'] as String?,
      toAccountId: json['to_account_id'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'amount_minor': amountMinor,
    'date': date.toIso(),
    'account_id': accountId,
    'category_id': categoryId,
    'subcategory_id': subcategoryId,
    'from_account_id': fromAccountId,
    'to_account_id': toAccountId,
    'description': description,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  TransactionRowsCompanion toCompanion() {
    return TransactionRowsCompanion.insert(
      id: id,
      type: type.name,
      amountMinor: amountMinor,
      date: date.toIso(),
      accountId: Value(accountId),
      categoryId: Value(categoryId),
      subcategoryId: Value(subcategoryId),
      fromAccountId: Value(fromAccountId),
      toAccountId: Value(toAccountId),
      description: Value(description),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
