import 'package:flutter/material.dart';

import 'palette.dart';

abstract final class AppTheme {
  static const handFont = 'PatrickHand';

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Palette.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.ink,
        brightness: Brightness.light,
        primary: Palette.ink,
        onPrimary: Palette.paper,
        secondary: Palette.markerRed,
        surface: Palette.paper,
        onSurface: Palette.ink,
      ),
    );
    final text = base.textTheme.apply(bodyColor: Palette.ink, displayColor: Palette.ink);
    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: text.displayLarge?.copyWith(fontFamily: handFont),
        displayMedium: text.displayMedium?.copyWith(fontFamily: handFont),
        displaySmall: text.displaySmall?.copyWith(fontFamily: handFont),
        headlineLarge: text.headlineLarge?.copyWith(fontFamily: handFont),
        headlineMedium: text.headlineMedium?.copyWith(fontFamily: handFont),
        headlineSmall: text.headlineSmall?.copyWith(fontFamily: handFont),
        titleLarge: text.titleLarge?.copyWith(fontFamily: handFont, fontSize: 26),
        titleMedium: text.titleMedium?.copyWith(fontFamily: handFont, fontSize: 21),
        titleSmall: text.titleSmall?.copyWith(fontFamily: handFont, fontSize: 18),
        bodyLarge: text.bodyLarge?.copyWith(height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.4, color: Palette.ink),
        bodySmall: text.bodySmall?.copyWith(color: Palette.inkSoft),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Palette.paper,
        foregroundColor: Palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontFamily: handFont, fontSize: 28, color: Palette.ink),
      ),
      dividerColor: Palette.inkFaint,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.ink,
          foregroundColor: Palette.paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontFamily: handFont, fontSize: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Palette.ink,
          side: const BorderSide(color: Palette.ink, width: 1.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontFamily: handFont, fontSize: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Palette.ink,
          textStyle: const TextStyle(fontFamily: handFont, fontSize: 19),
        ),
      ),
      iconTheme: const IconThemeData(color: Palette.ink),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Palette.ink,
        contentTextStyle: const TextStyle(color: Palette.paper, fontFamily: handFont, fontSize: 18),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
