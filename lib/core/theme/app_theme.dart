import 'package:flutter/material.dart';

class ApcColors {
  static const green = Color(0xFF39A453);
  static const blue = Color(0xFF5CC3E7);
  static const red = Color(0xFFE52B32);
  static const brown = Color(0xFF976532);
  static const white = Color(0xFFFFFFFF);
  static const dark = Color(0xFF1A1F2C);
  static const surface = Color(0xFF232A3B);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: ApcColors.green,
      secondary: ApcColors.blue,
      error: ApcColors.red,
      surface: ApcColors.surface,
      onPrimary: ApcColors.white,
      onSecondary: ApcColors.dark,
      onSurface: ApcColors.white,
      tertiary: ApcColors.brown,
    ),
    scaffoldBackgroundColor: ApcColors.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: ApcColors.dark,
      foregroundColor: ApcColors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: ApcColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ApcColors.green,
        foregroundColor: ApcColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ApcColors.dark.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ApcColors.blue, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ApcColors.surface,
      selectedColor: ApcColors.green.withValues(alpha: 0.3),
      labelStyle: const TextStyle(color: ApcColors.white),
      side: BorderSide(color: ApcColors.blue.withValues(alpha: 0.4)),
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: ApcColors.white,
      displayColor: ApcColors.white,
    ),
  );
}
