import 'package:language/language.dart';

/// Latin UI uses Inter, and display figures use Space Grotesk.
/// Arabic uses IBM Plex Sans Arabic, a screen face built for finance data
/// with the same weights as Inter.
abstract class Fonts {
  static bool get usesArabic => Language.instance.isArabic;

  static String get current => usesArabic ? ibmPlexSansArabic : inter;

  static String get display => usesArabic ? ibmPlexSansArabic : spaceGrotesk;

  static const String inter = 'Inter';
  static const String spaceGrotesk = 'Space Grotesk';
  static const String ibmPlexSansArabic = 'IBM Plex Sans Arabic';

  /// Tight tracking suits Space Grotesk. Arabic keeps the font's own spacing.
  static double? tracking(double latinTracking) =>
      usesArabic ? null : latinTracking;
}
