import 'package:flutter/material.dart';

import '../services/money_format.dart';
import '../theme/typography.dart';

/// Betrag mit tabellarischen Ziffern und optionalem Count-up.
class AmountText extends StatelessWidget {
  const AmountText(
    this.cents, {
    super.key,
    this.style,
    this.animate = false,
    this.duration = const Duration(milliseconds: 900),
  });

  final int cents;
  final TextStyle? style;
  final bool animate;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final effective = (style ?? DgType.amount).copyWith(
      fontFeatures: DgType.tabular,
    );
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!animate || reduceMotion) {
      return Text(MoneyFormat.euro(cents), style: effective);
    }
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: cents),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) =>
          Text(MoneyFormat.euro(value), style: effective),
    );
  }
}
