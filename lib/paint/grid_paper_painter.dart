import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Kariertes Papier, bewusst zurückhaltend: feine Linien, viel Luft.
class GridPaperPainter extends CustomPainter {
  const GridPaperPainter({this.cell = 24, this.lineColor = Palette.gridLine, this.background = Palette.paper});

  final double cell;
  final Color lineColor;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var x = cell; x < size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = cell; y < size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPaperPainter old) =>
      old.cell != cell || old.lineColor != lineColor || old.background != background;
}
