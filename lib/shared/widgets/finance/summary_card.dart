import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../core/utils/values/text_styles.dart';
import '../finance_ledger.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.leading,
    this.subtitle,
    this.amount,
    this.amountColor,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final Widget leading;
  final String? subtitle;
  final String? amount;
  final Color? amountColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: _RaisedSurface(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: _SummaryCardBody(
            title: title,
            leading: leading,
            subtitle: subtitle,
            amount: amount,
            amountColor: amountColor,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

class _RaisedSurface extends StatelessWidget {
  const _RaisedSurface({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final BorderRadius radius = BorderRadius.circular(16.r);
    return Material(
      color: colors.foreground,
      elevation: 2,
      shadowColor: colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(onTap: onTap, borderRadius: radius, child: child),
    );
  }
}

class _SummaryCardBody extends StatelessWidget {
  const _SummaryCardBody({
    required this.title,
    required this.leading,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.trailing,
  });

  final String title;
  final Widget leading;
  final String? subtitle;
  final String? amount;
  final Color? amountColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        leading,
        SizedBox(width: 12.w),
        Expanded(child: _SummaryCopy(title: title, subtitle: subtitle)),
        if (amount != null)
          FinanceAmount(label: amount!, size: 15, color: amountColor),
        ?trailing,
      ],
    );
  }
}

class _SummaryCopy extends StatelessWidget {
  const _SummaryCopy({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          style: TextStyles.of(size: 15, weight: FontWeight.w600),
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Text(
            subtitle!,
            maxLines: 1,
            style: TextStyles.of(size: 12, color: context.colors.textSecondary),
          ),
      ],
    );
  }
}
