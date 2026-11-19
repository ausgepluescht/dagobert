import 'package:flutter/material.dart';

import '../model/figure.dart';
import '../model/stroke_spec.dart';
import '../theme/palette.dart';
import 'marker_paint.dart';

/// Rechnet Figurkoordinaten (0..100) in ein Quadrat der Kantenlänge [side] um.
Offset figureToCanvas(Offset p, double side, {Offset origin = Offset.zero}) =>
    Offset(origin.dx + p.dx / 100 * side, origin.dy + p.dy / 100 * side);

/// Umgekehrte Richtung: Bildschirmpunkt in Figurkoordinaten.
Offset canvasToFigure(Offset p, double side, {Offset origin = Offset.zero}) =>
    Offset((p.dx - origin.dx) / side * 100, (p.dy - origin.dy) / side * 100);

/// Zeichnet eine Figur als fertiges Bild (Vorschau) oder als blasse Vorlage,
/// bei der der aktuelle Schritt etwas kräftiger erscheint.
class FigurePainter extends CustomPainter {
  const FigurePainter(
    this.figure, {
    this.mode = FigurePaintMode.preview,
    this.currentStep = 0,
    this.animationLength,
    this.padding = 0,
  });

  final Figure figure;
  final FigurePaintMode mode;

  /// Index des Schritts, der gerade geübt wird (nur im Vorlagen-Modus).
  final int currentStep;

  /// Länge in Figur-Einheiten, bis zu der der aktuelle Schritt bereits
  /// "gezeichnet" ist. Null = komplett anzeigen.
  final double? animationLength;

  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final side = (size.shortestSide - 2 * padding).clamp(1.0, double.infinity);
    final origin = Offset((size.width - side) / 2, (size.height - side) / 2);
    final scale = side / 100;

    for (var s = 0; s < figure.steps.length; s++) {
      final step = figure.steps[s];
      final (alpha, drawAnimated) = switch (mode) {
        FigurePaintMode.preview => (MarkerPaint.opacity, false),
        FigurePaintMode.ghost => s < currentStep
            ? (0.16, false)
            : s == currentStep
                ? (0.42, true)
                : (0.09, false),
        FigurePaintMode.demo => s < currentStep
            ? (0.16, false)
            : s == currentStep
                ? (MarkerPaint.opacity, true)
                : (0.0, false),
      };
      if (alpha <= 0) continue;

      var remaining = drawAnimated ? animationLength : null;
      for (final spec in step.strokes) {
        var pts = spec.points;
        if (remaining != null) {
          if (remaining <= 0) break;
          final len = spec.length;
          if (remaining < len) {
            pts = spec.prefix(remaining);
            remaining = 0;
          } else {
            remaining -= len;
          }
          if (spec.fill && pts.length < spec.points.length) {
            // Flächen erst zeigen, wenn der Umriss vollständig ist.
            MarkerPaint.strokePolyline(canvas, [for (final p in pts) figureToCanvas(p, side, origin: origin)],
                Palette.of(spec.color), spec.width.units * scale,
                alpha: alpha);
            continue;
          }
        }
        MarkerPaint.strokePolyline(
          canvas,
          [for (final p in pts) figureToCanvas(p, side, origin: origin)],
          Palette.of(spec.color),
          spec.width.units * scale,
          alpha: alpha,
          fill: spec.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FigurePainter old) =>
      old.figure != figure ||
      old.mode != mode ||
      old.currentStep != currentStep ||
      old.animationLength != animationLength ||
      old.padding != padding;
}

enum FigurePaintMode {
  /// Fertige Figur, voll sichtbar.
  preview,

  /// Blasse Vorlage zum Abmalen, aktueller Schritt etwas kräftiger.
  ghost,

  /// Nur der aktuelle Schritt, voll sichtbar, für die Vorführung.
  demo,
}

/// Breite eines Markers in Bildschirmpixeln für eine Zeichenfläche der Kantenlänge [side].
double markerWidthPx(MarkerWidth w, double side) => w.units * side / 100;
