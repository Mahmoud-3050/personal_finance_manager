import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../config/themes/extra_colors.dart';

class GradientPanel extends StatelessWidget {
  const GradientPanel({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final BorderRadius radius = BorderRadius.circular(20.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.black.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: colors.cardGradientEnd.withValues(alpha: 0),
        borderRadius: radius,
        child: InkWell(onTap: onTap, borderRadius: radius, child: child),
      ),
    );
  }
}
