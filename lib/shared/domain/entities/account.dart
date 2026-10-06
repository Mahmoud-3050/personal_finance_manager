import 'package:equatable/equatable.dart';

import 'calendar_date.dart';

enum AccountType { bank, eWallet, cash, other }

class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalanceMinor,
    required this.openingDate,
    required this.isActive,
    required this.includeInTotal,
    required this.createdAt,
    required this.updatedAt,
    this.bankName,
    this.accountNumber,
    this.phoneNumber,
  });

  final String id;
  final String name;
  final AccountType type;
  final String? bankName;
  final String? accountNumber;
  final String? phoneNumber;
  final int openingBalanceMinor;
  final CalendarDate openingDate;
  final bool isActive;
  final bool includeInTotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account copyWith({
    String? name,
    AccountType? type,
    String? bankName,
    String? accountNumber,
    String? phoneNumber,
    bool clearBank = false,
    bool clearPhone = false,
    int? openingBalanceMinor,
    CalendarDate? openingDate,
    bool? isActive,
    bool? includeInTotal,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      bankName: clearBank ? null : bankName ?? this.bankName,
      accountNumber: clearBank ? null : accountNumber ?? this.accountNumber,
      phoneNumber: clearPhone ? null : phoneNumber ?? this.phoneNumber,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      openingDate: openingDate ?? this.openingDate,
      isActive: isActive ?? this.isActive,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    type,
    bankName,
    accountNumber,
    phoneNumber,
    openingBalanceMinor,
    openingDate,
    isActive,
    includeInTotal,
    createdAt,
    updatedAt,
  ];
}
