import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import 'color_keys.dart';

/// Host extras and gradients. Light/dark values live on the two palettes.
extension ExtraColors on ThemeColors {
  Color get grey100 => extra(ColorKeys.grey100);
  Color get grey200 => extra(ColorKeys.grey200);
  Color get grey300 => extra(ColorKeys.grey300);
  Color get grey400 => extra(ColorKeys.grey400);
  Color get grey500 => extra(ColorKeys.grey500);
  Color get grey600 => extra(ColorKeys.grey600);
  Color get grey700 => extra(ColorKeys.grey700);
  Color get yellow => extra(ColorKeys.yellow);
  Color get orange => extra(ColorKeys.orange);
  Color get green => extra(ColorKeys.green);
  Color get red => extra(ColorKeys.red);
  Color get greyBackground => extra(ColorKeys.greyBackground);
  Color get greyForeground => extra(ColorKeys.greyForeground);
  Color get progressBarBackground => extra(ColorKeys.progressBarBackground);
  Color get baseColorShimmer => extra(ColorKeys.baseColorShimmer);
  Color get highlightColorShimmer => extra(ColorKeys.highlightColorShimmer);
  Color get cardGradientStart => extra(ColorKeys.cardGradientStart);
  Color get cardGradientEnd => extra(ColorKeys.cardGradientEnd);

  LinearGradient get primaryGradient => LinearGradient(
    colors: [cardGradientStart, cardGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
