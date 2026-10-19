import 'package:equatable/equatable.dart';

import '../services/percentage_commission.dart';
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
    this.commissionMinor = 0,
    this.commissionBasis = CommissionBasis.fixed,
    this.commissionRateMinor = 0,
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
  final int commissionMinor;
  final CommissionBasis commissionBasis;
  final int commissionRateMinor;
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
    commissionMinor,
    commissionBasis,
    commissionRateMinor,
    createdAt,
    updatedAt,
  ];
}
