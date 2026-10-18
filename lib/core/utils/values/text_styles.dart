import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import 'fonts.dart';

/// Figma size (px) + [FontWeight] → [TextStyle].
///
/// `size` is passed through `.sp`. Color defaults to
/// [Themes.instance.colors.textPrimary] and overflow to [TextOverflow.ellipsis].
/// Remaining fields match [TextStyle].
abstract final class TextStyles {
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight eztralight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  static TextStyle of({
    required double size,
    FontWeight weight = regular,
    Color? color,
    Color? backgroundColor,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    TextOverflow overflow = .ellipsis,
    bool inherit = true,
    Paint? foreground,
    Paint? background,
    TextBaseline? textBaseline,
    String? debugLabel,
    String? package,
  }) {
    final String resolvedFamily = fontFamily ?? Fonts.current;
    return TextStyle(
      inherit: inherit,
      color:
          color ??
          (Themes.instance.isInitialized
              ? Themes.instance.colors.textPrimary
              : null),
      backgroundColor: backgroundColor,
      fontSize: size.sp,
      fontWeight: weight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      leadingDistribution: leadingDistribution,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: resolvedFamily,
      fontFamilyFallback:
          fontFamilyFallback ??
          (resolvedFamily == Fonts.ibmPlexSansArabic
              ? null
              : const <String>[Fonts.ibmPlexSansArabic]),
      overflow: overflow,
      textBaseline: textBaseline,
      debugLabel: debugLabel,
      package: package,
    );
  }
}
