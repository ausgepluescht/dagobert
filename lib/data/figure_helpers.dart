import 'dart:math' as math;
import 'dart:ui';

import '../model/stroke_spec.dart';

/// Formen, die in vielen Figuren vorkommen.
abstract final class Fig {
  /// Fünfzackiger Stern (oder n-zackig).
  static List<Offset> star(double cx, double cy, double rOuter, double rInner, {int points = 5}) {
    final pts = <Offset>[];
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? rOuter : rInner;
      final a = -math.pi / 2 + i * math.pi / points;
      pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
    }
    pts.add(pts.first);
    return pts;
  }

  /// Zahnrad als geschlossene Polylinie.
  static List<Offset> gear(double cx, double cy, double rOuter, double rInner, {int teeth = 8}) {
    final pts = <Offset>[];
    final step = 2 * math.pi / teeth;
    for (var i = 0; i < teeth; i++) {
      final a0 = -math.pi / 2 + i * step;
      // Zahn: innen -> außen -> außen -> innen, jeweils ein Viertel Schritt.
      for (final (frac, r) in [(0.0, rInner), (0.2, rOuter), (0.5, rOuter), (0.7, rInner)]) {
        final a = a0 + frac * step;
        pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
      }
    }
    pts.add(pts.first);
    return pts;
  }

  /// Wolkenrand: eine Ellipse mit Ausbuchtungen.
  static List<Offset> cloud(double cx, double cy, double rx, double ry, {int bumps = 7, double depth = 0.16}) {
    final pts = <Offset>[];
    const n = 120;
    for (var i = 0; i <= n; i++) {
      final a = -math.pi / 2 + 2 * math.pi * i / n;
      final bump = 1 + depth * math.sin(bumps * a).abs();
      pts.add(Offset(cx + rx * bump * math.cos(a), cy + ry * bump * math.sin(a)));
    }
    return pts;
  }

  /// Pfeilspitze am Punkt (ex, ey), Richtung (dx, dy), als offenes V.
  static List<Offset> head(double ex, double ey, double dx, double dy, {double len = 12, double half = 7}) {
    final d = math.sqrt(dx * dx + dy * dy);
    final ux = dx / d, uy = dy / d;
    final bx = ex - ux * len, by = ey - uy * len;
    final nx = -uy * half, ny = ux * half;
    return [Offset(bx + nx, by + ny), Offset(ex, ey), Offset(bx - nx, by - ny)];
  }

  /// Grauer Schatten rechts und unten an einem Rechteck. Licht kommt von oben links.
  static List<StrokeSpec> boxShadow(double x, double y, double w, double h, {double gap = 3, MarkerWidth width = MarkerWidth.thick}) {
    final o = gap;
    return [
      StrokeSpec(Shapes.line(x + w + o, y + o + 4, x + w + o, y + h + o), color: MarkerColor.grey, width: width),
      StrokeSpec(Shapes.line(x + o + 4, y + h + o, x + w + o, y + h + o), color: MarkerColor.grey, width: width),
    ];
  }

  /// Grauer Schatten rechts unten an einem Kreis.
  static StrokeSpec circleShadow(double cx, double cy, double r, {double gap = 3, double startDeg = -20, double sweepDeg = 110}) =>
      StrokeSpec(Shapes.arc(cx + gap * 0.6, cy + gap * 0.6, r, startDeg, sweepDeg),
          color: MarkerColor.grey, width: MarkerWidth.thick);

  /// Bodenschatten als flache graue Ellipse.
  static StrokeSpec groundShadow(double cx, double cy, double rx, {double ry = 2.5}) =>
      StrokeSpec(Shapes.ellipse(cx, cy, rx, ry), color: MarkerColor.grey, width: MarkerWidth.medium, fill: true);

  static StrokeSpec dot(double cx, double cy, {double r = 1.8, MarkerColor color = MarkerColor.black}) =>
      StrokeSpec(Shapes.circle(cx, cy, r), color: color, width: MarkerWidth.thin, fill: true);

  static StrokeSpec grey(List<Offset> pts, {MarkerWidth width = MarkerWidth.thin}) =>
      StrokeSpec(pts, color: MarkerColor.grey, width: width);

  static StrokeSpec red(List<Offset> pts, {MarkerWidth width = MarkerWidth.medium, bool fill = false}) =>
      StrokeSpec(pts, color: MarkerColor.red, width: width, fill: fill);

  static StrokeSpec green(List<Offset> pts, {MarkerWidth width = MarkerWidth.medium}) =>
      StrokeSpec(pts, color: MarkerColor.green, width: width);

  static StrokeSpec blue(List<Offset> pts, {MarkerWidth width = MarkerWidth.medium}) =>
      StrokeSpec(pts, color: MarkerColor.blue, width: width);

  /// Schwarzer Standardstrich.
  static StrokeSpec s(List<Offset> pts, {MarkerWidth width = MarkerWidth.medium}) =>
      StrokeSpec(pts, width: width);

  /// Mehrere Polylinien zu Strichen gleicher Farbe.
  static List<StrokeSpec> many(List<List<Offset>> parts, {MarkerColor color = MarkerColor.black, MarkerWidth width = MarkerWidth.medium}) =>
      [for (final p in parts) StrokeSpec(p, color: color, width: width)];
}
