import 'package:flutter/material.dart';

class ApcColors {
  static const green = Color(0xFF39A453);
  static const greenDark = Color(0xFF2D8241);
  static const greenSoft = Color(0xFFE8F6EC);
  static const blue = Color(0xFF5CC3E7);
  static const blueSoft = Color(0xFFE8F7FC);
  static const red = Color(0xFFE52B32);
  static const redSoft = Color(0xFFFDECEE);
  static const brown = Color(0xFF976532);
  static const gold = Color(0xFFC9A227);
  static const white = Color(0xFFFFFFFF);
  static const dark = Color(0xFF1A1F2C);
  static const ink = Color(0xFF1B2430);
  static const muted = Color(0xFF6B7280);
  static const surface = Color(0xFFF5F7FA);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E9F0);
}

class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.light(
    primary: ApcColors.green,
    onPrimary: ApcColors.white,
    secondary: ApcColors.blue,
    onSecondary: ApcColors.ink,
    error: ApcColors.red,
    onError: ApcColors.white,
    surface: ApcColors.card,
    onSurface: ApcColors.ink,
    tertiary: ApcColors.brown,
    onTertiary: ApcColors.white,
    outline: ApcColors.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: ApcColors.surface,
    fontFamily: null,
    appBarTheme: const AppBarTheme(
      backgroundColor: ApcColors.surface,
      foregroundColor: ApcColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: ApcColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: ApcColors.card,
      elevation: 0,
      shadowColor: ApcColors.ink.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ApcColors.green,
        foregroundColor: ApcColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ApcColors.green,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        side: const BorderSide(color: ApcColors.border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ApcColors.green),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ApcColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        borderSide: const BorderSide(color: ApcColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        borderSide: const BorderSide(color: ApcColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        borderSide: const BorderSide(color: ApcColors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        borderSide: const BorderSide(color: ApcColors.red),
      ),
      labelStyle: const TextStyle(color: ApcColors.muted),
      hintStyle: TextStyle(color: ApcColors.muted.withValues(alpha: 0.8)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ApcColors.greenSoft,
      selectedColor: ApcColors.green,
      labelStyle: const TextStyle(color: ApcColors.ink, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: ApcColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(color: ApcColors.border, thickness: 1),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: ApcColors.green,
      unselectedItemColor: ApcColors.muted,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: ApcColors.ink,
      displayColor: ApcColors.ink,
    ),
  );
}

List<BoxShadow> softShadow({double blur = 18, double y = 8, double opacity = 0.07}) => [
      BoxShadow(
        color: ApcColors.ink.withValues(alpha: opacity),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
    ];
