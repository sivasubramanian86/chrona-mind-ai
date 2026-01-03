import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// TOKENS & CONSTANTS
// =============================================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

// =============================================================================
// COLOR PALETTES (Matches design_tokens.json)
// =============================================================================

class LightColors {
  static const primary = Color(0xFF6B46C1);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF4C9AFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const tertiary = Color(0xFF00D9FF);
  static const onTertiary = Color(0xFF003544);
  static const background = Color(0xFFF8F7FF);
  static const surface = Color(0xFFFCF8FF);
  static const error = Color(0xFFBA1A1A);
  static const outline = Color(0xFF79747E);
  static const shadow = Color(0xFF000000);
}

class DarkColors {
  static const primary = Color(0xFFD0BCFF);
  static const onPrimary = Color(0xFF381E72);
  static const secondary = Color(0xFF8AB4F8);
  static const onSecondary = Color(0xFF003258);
  static const tertiary = Color(0xFF66E5FF);
  static const onTertiary = Color(0xFF00363D);
  static const background = Color(0xFF0D0F13);
  static const surface = Color(0xFF1E1E24);
  static const error = Color(0xFFFFB4AB);
  static const outline = Color(0xFF938F99);
  static const shadow = Color(0xFF000000);
}

// =============================================================================
// TEXT STYLES & EXTENSIONS
// =============================================================================

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle withColor(Color color) => copyWith(color: color);
}

TextTheme _buildTextTheme() {
  final base = GoogleFonts.interTextTheme();
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: 57, 
      letterSpacing: -0.25,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: 45,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 36,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 32, 
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 28, 
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 24, 
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 22, 
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 16, 
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 14, 
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 16,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 14,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12,
      fontFamily: 'Inter',
      fontFamilyFallback: ['NotoSans', 'NotoColorEmoji'],
    ),
  );
}

// =============================================================================
// APP THEME DATA
// =============================================================================

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: LightColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: LightColors.primary,
          onPrimary: LightColors.onPrimary,
          secondary: LightColors.secondary,
          onSecondary: LightColors.onSecondary,
          tertiary: LightColors.tertiary,
          onTertiary: LightColors.onTertiary,
          error: LightColors.error,
          onError: Colors.white,
          surface: LightColors.surface,
          onSurface: Colors.black,
          outline: LightColors.outline,
          shadow: LightColors.shadow,
        ),
        textTheme: _buildTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.black,
        ),
        cardTheme: CardTheme(
          color: LightColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
            side: BorderSide(color: LightColors.outline.withValues(alpha: 0.1)),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: DarkColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: DarkColors.primary,
          onPrimary: DarkColors.onPrimary,
          secondary: DarkColors.secondary,
          onSecondary: DarkColors.onSecondary,
          tertiary: DarkColors.tertiary,
          onTertiary: DarkColors.onTertiary,
          error: DarkColors.error,
          onError: Colors.black,
          surface: DarkColors.surface,
          onSurface: Colors.white,
          outline: DarkColors.outline,
          shadow: DarkColors.shadow,
        ),
        textTheme: _buildTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: DarkColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
            side: BorderSide(color: DarkColors.outline.withOpacity(0.2)),
          ),
        ),
      );
}
