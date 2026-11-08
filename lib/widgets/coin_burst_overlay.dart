import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Steuert den Münzflug: Quelle → Geldsack.
class CoinBurstController extends ChangeNotifier {
  /// Position des Geldsacks (global), gesetzt vom Shell-Widget.
  final GlobalKey moneyBagKey = GlobalKey();

  CoinBurst? _pending;
  int _bagWiggle = 0;

  int get bagWiggle => _bagWiggle;

  /// Startet Münzen von [from] (globale Koordinaten) zum Geldsack.
  void burst({required Offset from, int coins = 8}) {
    _pending = CoinBurst(from: from, coins: coins, id: DateTime.now().microsecondsSinceEpoch);
    notifyListeners();
  }

  void wiggleBag() {
    _bagWiggle++;
    notifyListeners();
  }

  CoinBurst? takePending() {
    final p = _pending;
    _pending = null;
    return p;
  }

  Offset? bagCenter() {
    final ctx = moneyBagKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

class CoinBurst {
  const CoinBurst({required this.from, required this.coins, required this.id});
  final Offset from;
  final int coins;
  final int id;
}

/// Legt sich über die App und malt fliegende Münzen.
class CoinBurstOverlay extends StatefulWidget {
  const CoinBurstOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  final CoinBurstController controller;
  final Widget child;

  @override
  State<CoinBurstOverlay> createState() => _CoinBurstOverlayState();
}

class _CoinBurstOverlayState extends State<CoinBurstOverlay>
    with TickerProviderStateMixin {
  final _flights = <_Flight>[];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    for (final f in _flights) {
      f.controller.dispose();
    }
    super.dispose();
  }

  void _onController() {
    final burst = widget.controller.takePending();
    if (burst == null) return;
    final to = widget.controller.bagCenter();
    if (to == null) return;
    if (MediaQuery.of(context).disableAnimations) {
      widget.controller.wiggleBag();
      return;
    }
    final rnd = math.Random(burst.id);
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final coins = List.generate(burst.coins, (i) {
      final spread = Offset(
        (rnd.nextDouble() - 0.5) * 160,
        -40 - rnd.nextDouble() * 120,
      );
      return _Coin(
        delay: rnd.nextDouble() * 0.25,
        control: burst.from + spread,
        size: 14 + rnd.nextDouble() * 10,
        spin: (rnd.nextDouble() - 0.5) * 6,
      );
    });
    final flight = _Flight(
      controller: controller,
      from: burst.from,
      to: to,
      coins: coins,
    );
    setState(() => _flights.add(flight));
    HapticFeedback.mediumImpact();
    controller.forward().whenComplete(() {
      if (!mounted) return;
      widget.controller.wiggleBag();
      HapticFeedback.heavyImpact();
      setState(() => _flights.remove(flight));
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        for (final f in _flights)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: f.controller,
                builder: (context, _) => CustomPaint(
                  painter: _CoinPainter(f, f.controller.value),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Flight {
  _Flight({
    required this.controller,
    required this.from,
    required this.to,
    required this.coins,
  });
  final AnimationController controller;
  final Offset from;
  final Offset to;
  final List<_Coin> coins;
}

class _Coin {
  _Coin({
    required this.delay,
    required this.control,
    required this.size,
    required this.spin,
  });
  final double delay;
  final Offset control;
  final double size;
  final double spin;
}

class _CoinPainter extends CustomPainter {
  _CoinPainter(this.flight, this.t);

  final _Flight flight;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = DgColors.gold;
    final rim = Paint()
      ..color = DgColors.copper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final coin in flight.coins) {
      final local = ((t - coin.delay) / (1 - coin.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final eased = Curves.easeInQuad.transform(local);
      final p = _bezier(flight.from, coin.control, flight.to, eased);
      final scale = 1 - 0.5 * eased;
      final radius = coin.size / 2 * scale;
      final opacity = local > 0.9 ? (1 - (local - 0.9) / 0.1) : 1.0;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(coin.spin * eased);
      // Münze als leicht gekippte Ellipse
      final squash = 0.7 + 0.3 * math.cos(eased * math.pi * 3).abs();
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2 * squash,
        height: radius * 2,
      );
      canvas.drawOval(rect, gold..color = DgColors.gold.withValues(alpha: opacity));
      canvas.drawOval(rect, rim..color = DgColors.copper.withValues(alpha: opacity));
      final tp = TextPainter(
        text: TextSpan(
          text: '€',
          style: TextStyle(
            fontFamily: DgType.family,
            fontSize: radius * 1.2,
            fontWeight: FontWeight.w800,
            color: DgColors.espresso.withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  Offset _bezier(Offset a, Offset c, Offset b, double t) {
    final u = 1 - t;
    return a * (u * u) + c * (2 * u * t) + b * (t * t);
  }

  @override
  bool shouldRepaint(_CoinPainter old) => old.t != t;
}
