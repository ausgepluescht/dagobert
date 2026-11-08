import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wish_item.dart';
import '../services/check_questions.dart';
import '../services/time_format.dart';
import '../services/work_hours.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'amount_text.dart';
import 'dg_icons.dart';
import 'ripeness_ring.dart';

IconData categoryIcon(WishCategory? c) => switch (c) {
  WishCategory.household => DgIcons.household,
  WishCategory.tech => DgIcons.tech,
  WishCategory.clothing => DgIcons.clothing,
  WishCategory.leisure => DgIcons.leisure,
  WishCategory.travel => DgIcons.travel,
  WishCategory.gift => DgIcons.gift,
  WishCategory.other => DgIcons.other,
  null => DgIcons.sparkle,
};

String? linkHost(String? url) {
  if (url == null) return null;
  final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
  final host = uri?.host;
  if (host == null || host.isEmpty) return null;
  return host.startsWith('www.') ? host.substring(4) : host;
}

class WishCard extends ConsumerWidget {
  const WishCard({super.key, required this.item, this.onTap});

  final WishItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rate = ref.watch(hourlyRateProvider);
    final now = clock.now();
    final ripe = item.isRipe(now);
    final hours = WorkHours.hoursFor(item.priceCents, rate);
    final isNeed = item.type == WishType.need;
    final ringColor = isNeed ? DgColors.calmBlue : DgColors.orange;
    final host = linkHost(item.url);

    final metaParts = <String>[
      if (hours != null) '${WorkHours.format(hours)} Arbeit',
      TimeFormat.since(item.waitingSince(now)),
    ];

    return Material(
      color: DgColors.white,
      borderRadius: BorderRadius.circular(DgRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DgRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DgRadius.card),
            border: Border.all(
              color: ripe ? DgColors.gold : DgColors.sand,
              width: ripe ? 2 : 1,
            ),
            boxShadow: DgShadow.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                RipenessRing(
                  progress: item.ripeness(now),
                  ripe: ripe,
                  color: ringColor,
                  child: Icon(
                    categoryIcon(item.category),
                    size: 20,
                    color: isNeed ? DgColors.calmBlue : DgColors.copper,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: DgType.bodyStrong,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(metaParts.join(' · '), style: DgType.meta),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          TypeChip(type: item.type),
                          if (item.checkAnswers.isNotEmpty)
                            MetaChip(
                              text:
                                  '★ ${CheckQuestions.formatScore(item.checkScore)} / 5',
                            ),
                          if (ripe)
                            const MetaChip(
                              text: 'Reif',
                              background: DgColors.gold,
                              color: DgColors.espresso,
                            )
                          else if (item.remindAt != null)
                            MetaChip(
                              text:
                                  'Erinnerung ${TimeFormat.until(item.remindAt!.difference(now))}',
                            ),
                          if (host != null)
                            MetaChip(
                              text: host,
                              icon: DgIcons.link,
                              color: DgColors.copper,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AmountText(item.priceCents),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type});

  final WishType type;

  @override
  Widget build(BuildContext context) {
    final need = type == WishType.need;
    return MetaChip(
      text: type.label,
      background: need ? DgColors.blueTint : DgColors.goldDust,
      color: need ? DgColors.blueText : DgColors.espresso,
      bordered: false,
    );
  }
}

class MetaChip extends StatelessWidget {
  const MetaChip({
    super.key,
    required this.text,
    this.icon,
    this.background = DgColors.warmWhite,
    this.color = DgColors.cocoa,
    this.bordered = true,
  });

  final String text;
  final IconData? icon;
  final Color background;
  final Color color;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DgRadius.chip),
        border: bordered ? Border.all(color: DgColors.sand) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: DgType.label.copyWith(color: color)),
        ],
      ),
    );
  }
}
