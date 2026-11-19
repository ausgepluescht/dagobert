// Werkzeug, kein echter Test: rendert alle Figuren als Kontaktbögen, um sie
// anzuschauen. Läuft nur mit
//   flutter test test/render_figures_test.dart --dart-define=RENDER_FIGURES=true --dart-define=RENDER_OUT=build/figures
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flipo/data/lessons.dart';
import 'package:flipo/paint/figure_painter.dart';
import 'package:flipo/paint/grid_paper_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _enabled = bool.fromEnvironment('RENDER_FIGURES');
const _out = String.fromEnvironment('RENDER_OUT', defaultValue: 'build/figures');

void main() {
  test('Kontaktbögen rendern', () async {
    const cell = 300.0;
    const cols = 3;
    for (final lesson in allLessons) {
      final rows = (lesson.figures.length / cols).ceil();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(cell * cols, cell * rows);
      const GridPaperPainter(cell: 25).paint(canvas, size);
      for (var i = 0; i < lesson.figures.length; i++) {
        final x = (i % cols) * cell, y = (i ~/ cols) * cell;
        canvas.save();
        canvas.translate(x, y);
        canvas.drawRect(const Rect.fromLTWH(0, 0, cell, cell), Paint()..color = const Color(0x22000000)..style = PaintingStyle.stroke);
        FigurePainter(lesson.figures[i], padding: 20).paint(canvas, const Size(cell, cell));
        canvas.restore();
      }
      final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$_out/${lesson.id}.png')..createSync(recursive: true);
      file.writeAsBytesSync(bytes!.buffer.asUint8List());
    }
  }, skip: !_enabled);
}
