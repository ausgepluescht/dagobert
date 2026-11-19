import 'dart:math' as math;
import 'dart:ui';

/// Farben, wie sie auf echten Flipchart-Markern vorkommen.
enum MarkerColor { black, red, green, blue, grey }

/// Strichstärke eines Markers.
enum MarkerWidth { thin, medium, thick }

extension MarkerWidthValue on MarkerWidth {
  /// Breite in Figurkoordinaten (Figuren leben im 100 x 100 Raster).
  double get units => switch (this) {
    MarkerWidth.thin => 1.6,
    MarkerWidth.medium => 2.6,
    MarkerWidth.thick => 4.2,
  };
}

/// Ein einzelner Marker-Strich einer Vorlage, beschrieben als Polylinie im
/// Figurraster 0..100. Kurven werden beim Erzeugen bereits in Punkte zerlegt,
/// damit Vorlage, Animation und Treffervergleich dieselbe Darstellung nutzen.
class StrokeSpec {
  const StrokeSpec(
    this.points, {
    this.color = MarkerColor.black,
    this.width = MarkerWidth.medium,
    this.fill = false,
  });

  final List<Offset> points;
  final MarkerColor color;
  final MarkerWidth width;

  /// Geschlossene Fläche statt Linie (z. B. ein Schatten als graue Fläche).
  final bool fill;

  StrokeSpec copyWith({MarkerColor? color, MarkerWidth? width}) =>
      StrokeSpec(points, color: color ?? this.color, width: width ?? this.width, fill: fill);

  /// Gesamtlänge der Polylinie, für die Zeichen-Animation.
  double get length {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  /// Vorderer Abschnitt der Polylinie bis zur Länge [upTo].
  List<Offset> prefix(double upTo) {
    if (points.isEmpty) return const [];
    final out = <Offset>[points.first];
    var remaining = upTo;
    for (var i = 1; i < points.length; i++) {
      final seg = points[i] - points[i - 1];
      final d = seg.distance;
      if (d <= remaining) {
        out.add(points[i]);
        remaining -= d;
      } else {
        if (d > 0) out.add(points[i - 1] + seg * (remaining / d));
        break;
      }
    }
    return out;
  }
}

/// Kleine Werkzeugkiste, um Figuren kompakt zu beschreiben.
abstract final class Shapes {
  static Offset p(double x, double y) => Offset(x, y);

  static List<Offset> line(double x1, double y1, double x2, double y2) =>
      [Offset(x1, y1), Offset(x2, y2)];

  static List<Offset> poly(List<double> xy, {bool close = false}) {
    final pts = <Offset>[];
    for (var i = 0; i + 1 < xy.length; i += 2) {
      pts.add(Offset(xy[i], xy[i + 1]));
    }
    if (close && pts.isNotEmpty) pts.add(pts.first);
    return pts;
  }

  static List<Offset> rect(double x, double y, double w, double h) =>
      poly([x, y, x + w, y, x + w, y + h, x, y + h], close: true);

  /// Rechteck mit abgerundeten Ecken.
  static List<Offset> roundRect(double x, double y, double w, double h, double r) {
    final pts = <Offset>[];
    pts.addAll(arc(x + w - r, y + r, r, -90, 90));
    pts.addAll(arc(x + w - r, y + h - r, r, 0, 90));
    pts.addAll(arc(x + r, y + h - r, r, 90, 90));
    pts.addAll(arc(x + r, y + r, r, 180, 90));
    pts.add(pts.first);
    return pts;
  }

  /// Kreisbogen. Winkel in Grad, 0 = rechts, 90 = unten (Bildschirmkoordinaten).
  static List<Offset> arc(double cx, double cy, double r, double startDeg, double sweepDeg,
      {int? segments}) {
    final n = segments ?? math.max(6, (sweepDeg.abs() / 6).round());
    final pts = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final a = (startDeg + sweepDeg * i / n) * math.pi / 180;
      pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
    }
    return pts;
  }

  static List<Offset> ellipse(double cx, double cy, double rx, double ry,
      {double startDeg = -90, double sweepDeg = 360}) {
    final n = math.max(12, (sweepDeg.abs() / 6).round());
    final pts = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final a = (startDeg + sweepDeg * i / n) * math.pi / 180;
      pts.add(Offset(cx + rx * math.cos(a), cy + ry * math.sin(a)));
    }
    return pts;
  }

  static List<Offset> circle(double cx, double cy, double r, {double startDeg = -90}) =>
      arc(cx, cy, r, startDeg, 360);

  /// Quadratische Bezierkurve.
  static List<Offset> quad(double x0, double y0, double cx, double cy, double x1, double y1,
      {int segments = 14}) {
    final pts = <Offset>[];
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final mt = 1 - t;
      pts.add(Offset(
        mt * mt * x0 + 2 * mt * t * cx + t * t * x1,
        mt * mt * y0 + 2 * mt * t * cy + t * t * y1,
      ));
    }
    return pts;
  }

  /// Kubische Bezierkurve.
  static List<Offset> cubic(double x0, double y0, double c1x, double c1y, double c2x, double c2y,
      double x1, double y1,
      {int segments = 16}) {
    final pts = <Offset>[];
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final mt = 1 - t;
      pts.add(Offset(
        mt * mt * mt * x0 + 3 * mt * mt * t * c1x + 3 * mt * t * t * c2x + t * t * t * x1,
        mt * mt * mt * y0 + 3 * mt * mt * t * c1y + 3 * mt * t * t * c2y + t * t * t * y1,
      ));
    }
    return pts;
  }

  /// Mehrere Polylinien zu einer verbinden (Endpunkt der einen ist Startpunkt
  /// der nächsten).
  static List<Offset> join(List<List<Offset>> parts) {
    final out = <Offset>[];
    for (final part in parts) {
      if (out.isNotEmpty && part.isNotEmpty && (out.last - part.first).distance < 0.01) {
        out.addAll(part.skip(1));
      } else {
        out.addAll(part);
      }
    }
    return out;
  }

  /// Wellenlinie, z. B. für Wolken-Unterseiten oder Wasser.
  static List<Offset> wave(double x1, double x2, double y, double amp, int bumps) {
    final pts = <Offset>[];
    final n = bumps * 8;
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      pts.add(Offset(x1 + (x2 - x1) * t, y + amp * math.sin(t * bumps * 2 * math.pi)));
    }
    return pts;
  }

  /// Zickzack-Schraffur in einem Rechteck, für Falsch- und Füllmuster.
  static List<List<Offset>> hatch(double x, double y, double w, double h, double gap) {
    final lines = <List<Offset>>[];
    for (var d = gap; d < w + h; d += gap) {
      final ax = (d < h) ? x : x + (d - h);
      final ay = (d < h) ? y + d : y + h;
      final bx = (d < w) ? x + d : x + w;
      final by = (d < w) ? y : y + (d - w);
      lines.add([Offset(ax, ay), Offset(bx, by)]);
    }
    return lines;
  }
}
