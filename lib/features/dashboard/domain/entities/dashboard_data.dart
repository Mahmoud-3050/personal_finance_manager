import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/category_share.dart';
import '../../../../shared/domain/entities/money_transaction.dart';

class DashboardData extends Equatable {
  const DashboardData({
    required this.totalMoneyMinor,
    required this.incomeMinor,
    required this.expenseMinor,
    required this.netMinor,
    required this.accounts,
    required this.accountBalances,
    required this.expenseShares,
    required this.recent,
  });

  final int totalMoneyMinor;
  final int incomeMinor;
  final int expenseMinor;
  final int netMinor;
  final List<Account> accounts;
  final Map<String, int> accountBalances;
  final List<CategoryShare> expenseShares;
  final List<MoneyTransaction> recent;

  @override
  List<Object?> get props => <Object?>[
    totalMoneyMinor,
    incomeMinor,
    expenseMinor,
    netMinor,
    accounts,
    accountBalances,
    expenseShares,
    recent,
  ];
}
