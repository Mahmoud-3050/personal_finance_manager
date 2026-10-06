import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../core/utils/values/fonts.dart';
import '../../core/utils/values/text_styles.dart';

class FinanceAmount extends StatelessWidget {
  const FinanceAmount({
    required this.label,
    required this.size,
    this.color,
    this.weight = FontWeight.w600,
    super.key,
  });

  final String label;
  final double size;
  final Color? color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      style: TextStyles.of(
        size: size,
        weight: weight,
        color: color,
        fontFamily: Fonts.display,
        letterSpacing: size >= 28 ? -0.8 : -0.2,
        height: 1.05,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        fontVariations: <FontVariation>[
          FontVariation.weight(weight.value.toDouble()),
        ],
      ),
    );
  }
}

class FinanceSectionTitle extends StatelessWidget {
  const FinanceSectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 8.h),
      child: Text(
        label,
        style: TextStyles.of(
          size: 13,
          weight: FontWeight.w600,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class FinanceLedgerRow extends StatelessWidget {
  const FinanceLedgerRow({
    required this.title,
    this.subtitle,
    this.amount,
    this.amountColor,
    this.trailing,
    this.onTap,
    this.indent = 0,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? amount;
  final Color? amountColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final Widget body = Padding(
      padding: EdgeInsetsDirectional.only(
        start: 16.w + indent,
        end: 8.w,
        top: 14.h,
        bottom: 14.h,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  style: TextStyles.of(size: 16, weight: FontWeight.w500),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    style: TextStyles.of(
                      size: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (amount != null) ...<Widget>[
            SizedBox(width: 12.w),
            FinanceAmount(label: amount!, size: 15, color: amountColor),
          ],
          ?trailing,
        ],
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: onTap == null
          ? body
          : InkWell(onTap: onTap, child: body),
    );
  }
}
