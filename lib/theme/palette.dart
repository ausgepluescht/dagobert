import 'package:flutter/material.dart';

import '../model/stroke_spec.dart';

/// Farben der App: Papier, Tinte und die Marker-Farben.
abstract final class Palette {
  static const paper = Color(0xFFFBFAF6);
  static const paperDeep = Color(0xFFF3F1EA);
  static const gridLine = Color(0x1A5C7CA8);
  static const ink = Color(0xFF1F1F1F);
  static const inkSoft = Color(0xFF6B6B66);
  static const inkFaint = Color(0xFFB9B8B2);

  static const markerBlack = Color(0xFF232323);
  static const markerRed = Color(0xFFD7263D);
  static const markerGreen = Color(0xFF2E9E5B);
  static const markerBlue = Color(0xFF2B6CB0);
  static const markerGrey = Color(0xFFA2A6AA);

  static const accent = markerRed;

  static Color of(MarkerColor c) => switch (c) {
    MarkerColor.black => markerBlack,
    MarkerColor.red => markerRed,
    MarkerColor.green => markerGreen,
    MarkerColor.blue => markerBlue,
    MarkerColor.grey => markerGrey,
  };

  static String nameOf(MarkerColor c) => switch (c) {
    MarkerColor.black => 'Schwarz',
    MarkerColor.red => 'Rot',
    MarkerColor.green => 'Grün',
    MarkerColor.blue => 'Blau',
    MarkerColor.grey => 'Grau',
  };
}
