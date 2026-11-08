import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wish_item.dart';
import '../../services/money_format.dart';
import '../../services/time_format.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../../widgets/money_bag_nav.dart';
import '../../widgets/wish_card.dart';
import '../check/check_flow_screen.dart';
import '../decision/decision_screen.dart';
import '../shell/app_shell.dart';
import '../vault/vault_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(String? name) {
    final h = clock.now().hour;
    final part = h < 5
        ? 'Gute Nacht'
        : h < 11
        ? 'Guten Morgen'
        : h < 17
        ? 'Hallo'
        : 'Guten Abend';
    return name == null || name.trim().isEmpty ? part : '$part, ${name.trim()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savings = ref.watch(savingsProvider);
    final waiting = ref.watch(waitingWishesProvider);
    final ripe = ref.watch(ripeWishesProvider);
    final settings = ref.watch(settingsProvider);
    final upcoming = ref.watch(upcomingExperiencesProvider);
    final now = clock.now();

    final waitingTotal = waiting.fold<int>(0, (s, w) => s + w.priceCents);
    final nextReminder = waiting
        .where((w) => w.remindAt != null && w.remindAt!.isAfter(now))
        .map((w) => w.remindAt!)
        .fold<DateTime?>(null, (min, d) => min == null || d.isBefore(min) ? d : min);

    final headline = savings.totalCents == 0
        ? 'Erst merken, dann entscheiden.'
        : ripe.isNotEmpty
        ? '${ripe.length == 1 ? 'Ein Wunsch ist' : '${ripe.length} Wünsche sind'} reif.'
        : 'Dein Tresor wächst.';

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(settings.userName), style: DgType.meta),
                    const SizedBox(height: 2),
                    Text(headline, style: DgType.h1),
                  ],
                ),
              ),
              BackIconButton(
                icon: DgIcons.moneyBag,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const VaultScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HeroCard(savings: savings, settings: settings),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${waiting.length}',
                  label: waiting.length == 1 ? 'wartet' : 'warten',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  value: MoneyFormat.euro(waitingTotal),
                  label: 'auf der Liste',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  value: nextReminder == null
                      ? '–'
                      : TimeFormat.compact(nextReminder.difference(now)),
                  label: 'bis Erinnerung',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (ripe.isNotEmpty) ...[
            SectionHeader(
              'Reif zur Entscheidung',
              action: 'Alle ansehen',
              onAction: () =>
                  ref.read(shellTabProvider.notifier).set(ShellTab.wishlist),
            ),
            const SizedBox(height: 10),
            for (final w in ripe.take(3)) ...[
              WishCard(
                item: w,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DecisionScreen(wishId: w.id),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
          ],
          SurfaceCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CheckFlowScreen(standalone: true),
              ),
            ),
            child: Row(
              children: [
                const Icon(DgIcons.check, color: DgColors.copper),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Schnell-Check', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('5 Fragen, 30 Sekunden', style: DgType.meta.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(DgIcons.chevron, color: DgColors.copper),
              ],
            ),
          ),
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final e in upcoming.take(2)) _AnticipationBanner(item: e),
          ],
          if (waiting.isEmpty && ripe.isEmpty && savings.totalCents == 0) ...[
            const SizedBox(height: 10),
            const EmptyState(
              icon: DgIcons.sparkle,
              title: 'Noch keine Wünsche auf Reife.',
              body:
                  'Wenn dich das nächste Mal etwas anlacht, tipp auf Plus. Dagobert merkt es sich und erinnert dich, wenn der Kopf wieder kühl ist.',
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.savings, required this.settings});

  final Savings savings;
  final dynamic settings;

  @override
  Widget build(BuildContext context) {
    final goalCents = settings.hasGoal ? settings.savingsGoalCents as int : null;
    final progress = goalCents == null
        ? null
        : (savings.totalCents / goalCents).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        gradient: DgColors.heroGradient,
        borderRadius: BorderRadius.circular(DgRadius.card),
        boxShadow: DgShadow.orangeGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'GESPART DURCH VERZICHT',
                  style: DgType.label.copyWith(
                    color: DgColors.white,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Icon(DgIcons.euro, color: DgColors.white, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          AmountText(
            savings.totalCents,
            animate: true,
            style: DgType.display.copyWith(
              color: DgColors.white,
              fontSize: 44,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            savings.hours == null
                ? (savings.count == 0
                      ? 'Jeder Verzicht landet hier.'
                      : '${savings.count} ${savings.count == 1 ? 'Verzicht' : 'Verzichte'}')
                : '${WorkHours.format(savings.hours)} Arbeit zurückgewonnen',
            style: DgType.body.copyWith(
              color: DgColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sparziel: ${settings.savingsGoalTitle}',
                    style: DgType.label.copyWith(
                      color: DgColors.white,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(progress * 100).round()} %',
                  style: DgType.label.copyWith(
                    color: DgColors.white,
                    fontSize: 13,
                    fontFeatures: DgType.tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: DgColors.white.withValues(alpha: 0.35),
                color: DgColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnticipationBanner extends StatelessWidget {
  const _AnticipationBanner({required this.item});

  final WishItem item;

  @override
  Widget build(BuildContext context) {
    final left = item.experienceDate!.difference(clock.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DgColors.goldDust,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(DgIcons.calendar, size: 20, color: DgColors.espresso),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${TimeFormat.daysLeft(left)} ',
                      style: DgType.bodyStrong.copyWith(fontSize: 14),
                    ),
                    TextSpan(
                      text: 'bis ${item.title}',
                      style: DgType.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text('Vorfreude', style: DgType.label.copyWith(color: DgColors.cocoa)),
          ],
        ),
      ),
    );
  }
}
