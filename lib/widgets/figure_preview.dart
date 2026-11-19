import 'package:flutter/material.dart';

import '../model/figure.dart';
import '../paint/figure_painter.dart';
import '../paint/grid_paper_painter.dart';
import '../theme/palette.dart';

/// Kleines Vorschaubild einer Figur auf kariertem Papier.
class FigurePreview extends StatelessWidget {
  const FigurePreview(this.figure, {super.key, this.size = 72, this.grid = true, this.padding = 6});

  final Figure figure;
  final double size;
  final bool grid;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          painter: grid ? GridPaperPainter(cell: size / 6, lineColor: Palette.gridLine, background: Palette.paperDeep) : null,
          foregroundPainter: FigurePainter(figure, padding: padding),
        ),
      ),
    );
  }
}
