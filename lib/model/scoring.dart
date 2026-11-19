import 'dart:math' as math;
import 'dart:ui';

import 'drawing.dart';
import 'figure.dart';
import 'stroke_spec.dart';

/// Wie gut die eigene Zeichnung die Vorlage trifft.
class ScoreResult {
  const ScoreResult({required this.coverage, required this.precision});

  /// Anteil der Vorlage, der von eigenen Strichen abgedeckt ist (0..1).
  final double coverage;

  /// Anteil der eigenen Striche, die nah an der Vorlage liegen (0..1).
  final double precision;

  int get percent => (100 * (0.6 * coverage + 0.4 * precision)).round().clamp(0, 100);

  String get verdict {
    final p = percent;
    if (p >= 85) return 'Sitzt. Das kannst du auch ohne Vorlage.';
    if (p >= 70) return 'Gut getroffen. Noch zweimal, dann ist es drin.';
    if (p >= 50) return 'Die Form stimmt. Achte auf die Proportionen.';
    return 'Noch einmal langsam, Schritt für Schritt.';
  }
}

/// Vergleicht die Zeichnung mit den Schritten 0..[upToStep] der Figur.
/// Toleranz in Figur-Einheiten (das Blatt ist 100 breit).
ScoreResult scoreDrawing(List<UserStroke> drawing, Figure figure, {int? upToStep, double tolerance = 4.5}) {
  final last = upToStep ?? figure.steps.length - 1;
  final templateStrokes = <StrokeSpec>[
    for (var i = 0; i <= last && i < figure.steps.length; i++) ...figure.steps[i].strokes,
  ];
  // Eigene Striche ebenfalls abtasten: Bei schnellen Zügen liegen die
  // Punkte weit auseinander, der Strich dazwischen zählt aber genauso.
  final userPts = <Offset>[for (final s in drawing) ..._resample(s.points, 1.0)];
  if (templateStrokes.isEmpty || userPts.isEmpty) {
    return const ScoreResult(coverage: 0, precision: 0);
  }

  // Vorlage gleichmäßig abtasten.
  final samples = <Offset>[];
  for (final s in templateStrokes) {
    samples.addAll(_resample(s.points, 1.5));
  }

  // Deckung: Vorlagenpunkte, in deren Nähe ein eigener Punkt liegt.
  final grid = _Grid(userPts, tolerance);
  var covered = 0;
  for (final p in samples) {
    if (grid.anyWithin(p, tolerance)) covered++;
  }

  // Präzision: eigene Punkte, die nah an einer Vorlagenlinie liegen.
  final templateGrid = _Grid(samples, tolerance);
  var near = 0;
  for (final p in userPts) {
    if (templateGrid.anyWithin(p, tolerance)) near++;
  }

  return ScoreResult(
    coverage: samples.isEmpty ? 0 : covered / samples.length,
    precision: userPts.isEmpty ? 0 : near / userPts.length,
  );
}

List<Offset> _resample(List<Offset> pts, double step) {
  if (pts.isEmpty) return const [];
  if (pts.length == 1) return [pts.first];
  final out = <Offset>[pts.first];
  var carry = 0.0;
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    final d = (b - a).distance;
    if (d == 0) continue;
    var t = step - carry;
    while (t <= d) {
      out.add(a + (b - a) * (t / d));
      t += step;
    }
    carry = d - (t - step);
  }
  out.add(pts.last);
  return out;
}

/// Einfaches Raster für Nachbarschaftsabfragen.
class _Grid {
  _Grid(List<Offset> pts, this.cell) {
    for (final p in pts) {
      (_cells[_key(p)] ??= []).add(p);
    }
  }

  final double cell;
  final Map<int, List<Offset>> _cells = {};

  int _key(Offset p) => (p.dx / cell).floor() * 100000 + (p.dy / cell).floor();

  bool anyWithin(Offset p, double r) {
    final cx = (p.dx / cell).floor();
    final cy = (p.dy / cell).floor();
    final r2 = r * r;
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        final bucket = _cells[(cx + dx) * 100000 + (cy + dy)];
        if (bucket == null) continue;
        for (final q in bucket) {
          if ((q - p).distanceSquared <= r2) return true;
        }
      }
    }
    return false;
  }
}

/// Hilfsfunktion für Tests: Länge aller Striche einer Figur.
double figureInkLength(Figure f) => f.allStrokes.fold(0.0, (sum, s) => sum + math.max(s.length, 0.0));
