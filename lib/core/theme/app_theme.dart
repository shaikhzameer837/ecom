import 'package:flutter/material.dart';

/// Monochrome (black & white) Material 3 theme.
///
/// Everything is driven by neutral greys so the app reads as a clean
/// black-on-white in light mode and white-on-black in dark mode. Emphasis
/// colors (price, discount badges, ratings) are exposed as theme-aware
/// helpers rather than fixed colors so they stay legible in both modes.
class AppTheme {
  AppTheme._();

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 20;
  static const double spacingXs = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXl = 32;

  /// Strong emphasis text color (prices, in-stock, success) — pure
  /// foreground in either mode.
  static Color emphasis(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Inverse chip/badge background (black pill on light, white on dark).
  static Color badgeBg(BuildContext context) =>
      Theme.of(context).colorScheme.inverseSurface;

  static Color badgeFg(BuildContext context) =>
      Theme.of(context).colorScheme.onInverseSurface;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ColorScheme _scheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF111111),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE6E6E6),
        onPrimaryContainer: Color(0xFF111111),
        secondary: Color(0xFF2B2B2B),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE6E6E6),
        onSecondaryContainer: Color(0xFF111111),
        tertiary: Color(0xFF3A3A3A),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFEDEDED),
        onTertiaryContainer: Color(0xFF111111),
        error: Color(0xFFB00020),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0A0A0A),
        onSurfaceVariant: Color(0xFF4A4A4A),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF7F7F7),
        surfaceContainer: Color(0xFFF2F2F2),
        surfaceContainerHigh: Color(0xFFECECEC),
        surfaceContainerHighest: Color(0xFFE6E6E6),
        outline: Color(0xFFBDBDBD),
        outlineVariant: Color(0xFFE2E2E2),
        inverseSurface: Color(0xFF1A1A1A),
        onInverseSurface: Color(0xFFF5F5F5),
        inversePrimary: Color(0xFFEDEDED),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      );
    }
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF262626),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFD6D6D6),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFF262626),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFFC2C2C2),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF1E1E1E),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFCF6679),
      onError: Color(0xFF000000),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFAFAFA),
      onSurfaceVariant: Color(0xFFB5B5B5),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF0D0D0D),
      surfaceContainer: Color(0xFF141414),
      surfaceContainerHigh: Color(0xFF1C1C1C),
      surfaceContainerHighest: Color(0xFF242424),
      outline: Color(0xFF5A5A5A),
      outlineVariant: Color(0xFF2A2A2A),
      inverseSurface: Color(0xFFF5F5F5),
      onInverseSurface: Color(0xFF111111),
      inversePrimary: Color(0xFF262626),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = _scheme(brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: scheme.onSurface, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.surfaceContainerHighest,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 0.5),
    );
  }
}
