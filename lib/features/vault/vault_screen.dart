import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/wish_item.dart';
import '../../services/money_format.dart';
import '../../services/time_format.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../decision/decision_actions.dart';
import '../decision/decision_screen.dart';
import '../profile/goal_sheet.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savings = ref.watch(savingsProvider);
    final skipped = ref.watch(skippedWishesProvider);
    final settings = ref.watch(settingsProvider);
    final hoursPerDay = ref.watch(hoursPerDayProvider);
    final now = clock.now();

    // Letzte 6 Monate
    final months = List.generate(6, (i) => DateTime(now.year, now.month - 5 + i));
    final perMonth = <int>[for (final _ in months) 0];
    for (final w in skipped) {
      final d = w.decidedAt ?? w.updatedAt;
      for (var i = 0; i < months.length; i++) {
        if (d.year == months[i].year && d.month == months[i].month) perMonth[i] += w.priceCents;
      }
    }
    final maxMonth = perMonth.fold<int>(0, (m, v) => v > m ? v : m);

    // Häufigster Auslöser
    final triggerCounts = <WishTrigger, int>{};
    for (final w in skipped) {
      if (w.trigger != null) triggerCounts[w.trigger!] = (triggerCounts[w.trigger!] ?? 0) + 1;
    }
    final topTrigger = triggerCounts.entries.fold<MapEntry<WishTrigger, int>?>(
      null,
      (best, e) => best == null || e.value > best.value ? e : best,
    );

    final nextMilestone = DecisionActions.milestonesCents.where((m) => m > savings.totalCents).firstOrNull;

    final goalCents = settings.hasGoal ? settings.savingsGoalCents! : null;
    final goalProgress = goalCents == null ? null : (savings.totalCents / goalCents).clamp(0.0, 1.0);
    String? pace;
    if (goalCents != null && savings.totalCents > 0 && skipped.isNotEmpty) {
      final first = skipped.last.decidedAt ?? skipped.last.updatedAt;
      final days = now.difference(first).inDays.clamp(1, 100000);
      final perDay = savings.totalCents / days;
      final remaining = goalCents - savings.totalCents;
      if (remaining > 0 && perDay > 0) {
        final daysLeft = (remaining / perDay).round();
        pace = daysLeft < 45
            ? 'Beim aktuellen Tempo in etwa $daysLeft Tagen.'
            : 'Beim aktuellen Tempo in etwa ${(daysLeft / 30).round()} Monaten.';
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const BackIconButton(),
                  const Expanded(
                    child: Center(child: Text('Tresor', style: DgType.title)),
                  ),
                  BackIconButton(
                    icon: DgIcons.edit,
                    onPressed: () => showGoalSheet(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        _BagIllustration(count: savings.count),
                        const SizedBox(height: 10),
                        AmountText(
                          savings.totalCents,
                          animate: true,
                          style: DgType.display.copyWith(fontSize: 44, color: DgColors.pineGreen),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          savings.hours == null
                              ? (savings.count == 0
                                    ? 'Noch leer. Der erste Verzicht füllt ihn.'
                                    : '${savings.count} bewusste ${savings.count == 1 ? 'Entscheidung' : 'Entscheidungen'}')
                              : '${WorkDays.formatWithDays(savings.hours, hoursPerDay)} Lebenszeit behalten',
                          style: DgType.meta.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SurfaceCard(
                    onTap: () => showGoalSheet(context),
                    child: goalCents == null
                        ? Row(
                            children: [
                              const Icon(DgIcons.goal, color: DgColors.copper),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Wofür sparst du?', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Gib dem Gesparten ein Ziel, am besten ein Erlebnis. Dann fließt jeder Verzicht irgendwohin.',
                                      style: DgType.meta.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(DgIcons.chevron, color: DgColors.copper),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(DgIcons.goal, size: 18, color: DgColors.copper),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Sparziel: ${settings.savingsGoalTitle}',
                                        style: DgType.bodyStrong.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(
                                    '${MoneyFormat.euro(savings.totalCents)} / ${MoneyFormat.euro(goalCents)}',
                                    style: DgType.label.copyWith(color: DgColors.cocoa, fontSize: 12, fontFeatures: DgType.tabular),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: SizedBox(
                                  height: 10,
                                  child: Stack(
                                    children: [
                                      Container(color: DgColors.sand),
                                      FractionallySizedBox(
                                        widthFactor: goalProgress,
                                        child: Container(decoration: const BoxDecoration(gradient: DgColors.heroGradient)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                goalProgress! >= 1
                                    ? 'Ziel erreicht. Jetzt wird es Zeit, es einzulösen.'
                                    : 'Noch ${MoneyFormat.euro(goalCents - savings.totalCents)}. ${pace ?? ''}'.trim(),
                                style: DgType.meta.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                  if (nextMilestone != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(DgIcons.star, size: 16, color: DgColors.gold),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Nächster Meilenstein: ${MoneyFormat.euro(nextMilestone)}. Noch ${MoneyFormat.euro(nextMilestone - savings.totalCents)}.',
                            style: DgType.meta.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(child: Text('Letzte 6 Monate', style: DgType.title)),
                      Text('Verzichte pro Monat', style: DgType.meta.copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < months.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (perMonth[i] > 0)
                                  Text(
                                    MoneyFormat.euro(perMonth[i]),
                                    style: DgType.label.copyWith(fontSize: 10, color: DgColors.cocoa, fontFeatures: DgType.tabular),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 3),
                                Container(
                                  height: maxMonth == 0 ? 6 : (6 + 54 * perMonth[i] / maxMonth),
                                  decoration: BoxDecoration(
                                    color: i == months.length - 1 ? DgColors.orange : DgColors.sand,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM', 'de_DE').format(months[i]).replaceAll('.', ''),
                                  style: DgType.label.copyWith(
                                    fontSize: 10,
                                    color: i == months.length - 1 ? DgColors.copper : DgColors.cocoa,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('Verzichtet', style: DgType.title),
                  const SizedBox(height: 10),
                  if (skipped.isEmpty)
                    const EmptyState(
                      icon: DgIcons.moneyBag,
                      title: 'Hier landet jeder Verzicht.',
                      body: 'Wisch einen Wunsch in der Merkliste nach links oder tipp im Detail auf „Verzichten“.',
                    ),
                  for (final w in skipped)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SurfaceCard(
                        color: DgColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => DecisionScreen(wishId: w.id)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: DgColors.greenTint, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(DgIcons.skipped, size: 18, color: DgColors.pineGreen),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(w.title, style: DgType.bodyStrong.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      _relativeDay(w.decidedAt ?? w.updatedAt, now),
                                      TimeFormat.after((w.decidedAt ?? w.updatedAt).difference(w.createdAt)),
                                      if (w.trigger != null) 'Auslöser: ${w.trigger!.label}',
                                    ].join(' · '),
                                    style: DgType.meta.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${MoneyFormat.euro(w.priceCents)}',
                              style: DgType.amount.copyWith(fontSize: 15, color: DgColors.pineGreen),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (topTrigger != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: DgColors.goldDust, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Icon(DgIcons.star, size: 18, color: DgColors.espresso),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Häufigster Auslöser für Verzicht: ',
                                style: DgType.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                                children: [
                                  TextSpan(
                                    text: '${topTrigger.key.label} (${topTrigger.value} von ${skipped.where((w) => w.trigger != null).length})',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeDay(DateTime d, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'heute';
    if (diff == 1) return 'gestern';
    return DateFormat('d. MMM', 'de_DE').format(d);
  }
}

class _BagIllustration extends StatelessWidget {
  const _BagIllustration({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final coins = count.clamp(0, 3);
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [DgColors.goldDust, DgColors.white], stops: [0.0, 0.75]),
            ),
          ),
          const Icon(DgIcons.moneyBag, size: 86, color: DgColors.orange),
          if (coins >= 1) const Positioned(top: 6, right: 14, child: _Coin(size: 26)),
          if (coins >= 2) const Positioned(top: 32, left: 6, child: _Coin(size: 20)),
          if (coins >= 3) const Positioned(bottom: 14, right: 4, child: _Coin(size: 22)),
        ],
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DgColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: DgColors.white, width: 2),
      ),
      child: Text('€', style: DgType.label.copyWith(fontSize: size * 0.45)),
    );
  }
}
