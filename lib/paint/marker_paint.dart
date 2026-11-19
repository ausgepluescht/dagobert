import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';

/// Zeichnet Striche so, dass sie nach Flipchart-Marker aussehen: leicht
/// durchscheinend (Überlappungen werden dunkler), mit einer Keilspitze, die
/// quer zur Zugrichtung breiter aufträgt als längs, und runden Enden.
abstract final class MarkerPaint {
  /// Deckkraft eines frischen Markerstrichs.
  static const double opacity = 0.86;

  /// Winkel der Keilspitze in Radiant (0 = waagerecht gehaltener Keil).
  static const double tipAngle = 0.35;

  /// Wie stark die Breite zwischen längs und quer schwankt (0 = rund, 1 = extrem).
  static const double chisel = 0.42;

  static double widthFactor(Offset dir) {
    if (dir.distanceSquared == 0) return 1;
    final angle = math.atan2(dir.dy, dir.dx);
    final across = math.sin(angle - tipAngle).abs();
    return (1 - chisel) + chisel * across;
  }

  /// Zeichnet eine Polylinie in Bildschirmkoordinaten.
  static void strokePolyline(
    Canvas canvas,
    List<Offset> pts,
    Color color,
    double width, {
    double alpha = opacity,
    bool fill = false,
    Rect? bounds,
  }) {
    if (pts.isEmpty) return;
    final layerPaint = Paint()..color = Color.fromRGBO(255, 255, 255, alpha.clamp(0, 1));
    final layerBounds = bounds ?? _bounds(pts, width * 2);
    canvas.saveLayer(layerBounds, layerPaint);

    if (fill && pts.length > 2) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
      // Rand nachziehen, damit die Kante den Marker-Look behält.
      canvas.drawPath(path, Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.6
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true);
      canvas.restore();
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    if (pts.length == 1) {
      canvas.drawCircle(pts.first, width / 2, Paint()..color = color..isAntiAlias = true);
      canvas.restore();
      return;
    }

    // Breitenfaktor pro Segment, zwischen Nachbarn geglättet, damit die
    // Breite nicht springt.
    final n = pts.length - 1;
    final factors = List<double>.filled(n, 1);
    for (var i = 0; i < n; i++) {
      factors[i] = widthFactor(pts[i + 1] - pts[i]);
    }
    for (var i = 0; i < n; i++) {
      final prev = i > 0 ? factors[i - 1] : factors[i];
      final next = i < n - 1 ? factors[i + 1] : factors[i];
      final f = (prev + 2 * factors[i] + next) / 4;
      paint.strokeWidth = math.max(1.0, width * f);
      canvas.drawLine(pts[i], pts[i + 1], paint);
    }
    canvas.restore();
  }

  static Rect _bounds(List<Offset> pts, double pad) {
    var minX = pts.first.dx, maxX = pts.first.dx, minY = pts.first.dy, maxY = pts.first.dy;
    for (final p in pts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
  }
}
