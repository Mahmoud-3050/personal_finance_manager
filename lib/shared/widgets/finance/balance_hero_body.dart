import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../core/utils/values/text_styles.dart';
import '../finance_ledger.dart';

class BalanceHeroBody extends StatelessWidget {
  const BalanceHeroBody({
    required this.label,
    required this.amount,
    this.amountColor,
    this.footer,
    super.key,
  });

  final String label;
  final String amount;
  final Color? amountColor;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final Widget? flow = footer;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BalanceGlyph(),
          ),
          Text(label, style: TextStyles.of(size: 13, weight: FontWeight.w500)),
          SizedBox(height: 4.h),
          FinanceAmount(
            label: amount,
            size: 36,
            color: amountColor ?? colors.success,
          ),
          if (flow != null) ...<Widget>[SizedBox(height: 16.h), flow],
        ],
      ),
    );
  }
}

class BalanceGlyph extends StatelessWidget {
  const BalanceGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 40.r,
        child: Icon(
          Icons.account_balance_wallet_outlined,
          color: colors.success,
          size: 20.r,
        ),
      ),
    );
  }
}
