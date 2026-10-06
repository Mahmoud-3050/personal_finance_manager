import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../core/utils/values/text_styles.dart';
import '../finance_ledger.dart';

class BalanceFlowStat extends StatelessWidget {
  const BalanceFlowStat({
    required this.incomeLabel,
    required this.incomeAmount,
    required this.expenseLabel,
    required this.expenseAmount,
    this.onIncome,
    this.onExpense,
    super.key,
  });

  final String incomeLabel;
  final String incomeAmount;
  final String expenseLabel;
  final String expenseAmount;
  final VoidCallback? onIncome;
  final VoidCallback? onExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _FlowStat(
            label: incomeLabel,
            amount: incomeAmount,
            color: context.colors.success,
            onTap: onIncome,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _FlowStat(
            label: expenseLabel,
            amount: expenseAmount,
            color: context.colors.error,
            onTap: onExpense,
          ),
        ),
      ],
    );
  }
}

class _FlowStat extends StatelessWidget {
  const _FlowStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String amount;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, maxLines: 1, style: TextStyles.of(size: 12, color: color)),
          SizedBox(height: 2.h),
          FinanceAmount(label: amount, size: 16, color: color),
        ],
      ),
    );
  }
}
