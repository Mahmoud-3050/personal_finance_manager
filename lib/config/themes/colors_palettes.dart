import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import 'color_keys.dart';

/// Navy, emerald, and coral. Edit hex here — hot reload.
///
/// Surfaces are deep navy or slate. Text is off-white. Emerald marks
/// balances and income. Coral marks expenses.
abstract final class ColorsPalettes {
  static const Map<String, Color> _sharedExtra = {
    ColorKeys.grey100: Color(0xFF243044),
    ColorKeys.grey200: Color(0xFF2C3B52),
    ColorKeys.grey300: Color(0xFF8B97A8),
    ColorKeys.grey400: Color(0xFF6E7C90),
    ColorKeys.grey500: Color(0xFFA8B3C0),
    ColorKeys.grey600: Color(0xFFC3CBD4),
    ColorKeys.grey700: Color(0xFFF4F6F8),
    ColorKeys.yellow: Color(0xFFE2B340),
    ColorKeys.orange: Color(0xFFE08A4F),
    ColorKeys.green: Color(0xFF3DDC97),
    ColorKeys.red: Color(0xFFFF7A70),
    ColorKeys.baseColorShimmer: Color(0xFF1A2436),
    ColorKeys.highlightColorShimmer: Color(0xFF2A384E),
  };

  static const ThemeColors _light = ThemeColors(
    white: Color(0xFFF4F6F8),
    black: Color(0xFF071018),
    background: Color(0xFF152033),
    foreground: Color(0xFF1E2A3D),
    primary: Color(0xFF3DDC97),
    onPrimary: Color(0xFF071018),
    secondary: Color(0xFF24344A),
    onSecondary: Color(0xFFF4F6F8),
    textPrimary: Color(0xFFF4F6F8),
    textSecondary: Color(0xFFC3CBD4),
    unselected: Color(0xFF8B97A8),
    divider: Color(0xFF2C3B52),
    hint: Color(0xFFA8B3C0),
    border: Color(0xFF2C3B52),
    error: Color(0xFFFF7A70),
    success: Color(0xFF3DDC97),
    extra: {
      ..._sharedExtra,
      ColorKeys.greyBackground: Color(0xFF152033),
      ColorKeys.greyForeground: Color(0xFF1E2A3D),
      ColorKeys.progressBarBackground: Color(0xFF2C3B52),
      ColorKeys.cardGradientStart: Color(0xFF1A3358),
      ColorKeys.cardGradientEnd: Color(0xFF0E1C30),
    },
  );

  static const ThemeColors _dark = ThemeColors(
    white: Color(0xFFF7F8FA),
    black: Color(0xFF05080E),
    background: Color(0xFF0B1220),
    foreground: Color(0xFF141C2B),
    primary: Color(0xFF3DDC97),
    onPrimary: Color(0xFF071018),
    secondary: Color(0xFF1C2838),
    onSecondary: Color(0xFFF7F8FA),
    textPrimary: Color(0xFFF7F8FA),
    textSecondary: Color(0xFFB7C0CC),
    unselected: Color(0xFF8B97A8),
    divider: Color(0xFF243044),
    hint: Color(0xFF9AA6B5),
    border: Color(0xFF243044),
    error: Color(0xFFFF8A80),
    success: Color(0xFF3DDC97),
    extra: {
      ColorKeys.grey100: Color(0xFF141C2B),
      ColorKeys.grey200: Color(0xFF243044),
      ColorKeys.grey300: Color(0xFF8B97A8),
      ColorKeys.grey400: Color(0xFF6E7C90),
      ColorKeys.grey500: Color(0xFF9AA6B5),
      ColorKeys.grey600: Color(0xFFB7C0CC),
      ColorKeys.grey700: Color(0xFFF7F8FA),
      ColorKeys.yellow: Color(0xFFE2B340),
      ColorKeys.orange: Color(0xFFE08A4F),
      ColorKeys.green: Color(0xFF3DDC97),
      ColorKeys.red: Color(0xFFFF8A80),
      ColorKeys.baseColorShimmer: Color(0xFF121A28),
      ColorKeys.highlightColorShimmer: Color(0xFF1C2838),
      ColorKeys.greyBackground: Color(0xFF0B1220),
      ColorKeys.greyForeground: Color(0xFF141C2B),
      ColorKeys.progressBarBackground: Color(0xFF243044),
      ColorKeys.cardGradientStart: Color(0xFF163056),
      ColorKeys.cardGradientEnd: Color(0xFF0A1424),
    },
  );

  static const ThemeConfig config = ThemeConfig(light: _light, dark: _dark);
}
