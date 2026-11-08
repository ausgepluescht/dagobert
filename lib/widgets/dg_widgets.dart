import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Warmweiße Fläche mit Sand-Rahmen.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = DgColors.warmWhite,
    this.borderColor = DgColors.sand,
    this.shadow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(DgRadius.card),
      border: Border.all(color: borderColor),
      boxShadow: shadow ? DgShadow.card : null,
    );
    if (onTap == null) {
      return Container(decoration: decoration, padding: padding, child: child);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DgRadius.card),
        child: Ink(
          decoration: decoration,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            title,
            style: DgType.title.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

/// Leerer Zustand als Einladung: Illustration, Satz, CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: DgColors.goldDust,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: DgColors.copper),
          ),
          const SizedBox(height: 18),
          Text(title, style: DgType.title, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            body,
            style: DgType.meta.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kleines Kennzahl-Kästchen.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: DgType.bodyStrong.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: DgType.tabular,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: DgType.meta.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 1–5-Skala als fünf Kacheln (Wunsch-Thermometer).
class DesireSlider extends StatelessWidget {
  const DesireSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = DgColors.orange,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final Color color;

  static const labels = ['Kaum', 'Etwas', 'Schon', 'Sehr', 'Unbedingt'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= 5; i++) ...[
              if (i > 1) const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value != null && i <= value!,
                  label: '$i von 5, ${labels[i - 1]}',
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: 40,
                      decoration: BoxDecoration(
                        color: value != null && i <= value!
                            ? color
                            : DgColors.warmWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: value != null && i <= value!
                            ? null
                            : Border.all(color: DgColors.sand),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kaum', style: DgType.meta.copyWith(fontSize: 11)),
            Text(
              value == null ? 'Tippe zum Einschätzen' : labels[value! - 1],
              style: DgType.label.copyWith(color: DgColors.copper),
            ),
            Text('Unbedingt', style: DgType.meta.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class BackIconButton extends StatelessWidget {
  const BackIconButton({super.key, this.icon = Icons.arrow_back_ios_new_rounded, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DgColors.warmWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DgColors.sand),
          ),
          child: Icon(icon, size: 18, color: DgColors.cocoa),
        ),
      ),
    );
  }
}
