import 'package:equatable/equatable.dart';

import '../../../../shared/domain/finance_records.dart';

class AccountListData extends Equatable {
  const AccountListData({required this.records, required this.balances});

  final FinanceRecords records;
  final Map<String, int> balances;

  @override
  List<Object?> get props => <Object?>[records, balances];
}
