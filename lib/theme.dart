import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  AppThemeData get theme => AppThemeData();
}

class AppThemeData {
  // Backgrounds: Deep Dark Space Blue/Purple
  Color get background => const Color(0xFF070414); 
  Color get surface => const Color(0xFF070414);
  Color get surfaceContainerLow => const Color(0xFF0F0B24);
  Color get surfaceContainer => const Color(0xFF18103A);
  Color get surfaceContainerHighest => const Color(0xFF2C1E5C);
  Color get surfaceLow => const Color(0xFF0B071A); // Tile background
  
  // Text
  Color get onSurface => const Color(0xFFE8E6FC);
  Color get onSurfaceVariant => const Color(0xFFAFA7D6);
  
  // Borders
  Color get outline => const Color(0xFF6C5A9C);
  Color get outlineVariant => const Color(0xFF3A2D65);
  
  // Accents (Neon Cyan and Purple)
  Color get primary => const Color(0xFFD0FBFF);
  Color get primaryContainer => const Color(0xFF00F0FF); // Neon cyan
  
  Color get secondary => const Color(0xFFF1D4FF);
  Color get secondaryContainer => const Color(0xFFB517FF); // Vivid Purple
  
  Color get tertiary => const Color(0xFFD4FFEA);
  Color get tertiaryContainer => const Color(0xFF00FA64); // Neon Green for success
  
  Color get accentPurple => const Color(0xFFB517FF);
  Color get accentRed => const Color(0xFFFF2A54); // Neon red
  Color get accentGreen => const Color(0xFF00FA64); // Neon green
  Color get accentBlue => const Color(0xFF00F0FF); // Neon cyan
}
