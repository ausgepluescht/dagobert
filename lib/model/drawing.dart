import 'dart:ui';

import 'stroke_spec.dart';

/// Ein vom Nutzer gezeichneter Strich, Punkte in Figurkoordinaten (0..100).
class UserStroke {
  UserStroke({required this.color, required this.width, List<Offset>? points}) : points = points ?? [];

  final MarkerColor color;
  final MarkerWidth width;
  final List<Offset> points;

  UserStroke copy() => UserStroke(color: color, width: width, points: List.of(points));
}

/// Die Zeichnung auf dem aktuellen Blatt, mit Rückgängig-Stapel.
class Drawing {
  Drawing({List<UserStroke>? strokes}) : _strokes = strokes ?? [];

  List<UserStroke> _strokes;
  final List<UserStroke> _redo = [];

  /// Unveränderliche Sicht. Die Liste wird bei jeder Änderung ersetzt, damit
  /// Painter per Identitätsvergleich merken, dass sich etwas getan hat.
  List<UserStroke> get strokes => _strokes;

  bool get isEmpty => _strokes.isEmpty;
  bool get canUndo => _strokes.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void add(UserStroke stroke) {
    _strokes = [..._strokes, stroke];
    _redo.clear();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    _redo.add(_strokes.last);
    _strokes = _strokes.sublist(0, _strokes.length - 1);
  }

  void redo() {
    if (_redo.isEmpty) return;
    _strokes = [..._strokes, _redo.removeLast()];
  }

  void clear() {
    _redo.clear();
    _strokes = [];
  }
}
