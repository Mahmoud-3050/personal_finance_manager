import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/widgets/finance/balance_flow_stat.dart';
import '../../../../shared/widgets/finance/balance_hero_body.dart';
import '../../../../shared/widgets/finance/gradient_panel.dart';
import '../../domain/entities/dashboard_data.dart';
import 'dashboard_navigation.dart';

class DashboardBalance extends StatelessWidget {
  const DashboardBalance({required this.data, super.key});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final int availableMinor = _availableMinor(data);
    return GradientPanel(
      onTap: () => openMonth(context, excludeTransfers: true),
      child: BalanceHeroBody(
        label: Strings.fenzoTotal,
        amount: Money(availableMinor).format(),
        amountColor: availableMinor < 0 ? colors.error : colors.success,
        footer: BalanceFlowStat(
          incomeLabel: Strings.fenzoIncome,
          incomeAmount: Money(data.incomeMinor).format(),
          expenseLabel: Strings.fenzoExpense,
          expenseAmount: Money(data.expenseMinor).format(),
          onIncome: () => openMonth(context, type: .income),
          onExpense: () => openMonth(context, type: .expense),
        ),
      ),
    );
  }
}

int _availableMinor(DashboardData data) {
  var total = 0;
  for (final int balance in data.accountBalances.values) {
    total += balance;
  }
  return total;
}

class DashboardGap extends StatelessWidget {
  const DashboardGap({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: 16.h);
}
