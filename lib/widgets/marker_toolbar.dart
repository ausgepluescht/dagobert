import 'package:flutter/material.dart';

import '../model/stroke_spec.dart';
import '../theme/palette.dart';

/// Farb- und Strichstärkenauswahl im Stil einer Stifteablage.
class MarkerToolbar extends StatelessWidget {
  const MarkerToolbar({
    super.key,
    required this.color,
    required this.width,
    required this.onColor,
    required this.onWidth,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.canUndo,
    required this.canRedo,
  });

  final MarkerColor color;
  final MarkerWidth width;
  final ValueChanged<MarkerColor> onColor;
  final ValueChanged<MarkerWidth> onWidth;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onClear;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Palette.paper,
        border: Border(top: BorderSide(color: Palette.inkFaint)),
      ),
      child: Row(
        children: [
          // Stifteablage: schrumpft auf schmalen Geräten, statt überzulaufen.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in MarkerColor.values) ...[
                    _MarkerChip(color: c, selected: c == color, onTap: () => onColor(c)),
                    const SizedBox(width: 6),
                  ],
                  const SizedBox(width: 6),
                  _WidthPicker(width: width, onWidth: onWidth, color: Palette.of(color)),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Rückgängig',
            visualDensity: VisualDensity.compact,
            onPressed: canUndo ? onUndo : null,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: 'Wiederholen',
            visualDensity: VisualDensity.compact,
            onPressed: canRedo ? onRedo : null,
            icon: const Icon(Icons.redo_rounded),
          ),
          IconButton(
            tooltip: 'Blatt leeren',
            visualDensity: VisualDensity.compact,
            onPressed: canUndo ? onClear : null,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
    );
  }
}

/// Ein Marker, von oben gesehen: farbige Kappe, ausgewählt leicht herausgezogen.
class _MarkerChip extends StatelessWidget {
  const _MarkerChip({required this.color, required this.selected, required this.onTap});

  final MarkerColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(color);
    return Semantics(
      label: Palette.nameOf(color),
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 30,
          height: selected ? 44 : 36,
          decoration: BoxDecoration(
            color: c,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(10)),
            border: Border.all(color: selected ? Palette.ink : Colors.transparent, width: 2),
            boxShadow: selected
                ? [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 3))]
                : const [],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WidthPicker extends StatelessWidget {
  const _WidthPicker({required this.width, required this.onWidth, required this.color});

  final MarkerWidth width;
  final ValueChanged<MarkerWidth> onWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final w in MarkerWidth.values)
          Semantics(
            label: switch (w) { MarkerWidth.thin => 'Dünn', MarkerWidth.medium => 'Mittel', MarkerWidth.thick => 'Dick' },
            selected: w == width,
            button: true,
            child: GestureDetector(
              onTap: () => onWidth(w),
              child: Container(
                width: 30,
                height: 36,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: w == width ? Palette.ink : Colors.transparent, width: 1.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 4 + w.units * 3,
                  height: 4 + w.units * 3,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
