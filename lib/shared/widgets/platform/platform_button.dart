import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../core/utils/values/text_styles.dart';
import 'platform_target.dart';

const double _iosButtonRadius = 12;

/// A text button that follows the phone platform.
///
/// iOS uses [CupertinoButton]. Android uses a Material filled or outlined button.
class PlatformButton extends StatelessWidget {
  const PlatformButton({
    required this.label,
    required this.onPressed,
    this.filled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final Color labelColor = filled
        ? (usesIosComponents(context)
              ? CupertinoTheme.of(context).primaryContrastingColor
              : colors.onPrimary)
        : colors.textPrimary;
    final Text labelText = Text(
      label,
      maxLines: 1,
      style: TextStyles.of(
        size: 15,
        weight: TextStyles.semibold,
        color: labelColor,
      ),
    );
    if (usesIosComponents(context)) {
      return _IosPlatformButton(
        label: labelText,
        onPressed: onPressed,
        filled: filled,
        colors: colors,
      );
    }
    if (filled) {
      return FilledButton(onPressed: onPressed, child: labelText);
    }
    return OutlinedButton(onPressed: onPressed, child: labelText);
  }
}

class _IosPlatformButton extends StatelessWidget {
  const _IosPlatformButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    required this.colors,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final bool filled;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return CupertinoButton.filled(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        borderRadius: BorderRadius.circular(_iosButtonRadius.r),
        onPressed: onPressed,
        child: label,
      );
    }
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      borderRadius: BorderRadius.circular(_iosButtonRadius.r),
      color: colors.foreground,
      onPressed: onPressed,
      child: label,
    );
  }
}
