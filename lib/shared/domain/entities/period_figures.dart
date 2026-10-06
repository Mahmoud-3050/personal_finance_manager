import 'package:equatable/equatable.dart';

import 'account_period_figures.dart';
import 'category_share.dart';

class PeriodFigures extends Equatable {
  const PeriodFigures({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.netMinor,
    required this.expenseShares,
    required this.incomeShares,
    required this.accounts,
  });

  final int incomeMinor;
  final int expenseMinor;
  final int netMinor;
  final List<CategoryShare> expenseShares;
  final List<CategoryShare> incomeShares;
  final List<AccountPeriodFigures> accounts;

  @override
  List<Object?> get props => <Object?>[
    incomeMinor,
    expenseMinor,
    netMinor,
    expenseShares,
    incomeShares,
    accounts,
  ];
}
