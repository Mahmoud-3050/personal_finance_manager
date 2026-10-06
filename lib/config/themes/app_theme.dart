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
  final TextStyle body = TextStyles.of(
    size: 16,
    fontFamily: Fonts.current,
  );
  final TextStyle label = TextStyles.of(
    size: 15,
    weight: FontWeight.w600,
    fontFamily: Fonts.current,
  );
  final StadiumBorder pill = const StadiumBorder();
  return colorTheme.copyWith(
    textTheme: colorTheme.textTheme.apply(fontFamily: Fonts.current),
    primaryTextTheme: colorTheme.primaryTextTheme.apply(
      fontFamily: Fonts.current,
    ),
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
          fontWeight: FontWeight.w500, 
          fontFamily: Fonts.current,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.textPrimary,
        textStyle: body.copyWith(
          fontWeight: FontWeight.w500,
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
        return colors.foreground;
      }),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.border;
      }),
      trackOutlineColor: WidgetStateProperty.all<Color>(colors.border),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.textPrimary),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.background,
      elevation: 0,
      height: 64.h,
      indicatorColor: colors.primary.withValues(alpha: 0.12),
      surfaceTintColor: colors.background,
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
        weight: FontWeight.w600,
        fontFamily: Fonts.current,
        letterSpacing: -0.4,
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

OutlineInputBorder _fieldBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.r),
    borderSide: BorderSide(color: color),
  );
}
