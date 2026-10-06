import 'package:drift/drift.dart';

import '../../../../core/database/finance_database.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';

final class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.openingBalanceMinor,
    required super.openingDate,
    required super.isActive,
    required super.includeInTotal,
    required super.createdAt,
    required super.updatedAt,
    super.bankName,
    super.accountNumber,
    super.phoneNumber,
  });

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      name: account.name,
      type: account.type,
      bankName: account.bankName,
      accountNumber: account.accountNumber,
      phoneNumber: account.phoneNumber,
      openingBalanceMinor: account.openingBalanceMinor,
      openingDate: account.openingDate,
      isActive: account.isActive,
      includeInTotal: account.includeInTotal,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  factory AccountModel.fromRow(AccountRow row) {
    return AccountModel(
      id: row.id,
      name: row.name,
      type: AccountType.values.byName(row.type),
      bankName: row.bankName,
      accountNumber: row.accountNumber,
      phoneNumber: row.phoneNumber,
      openingBalanceMinor: row.openingBalanceMinor,
      openingDate: CalendarDate.parse(row.openingDate),
      isActive: row.isActive,
      includeInTotal: row.includeInTotal,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values.byName(json['type'] as String),
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      phoneNumber: json['phone_number'] as String?,
      openingBalanceMinor: json['opening_balance_minor'] as int,
      openingDate: CalendarDate.parse(json['opening_date'] as String),
      isActive: json['is_active'] as bool,
      includeInTotal: json['include_in_total'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'type': type.name,
    'bank_name': bankName,
    'account_number': accountNumber,
    'phone_number': phoneNumber,
    'opening_balance_minor': openingBalanceMinor,
    'opening_date': openingDate.toIso(),
    'is_active': isActive,
    'include_in_total': includeInTotal,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  AccountRowsCompanion toCompanion() {
    return AccountRowsCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      bankName: Value(bankName),
      accountNumber: Value(accountNumber),
      phoneNumber: Value(phoneNumber),
      openingBalanceMinor: openingBalanceMinor,
      openingDate: openingDate.toIso(),
      isActive: isActive,
      includeInTotal: includeInTotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
