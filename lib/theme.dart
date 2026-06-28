import 'package:flutter/material.dart';

class AppTheme {
  // Atmospheric Glass Colors
  static const Color surface = Color(0xFF111318);
  static const Color background = Color(0xFF111318);
  static const Color surfaceDim = Color(0xFF111318);
  static const Color surfaceBright = Color(0xFF37393F);
  static const Color surfaceContainerLowest = Color(0xFF0C0E13);
  static const Color surfaceContainerLow = Color(0xFF1A1B21);
  static const Color surfaceContainer = Color(0xFF1E2025);
  static const Color surfaceContainerHigh = Color(0xFF282A2F);
  static const Color surfaceContainerHighest = Color(0xFF33353A);
  
  static const Color onSurface = Color(0xFFE2E2E9);
  static const Color onSurfaceVariant = Color(0xFFC1C6D7);
  static const Color inverseSurface = Color(0xFFE2E2E9);
  static const Color inverseOnSurface = Color(0xFF2E3036);
  
  static const Color outline = Color(0xFF8C909F);
  static const Color outlineVariant = Color(0xFF424753);
  
  static const Color primary = Color(0xFFADC6FF);
  static const Color onPrimary = Color(0xFF002E69);
  static const Color primaryContainer = Color(0xFF4B8EFF);
  static const Color onPrimaryContainer = Color(0xFF00285C);
  static const Color inversePrimary = Color(0xFF005BC1);
  
  static const Color secondary = Color(0xFFE8B3FF);
  static const Color onSecondary = Color(0xFF510074);
  static const Color secondaryContainer = Color(0xFF7D01B1);
  
  static const Color surfaceLow = Color(0xFF0B071A);
  static const Color accentPurple = Color(0xFFB517FF);
  static const Color accentRed = Color(0xFFFF2A54);
  static const Color accentGreen = Color(0xFF00FA64);
  static const Color accentBlue = Color(0xFF00F0FF);
  static const Color onSecondaryContainer = Color(0xFFE5A9FF);
  
  static const Color tertiary = Color(0xFFFFB695);
  static const Color onTertiary = Color(0xFF571E00);
  static const Color tertiaryContainer = Color(0xFFEF6719);
  static const Color onTertiaryContainer = Color(0xFF4C1A00);
  
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  

  static const Color onBackground = Color(0xFFE2E2E9);
  
  // Glass Colors
  static const Color glassSurface = Color(0x991C1E23); // rgba(28, 30, 35, 0.6)
  static const Color inputGlass = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
  static const Color outlineGlow = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.64, height: 1.25),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.28),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.24, height: 1.33),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.42),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.26, height: 1.38),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.44, height: 1.45),
      ),
    );
  }
}
