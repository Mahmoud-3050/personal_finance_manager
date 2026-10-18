import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../core/utils/values/fonts.dart';
import '../../core/utils/values/text_styles.dart';
import 'extra_colors.dart';

/// Host [ThemeData]: package color layer + fonts / ScreenUtil sizes.
///
/// Call only inside [ScreenUtilInit] so `.w` / `.sp` are valid.
ThemeData appTheme(ThemeColors colors, Brightness brightness) {
  final colorTheme = Themes.buildThemeData(colors, brightness);
  final TextStyle body = TextStyles.of(size: 16, fontFamily: Fonts.current);
  final TextStyle label = TextStyles.of(
    size: 15,
    weight: TextStyles.semibold,
    fontFamily: Fonts.current,
  );
  final StadiumBorder pill = const StadiumBorder();
  return colorTheme.copyWith(
    textTheme: colorTheme.textTheme.apply(
      fontFamily: Fonts.current,
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    ),
    primaryTextTheme: colorTheme.primaryTextTheme.apply(
      fontFamily: Fonts.current,
      bodyColor: colors.onPrimary,
      displayColor: colors.onPrimary,
    ),
    colorScheme: _platformColorScheme(colorTheme.colorScheme, colors),
    cupertinoOverrideTheme: _cupertinoTheme(colors, _surfaceBrightness(colors)),
    splashFactory: InkRipple.splashFactory,
    dividerTheme: DividerThemeData(thickness: 1.sp, color: colors.divider),
    focusColor: colors.primary,
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        alignment: Alignment.center,
        foregroundColor: WidgetStateProperty.all<Color>(colors.textPrimary),
        iconColor: WidgetStateProperty.all<Color>(colors.textPrimary),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.grey400,
        elevation: 0,
        minimumSize: Size(48.w, 48.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        shape: pill,
        textStyle: label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        disabledForegroundColor: colors.grey400,
        side: BorderSide(color: colors.border),
        minimumSize: Size(48.w, 44.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        shape: pill,
        textStyle: label.copyWith(
          fontWeight: TextStyles.medium,
          fontFamily: Fonts.current,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.textPrimary,
        textStyle: body.copyWith(
          fontWeight: TextStyles.medium,
          fontFamily: Fonts.current,
        ),
        shape: pill,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: const CircleBorder(),
      sizeConstraints: BoxConstraints.tightFor(width: 56.r, height: 56.r),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return colors.onPrimary;
        }
        return colors.textPrimary;
      }),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.border;
      }),
      trackOutlineColor: WidgetStateProperty.all<Color>(colors.border),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.background,
      elevation: 0,
      height: 64.h,
      indicatorColor: colors.primary.withValues(alpha: _selectedTintAlpha),
      surfaceTintColor: colors.background,
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        final Color color = states.contains(WidgetState.selected)
            ? colors.primary
            : colors.unselected;
        return IconThemeData(color: color);
      }),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colors.foreground,
      headerBackgroundColor: colors.background,
      headerForegroundColor: colors.textPrimary,
      dayForegroundColor: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return colors.onPrimary;
        }
        return colors.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.foreground.withValues(alpha: 0);
      }),
      todayForegroundColor: WidgetStateProperty.all<Color>(colors.primary),
      todayBorder: BorderSide(color: colors.primary),
      yearForegroundColor: WidgetStateProperty.all<Color>(colors.textPrimary),
      rangeSelectionBackgroundColor: colors.primary.withValues(
        alpha: _selectedTintAlpha,
      ),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: colors.primary),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.textSecondary,
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: colors.background,
      surfaceTintColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: colors.textPrimary),
      titleTextStyle: TextStyles.of(
        size: 20,
        weight: TextStyles.semibold,
        fontFamily: Fonts.current,
        letterSpacing: Fonts.tracking(-0.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.foreground,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      labelStyle: TextStyles.of(size: 13, color: colors.textSecondary),
      hintStyle: TextStyles.of(size: 14, color: colors.hint),
      border: _fieldBorder(colors.border),
      enabledBorder: _fieldBorder(colors.border),
      focusedBorder: _fieldBorder(colors.primary),
      errorBorder: _fieldBorder(colors.error),
      focusedErrorBorder: _fieldBorder(colors.error),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: colors.border),
      ),
    ),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (BuildContext context) => Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 16.r,
        color: colors.textPrimary,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

const double _selectedTintAlpha = 0.16;
const double _iosBodySize = 17;
const double _iosSmallActionSize = 15;
const double _iosLargeTitleSize = 34;
const double _iosPickerSize = 21;
const double _iosTabSize = 10;

ColorScheme _platformColorScheme(ColorScheme base, ThemeColors colors) {
  final Color selectedTint = colors.primary.withValues(
    alpha: _selectedTintAlpha,
  );
  return base.copyWith(
    surface: colors.background,
    onSurface: colors.textPrimary,
    onSurfaceVariant: colors.textSecondary,
    surfaceDim: colors.background,
    surfaceBright: colors.foreground,
    surfaceContainerLowest: colors.background,
    surfaceContainerLow: colors.background,
    surfaceContainer: colors.foreground,
    surfaceContainerHigh: colors.foreground,
    surfaceContainerHighest: colors.foreground,
    outline: colors.border,
    outlineVariant: colors.divider,
    surfaceTint: colors.background,
    primaryContainer: selectedTint,
    onPrimaryContainer: colors.primary,
    secondaryContainer: colors.secondary,
    onSecondaryContainer: colors.onSecondary,
    errorContainer: colors.error.withValues(alpha: _selectedTintAlpha),
    onErrorContainer: colors.error,
    inverseSurface: colors.textPrimary,
    onInverseSurface: colors.background,
    inversePrimary: colors.primary,
  );
}

/// Both palettes are dark navy, including the light theme mode. Cupertino
/// sheets and alerts resolve their materials from this brightness.
Brightness _surfaceBrightness(ThemeColors colors) {
  return ThemeData.estimateBrightnessForColor(colors.background);
}

CupertinoThemeData _cupertinoTheme(ThemeColors colors, Brightness brightness) {
  final TextStyle body = TextStyle(
    inherit: false,
    color: colors.textPrimary,
    fontFamily: Fonts.current,
    fontFamilyFallback: Fonts.usesArabic
        ? null
        : const <String>[Fonts.ibmPlexSansArabic],
    fontSize: _iosBodySize,
    decoration: TextDecoration.none,
  );
  final TextStyle action = body.copyWith(color: colors.primary);
  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: colors.primary,
    primaryContrastingColor: colors.onPrimary,
    applyThemeToAll: true,
    scaffoldBackgroundColor: colors.background,
    barBackgroundColor: colors.background,
    selectionHandleColor: colors.primary,
    textTheme: CupertinoTextThemeData(
      primaryColor: colors.primary,
      textStyle: body,
      actionTextStyle: action,
      actionSmallTextStyle: action.copyWith(fontSize: _iosSmallActionSize),
      tabLabelTextStyle: body.copyWith(
        color: colors.textSecondary,
        fontSize: _iosTabSize,
        fontWeight: TextStyles.medium,
      ),
      navTitleTextStyle: body.copyWith(fontWeight: TextStyles.semibold),
      navLargeTitleTextStyle: body.copyWith(
        fontSize: _iosLargeTitleSize,
        fontWeight: TextStyles.bold,
      ),
      navActionTextStyle: action,
      pickerTextStyle: body.copyWith(fontSize: _iosPickerSize),
      dateTimePickerTextStyle: body.copyWith(fontSize: _iosPickerSize),
    ),
  );
}

OutlineInputBorder _fieldBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.r),
    borderSide: BorderSide(color: color),
  );
}
