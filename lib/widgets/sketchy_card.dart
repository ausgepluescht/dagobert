import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Karte mit handgezeichnetem Rand: leicht wackelige Linien, ein Hauch Drehung.
class SketchyCard extends StatelessWidget {
  const SketchyCard({
    super.key,
    required this.child,
    this.seed = 0,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = Palette.paper,
    this.borderColor = Palette.ink,
    this.shadow = true,
    this.tilt = true,
  });

  final Widget child;
  final int seed;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final bool shadow;
  final bool tilt;

  @override
  Widget build(BuildContext context) {
    final rnd = math.Random(seed);
    final angle = tilt ? (rnd.nextDouble() - 0.5) * 0.018 : 0.0;
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        painter: _SketchyBorderPainter(seed: seed, color: color, borderColor: borderColor, shadow: shadow),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class _SketchyBorderPainter extends CustomPainter {
  const _SketchyBorderPainter({required this.seed, required this.color, required this.borderColor, required this.shadow});

  final int seed;
  final Color color;
  final Color borderColor;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = sketchyRect(Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3), seed);
    if (shadow) {
      canvas.save();
      canvas.translate(3, 4);
      canvas.drawPath(path, Paint()..color = Palette.markerGrey.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 3..strokeJoin = StrokeJoin.round);
      canvas.restore();
    }
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SketchyBorderPainter old) =>
      old.seed != seed || old.color != color || old.borderColor != borderColor || old.shadow != shadow;
}

/// Rechteck mit leicht zittrigen Kanten und minimal überzogenen Ecken.
Path sketchyRect(Rect r, int seed, {double wobble = 1.2}) {
  final rnd = math.Random(seed);
  double j() => (rnd.nextDouble() - 0.5) * 2 * wobble;
  final path = Path();
  final corners = [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft];
  for (var i = 0; i < 4; i++) {
    final a = corners[i];
    final b = corners[(i + 1) % 4];
    final start = Offset(a.dx + j(), a.dy + j());
    final mid = Offset.lerp(a, b, 0.5)! + Offset(j() * 1.6, j() * 1.6);
    final end = Offset(b.dx + j(), b.dy + j());
    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }
    path.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
  }
  path.close();
  return path;
}

/// Handgezeichnete Unterstreichung für Überschriften.
class SketchyUnderline extends StatelessWidget {
  const SketchyUnderline({super.key, required this.width, this.color = Palette.markerRed, this.height = 6});

  final double width;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _UnderlinePainter(color));
}

class _UnderlinePainter extends CustomPainter {
  const _UnderlinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.3, 0, size.width * 0.55, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height, size.width, size.height * 0.4);
    canvas.drawPath(
      p,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_UnderlinePainter old) => old.color != color;
}
