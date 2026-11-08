import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wish_item.dart';
import '../../services/money_format.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../../widgets/wish_card.dart';
import '../add_wish/add_wish_sheet.dart';
import '../decision/decision_actions.dart';
import '../decision/decision_screen.dart';
import '../vault/vault_screen.dart';

enum WishFilter { all, need, want }

enum WishSort {
  longestWaiting('Am längsten wartend'),
  price('Preis'),
  workHours('Arbeitsstunden'),
  nextReminder('Nächste Erinnerung');

  const WishSort(this.label);
  final String label;
}

class WishlistFilterNotifier extends Notifier<WishFilter> {
  @override
  WishFilter build() => WishFilter.all;
  void set(WishFilter f) => state = f;
}

class WishlistSortNotifier extends Notifier<WishSort> {
  @override
  WishSort build() => WishSort.longestWaiting;
  void set(WishSort s) => state = s;
}

final wishlistFilterProvider =
    NotifierProvider<WishlistFilterNotifier, WishFilter>(
      WishlistFilterNotifier.new,
    );
final wishlistSortProvider = NotifierProvider<WishlistSortNotifier, WishSort>(
  WishlistSortNotifier.new,
);

final sortedWishlistProvider = Provider<List<WishItem>>((ref) {
  final filter = ref.watch(wishlistFilterProvider);
  final sort = ref.watch(wishlistSortProvider);
  final rate = ref.watch(hourlyRateProvider);
  final items = ref.watch(waitingWishesProvider).where((w) {
    return switch (filter) {
      WishFilter.all => true,
      WishFilter.need => w.type == WishType.need,
      WishFilter.want => w.type == WishType.want,
    };
  }).toList();
  final far = DateTime(2200);
  items.sort((a, b) {
    switch (sort) {
      case WishSort.longestWaiting:
        return a.createdAt.compareTo(b.createdAt);
      case WishSort.price:
        return b.priceCents.compareTo(a.priceCents);
      case WishSort.workHours:
        final ha = WorkHours.hoursFor(a.priceCents, rate) ?? a.priceCents.toDouble();
        final hb = WorkHours.hoursFor(b.priceCents, rate) ?? b.priceCents.toDouble();
        return hb.compareTo(ha);
      case WishSort.nextReminder:
        return (a.remindAt ?? far).compareTo(b.remindAt ?? far);
    }
  });
  // Reife immer oben.
  final now = clock.now();
  final ripe = items.where((w) => w.isRipe(now)).toList();
  final rest = items.where((w) => !w.isRipe(now)).toList();
  return [...ripe, ...rest];
});

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(sortedWishlistProvider);
    final filter = ref.watch(wishlistFilterProvider);
    final sort = ref.watch(wishlistSortProvider);
    final savings = ref.watch(savingsProvider);
    final allWaiting = ref.watch(waitingWishesProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                const Expanded(child: Text('Merkliste', style: DgType.h1)),
                Material(
                  color: DgColors.greenTint,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const VaultScreen()),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            DgIcons.skipped,
                            size: 16,
                            color: DgColors.pineGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${MoneyFormat.euro(savings.totalCents)} gespart',
                            style: DgType.label.copyWith(
                              color: DgColors.pineGreen,
                              fontSize: 13,
                              fontFeatures: DgType.tabular,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Alle',
                          selected: filter == WishFilter.all,
                          onTap: () => ref
                              .read(wishlistFilterProvider.notifier)
                              .set(WishFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Brauche ich',
                          selected: filter == WishFilter.need,
                          selectedColor: DgColors.calmBlue,
                          onTap: () => ref
                              .read(wishlistFilterProvider.notifier)
                              .set(WishFilter.need),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Will ich',
                          selected: filter == WishFilter.want,
                          onTap: () => ref
                              .read(wishlistFilterProvider.notifier)
                              .set(WishFilter.want),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<WishSort>(
                  tooltip: 'Sortieren',
                  initialValue: sort,
                  onSelected: (s) =>
                      ref.read(wishlistSortProvider.notifier).set(s),
                  itemBuilder: (_) => [
                    for (final s in WishSort.values)
                      PopupMenuItem(value: s, child: Text(s.label)),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const BackIconButton(icon: DgIcons.sort, onPressed: null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.only(bottom: 110),
                    children: [
                      EmptyState(
                        icon: DgIcons.sparkle,
                        title: allWaiting.isEmpty
                            ? 'Noch keine Wünsche auf Reife.'
                            : 'Hier ist gerade nichts.',
                        body: allWaiting.isEmpty
                            ? 'Trag ein, was dich anlacht. Dagobert zeigt dir, wie viele Arbeitsstunden es kostet, und erinnert dich später.'
                            : 'In dieser Kategorie wartet nichts. Wechsle den Filter oder merk dir etwas Neues.',
                        actionLabel: 'Wunsch merken',
                        onAction: () => showAddWishSheet(context),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return _SwipeableWish(
                        key: ValueKey(item.id),
                        item: item,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = DgColors.orange,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedColor : DgColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? selectedColor : DgColors.sand),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: DgType.label.copyWith(
              fontSize: 13,
              color: selected ? DgColors.white : DgColors.espresso,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Swipe links = Verzichten, Swipe rechts = Gekauft. Beides mit Undo.
class _SwipeableWish extends ConsumerWidget {
  const _SwipeableWish({super.key, required this.item});

  final WishItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('swipe-${item.id}'),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.45,
        DismissDirection.startToEnd: 0.45,
      },
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: DgColors.copper,
        icon: DgIcons.bought,
        label: 'Gekauft',
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: DgColors.savingsGreen,
        icon: DgIcons.moneyBag,
        label: 'Verzichten',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await DecisionActions.skip(context, ref, item, origin: _cardCenter(context));
        } else {
          await DecisionActions.buy(context, ref, item);
        }
        // Die Liste rendert den Eintrag nicht mehr, daher kein echtes Dismiss.
        return false;
      },
      child: WishCard(
        item: item,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => DecisionScreen(wishId: item.id)),
        ),
      ),
    );
  }

  Offset? _cardCenter(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final left = alignment == Alignment.centerLeft;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (left) ...[
            Icon(icon, color: DgColors.white),
            const SizedBox(width: 8),
          ],
          Text(label, style: DgType.label.copyWith(color: DgColors.white, fontSize: 13)),
          if (!left) ...[
            const SizedBox(width: 8),
            Icon(icon, color: DgColors.white),
          ],
        ],
      ),
    );
  }
}
