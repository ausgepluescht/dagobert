import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Ring, der sich bis zur Erinnerung füllt. Golden, wenn reif.
class RipenessRing extends StatelessWidget {
  const RipenessRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 48,
    this.color,
    this.ripe = false,
  });

  final double progress;
  final Widget child;
  final double size;
  final Color? color;
  final bool ripe;

  @override
  Widget build(BuildContext context) {
    final ringColor = ripe ? DgColors.gold : (color ?? DgColors.orange);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: ripe ? 1 : progress.clamp(0, 1),
          color: ringColor,
          track: DgColors.sand,
          stroke: size * 0.11,
        ),
        child: Center(
          child: Container(
            width: size - size * 0.22 - 2,
            height: size - size * 0.22 - 2,
            decoration: const BoxDecoration(
              color: DgColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final paintTrack = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final paintArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, paintTrack);
    if (progress > 0) {
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * progress, false, paintArc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.stroke != stroke;
}
