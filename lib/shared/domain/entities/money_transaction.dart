import 'package:equatable/equatable.dart';

import 'calendar_date.dart';

/// A recorded movement. This is the spec's Transaction.
enum MoneyTransactionType { income, expense, transfer }

class MoneyTransaction extends Equatable {
  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.accountId,
    this.categoryId,
    this.subcategoryId,
    this.fromAccountId,
    this.toAccountId,
    this.description,
    this.notes,
  });

  final String id;
  final MoneyTransactionType type;
  final int amountMinor;
  final CalendarDate date;
  final String? accountId;
  final String? categoryId;
  final String? subcategoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    type,
    amountMinor,
    date,
    accountId,
    categoryId,
    subcategoryId,
    fromAccountId,
    toAccountId,
    description,
    notes,
    createdAt,
    updatedAt,
  ];
}
