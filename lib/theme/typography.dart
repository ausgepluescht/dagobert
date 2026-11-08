import 'package:flutter/material.dart';

import 'colors.dart';

abstract final class DgType {
  static const family = 'PlusJakartaSans';

  /// Tabellarische Ziffern, damit Beträge beim Hochzählen nicht springen.
  static const tabular = [FontFeature.tabularFigures()];

  static const display = TextStyle(
    fontFamily: family,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.0,
    color: DgColors.espresso,
    fontFeatures: tabular,
  );

  static const h1 = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.2,
    color: DgColors.espresso,
  );

  static const title = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: DgColors.espresso,
  );

  static const body = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: DgColors.espresso,
  );

  static const bodyStrong = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: DgColors.espresso,
  );

  static const meta = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: DgColors.cocoa,
  );

  static const label = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: DgColors.espresso,
  );

  static const amount = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: DgColors.copper,
    fontFeatures: tabular,
  );

  static TextTheme textTheme = const TextTheme(
    displayLarge: display,
    headlineMedium: h1,
    titleMedium: title,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: meta,
    labelSmall: label,
  ).apply(fontFamily: family);
}
