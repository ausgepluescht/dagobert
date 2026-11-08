import 'package:flutter/material.dart';

/// Dagobert-Farbpalette. Namen aus dem Designsystem.
abstract final class DgColors {
  /// Primär: Flächen, Icons, FAB, Hero-Verlauf, Fortschrittsringe.
  static const orange = Color(0xFFE2711D);

  /// Primär dunkel: Text-Buttons und orange Texte (WCAG AA auf Weiß).
  static const copper = Color(0xFFB85A12);

  /// Sekundär: Akzente, "Will ich", Münzen, Meilensteine.
  static const gold = Color(0xFFD9A425);

  /// Gold hell: Chip-Hintergründe, Hervorhebung "reif".
  static const goldDust = Color(0xFFF7E6BC);

  static const white = Color(0xFFFFFFFF);

  /// Surface: Karten, Sheets.
  static const warmWhite = Color(0xFFFFF8F1);

  /// Linien, Trenner, Rahmen.
  static const sand = Color(0xFFF0E4D6);

  /// Text.
  static const espresso = Color(0xFF2A2118);

  /// Text gedämpft.
  static const cocoa = Color(0xFF7A6A5C);

  /// Erfolg, gesparte Beträge (Flächen).
  static const savingsGreen = Color(0xFF2F9B6A);

  /// Grüner Text auf Weiß.
  static const pineGreen = Color(0xFF22704D);

  static const greenTint = Color(0xFFE9F6EF);

  /// "Brauche ich".
  static const calmBlue = Color(0xFF3D6FA8);

  static const blueText = Color(0xFF2D5583);

  static const blueTint = Color(0xFFE3ECF7);

  /// Destruktiv.
  static const brick = Color(0xFFD2453B);

  /// Undo-Snackbar Aktionstext.
  static const undoGold = Color(0xFFF7CF7A);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, gold],
  );
}
