import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/drawing.dart';
import '../model/figure.dart';
import '../model/stroke_spec.dart';
import '../paint/figure_painter.dart';
import '../paint/grid_paper_painter.dart';
import '../paint/marker_paint.dart';
import '../theme/palette.dart';

/// Das Blatt: kariertes Papier, blasse Vorlage, eigene Striche, Finger oder Stift.
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.color,
    required this.width,
    required this.onStrokeEnd,
    this.figure,
    this.currentStep = 0,
    this.showGhost = true,
    this.demoLength,
    this.enabled = true,
  });

  final List<UserStroke> strokes;
  final MarkerColor color;
  final MarkerWidth width;
  final ValueChanged<UserStroke> onStrokeEnd;

  final Figure? figure;
  final int currentStep;
  final bool showGhost;

  /// Wenn gesetzt, läuft gerade die Vorführung: nur der aktuelle Schritt,
  /// bis zu dieser Länge gezeichnet.
  final double? demoLength;

  final bool enabled;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  UserStroke? _active;
  Offset? _lastRaw;
  int? _pointer;

  double _side = 1;
  Offset _origin = Offset.zero;

  void _layout(Size size) {
    _side = size.shortestSide;
    _origin = Offset((size.width - _side) / 2, (size.height - _side) / 2);
  }

  Offset _toFigure(Offset local) => canvasToFigure(local, _side, origin: _origin);

  void _down(PointerDownEvent e) {
    if (!widget.enabled || _pointer != null) return;
    _pointer = e.pointer;
    _lastRaw = e.localPosition;
    setState(() {
      _active = UserStroke(color: widget.color, width: widget.width, points: [_toFigure(e.localPosition)]);
    });
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer || _active == null) return;
    final last = _lastRaw!;
    final raw = e.localPosition;
    if ((raw - last).distance < 1.2) return;
    // Leichte Glättung gegen Zittern, ohne Ecken zu verschleifen.
    final smoothed = Offset.lerp(last, raw, 0.72)!;
    _lastRaw = smoothed;
    setState(() => _active!.points.add(_toFigure(smoothed)));
  }

  void _up(PointerEvent e) {
    if (e.pointer != _pointer) return;
    final s = _active;
    _pointer = null;
    _active = null;
    _lastRaw = null;
    if (s != null) widget.onStrokeEnd(s);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layout(constraints.biggest);
        final figure = widget.figure;
        return Listener(
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _up,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const RepaintBoundary(child: CustomPaint(painter: GridPaperPainter(cell: 26))),
              if (figure != null && (widget.showGhost || widget.demoLength != null))
                RepaintBoundary(
                  child: CustomPaint(
                    painter: FigurePainter(
                      figure,
                      mode: widget.demoLength != null ? FigurePaintMode.demo : FigurePaintMode.ghost,
                      currentStep: widget.currentStep,
                      animationLength: widget.demoLength,
                    ),
                  ),
                ),
              RepaintBoundary(child: CustomPaint(painter: _StrokesPainter(widget.strokes))),
              if (_active != null) CustomPaint(painter: _StrokesPainter([_active!], live: true)),
            ],
          ),
        );
      },
    );
  }
}

class _StrokesPainter extends CustomPainter {
  _StrokesPainter(this.strokes, {this.live = false});

  final List<UserStroke> strokes;
  final bool live;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final origin = Offset((size.width - side) / 2, (size.height - side) / 2);
    for (final s in strokes) {
      MarkerPaint.strokePolyline(
        canvas,
        [for (final p in s.points) figureToCanvas(p, side, origin: origin)],
        Palette.of(s.color),
        markerWidthPx(s.width, side),
      );
    }
  }

  @override
  bool shouldRepaint(_StrokesPainter old) => live || old.strokes != strokes;
}

/// Rendert die Zeichnung als Bild, etwa zum Teilen oder als Vorschau.
Future<ui.Image> renderDrawing(List<UserStroke> strokes, double side) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, side, side));
  GridPaperPainter(cell: side / 16).paint(canvas, Size(side, side));
  _StrokesPainter(strokes).paint(canvas, Size(side, side));
  return recorder.endRecording().toImage(side.round(), side.round());
}
