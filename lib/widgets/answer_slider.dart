import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/wish_item.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Schieberegler mit drei Rastpunkten: Nein · Teils · Ja.
/// Wischen oder tippen. Farbe folgt der Antwort.
class AnswerSlider extends StatefulWidget {
  const AnswerSlider({super.key, required this.value, required this.onChanged});

  final CheckAnswer? value;
  final ValueChanged<CheckAnswer> onChanged;

  static Color colorFor(CheckAnswer? a) => switch (a) {
    CheckAnswer.yes => DgColors.savingsGreen,
    CheckAnswer.partly => DgColors.gold,
    CheckAnswer.no => DgColors.brick,
    null => DgColors.sand,
  };

  static Color tintFor(CheckAnswer? a) => switch (a) {
    CheckAnswer.yes => const Color(0xFFE6F5EC),
    CheckAnswer.partly => DgColors.goldDust,
    CheckAnswer.no => const Color(0xFFFBE4E1),
    null => DgColors.white,
  };

  @override
  State<AnswerSlider> createState() => _AnswerSliderState();
}

class _AnswerSliderState extends State<AnswerSlider> {
  double? _dragT;

  double _targetT(CheckAnswer? a) => switch (a) {
    CheckAnswer.no => 0,
    CheckAnswer.partly => 0.5,
    CheckAnswer.yes => 1,
    null => 0.5,
  };

  CheckAnswer _snap(double t) {
    if (t < 0.25) return CheckAnswer.no;
    if (t > 0.75) return CheckAnswer.yes;
    return CheckAnswer.partly;
  }

  void _commit(double t) {
    final a = _snap(t);
    if (a != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(a);
    }
    setState(() => _dragT = null);
  }

  @override
  Widget build(BuildContext context) {
    const height = 44.0;
    const knob = 36.0;
    final answered = widget.value != null;
    final color = AnswerSlider.colorFor(widget.value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final travel = width - knob - 8;
        final t = _dragT ?? _targetT(widget.value);
        return Semantics(
          slider: true,
          label: 'Antwort',
          value: widget.value?.label ?? 'noch offen',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _commit(((d.localPosition.dx - knob / 2 - 4) / travel).clamp(0.0, 1.0)),
            onHorizontalDragStart: (d) => setState(
              () => _dragT = ((d.localPosition.dx - knob / 2 - 4) / travel).clamp(0.0, 1.0),
            ),
            onHorizontalDragUpdate: (d) => setState(
              () => _dragT = ((d.localPosition.dx - knob / 2 - 4) / travel).clamp(0.0, 1.0),
            ),
            onHorizontalDragEnd: (_) => _commit(_dragT ?? t),
            onHorizontalDragCancel: () => setState(() => _dragT = null),
            child: SizedBox(
              height: height,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: height,
                    decoration: BoxDecoration(
                      color: answered ? color.withValues(alpha: 0.18) : DgColors.warmWhite,
                      borderRadius: BorderRadius.circular(height / 2),
                      border: Border.all(color: answered ? color : DgColors.sand),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Label('Nein', active: widget.value == CheckAnswer.no, color: DgColors.brick),
                          _Label('Ja', active: widget.value == CheckAnswer.yes, color: DgColors.pineGreen),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _dragT == null ? const Duration(milliseconds: 180) : Duration.zero,
                    curve: Curves.easeOut,
                    left: 4 + t * travel,
                    child: Container(
                      width: knob,
                      height: knob,
                      decoration: BoxDecoration(
                        color: answered ? color : DgColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: answered ? color : DgColors.sand, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x332A2118), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Icon(
                        switch (widget.value) {
                          CheckAnswer.yes => Icons.check_rounded,
                          CheckAnswer.no => Icons.close_rounded,
                          CheckAnswer.partly => Icons.remove_rounded,
                          null => Icons.drag_handle_rounded,
                        },
                        size: 20,
                        color: answered ? DgColors.white : DgColors.cocoa,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.active, required this.color});
  final String text;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DgType.label.copyWith(
        fontSize: 12,
        color: active ? color : DgColors.cocoa,
        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}
