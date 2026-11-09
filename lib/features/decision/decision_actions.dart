import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wish_item.dart';
import '../../services/money_format.dart';
import '../../services/reminder_policy.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../shell/app_shell.dart';
import 'buy_sheet.dart';

/// Gemeinsame Aktionen für Karte, Swipe und Entscheidungs-Screen.
abstract final class DecisionActions {
  /// Verzichten mit Münzflug und Undo-Snackbar.
  static Future<void> skip(
    BuildContext context,
    WidgetRef ref,
    WishItem item, {
    Offset? origin,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final coins = ref.read(coinBurstProvider);
    final size = MediaQuery.of(context).size;
    final from = origin ?? Offset(size.width / 2, size.height / 2);
    final before = ref.read(savingsProvider).totalCents;
    final updated = await ref.read(wishesProvider.notifier).skip(item.id);
    if (updated == null) return;
    coins.burst(from: from, coins: _coinsFor(item.priceCents));

    final rate = ref.read(hourlyRateProvider);
    final hoursPerDay = ref.read(hoursPerDayProvider);
    final hours = WorkHours.hoursFor(item.priceCents, rate);
    final after = before + item.priceCents;
    final milestone = _crossedMilestone(before, after);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(
          milestone != null
              ? 'Meilenstein: ${MoneyFormat.euro(milestone)} im Tresor. ${item.title} verzichtet.'
              : hours == null
              ? '${MoneyFormat.euro(item.priceCents)} bleiben im Tresor.'
              : '${MoneyFormat.euro(item.priceCents)} bleiben im Tresor. Das sind ${WorkDays.formatWithDays(hours, hoursPerDay).replaceFirst('≈ ', '')} Lebenszeit.',
        ),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => ref.read(wishesProvider.notifier).restore(item.id),
        ),
      ),
    );
  }

  /// Gekauft: optional tatsächlicher Preis und Erlebnis-Datum.
  static Future<void> buy(
    BuildContext context,
    WidgetRef ref,
    WishItem item,
  ) async {
    final result = await showBuySheet(context, item);
    if (result == null) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(wishesProvider.notifier)
        .buy(
          item.id,
          paidCents: result.paidCents,
          experienceDate: result.experienceDate,
        );
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(
          result.experienceDate != null
              ? 'Gekauft. Jetzt kommt das Beste: die Vorfreude.'
              : 'Bewusst entschieden. In 30 Tagen fragt Dagobert, ob es das wert war.',
        ),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => ref.read(wishesProvider.notifier).restore(item.id),
        ),
      ),
    );
  }

  /// Weiter reifen lassen: Auswahl des neuen Timers.
  static Future<bool> snooze(
    BuildContext context,
    WidgetRef ref,
    WishItem item,
  ) async {
    final option = await showModalBottomSheet<ReminderOption>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewPaddingOf(ctx).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weiter reifen lassen', style: DgType.h1),
              const SizedBox(height: 4),
              Text(
                'Wann soll Dagobert wieder fragen?',
                style: DgType.meta,
              ),
              const SizedBox(height: 16),
              for (final o in ReminderOption.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_rounded, color: DgColors.copper),
                  title: Text(o.sentence[0].toUpperCase() + o.sentence.substring(1),
                      style: DgType.bodyStrong.copyWith(fontSize: 15)),
                  onTap: () => Navigator.of(ctx).pop(o),
                ),
            ],
          ),
        ),
      ),
    );
    if (option == null) return false;
    await ref.read(wishesProvider.notifier).snooze(item.id, option);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Gut. Dagobert meldet sich ${option.sentence} noch einmal.'),
          ),
        );
    }
    return true;
  }

  static Future<bool> confirmDelete(BuildContext context, WidgetRef ref, WishItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eintrag löschen?'),
        content: const Text(
          'Löschen ist für Fehleinträge gedacht und zählt nicht als gespart. Wenn du bewusst verzichtest, nimm „Verzichten“.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: DgColors.brick),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    await ref.read(wishesProvider.notifier).delete(item.id);
    return true;
  }

  static int _coinsFor(int cents) {
    if (cents < 2000) return 5;
    if (cents < 10000) return 7;
    if (cents < 50000) return 9;
    return 12;
  }

  static const milestonesCents = [10000, 25000, 50000, 100000, 250000, 500000];

  static int? _crossedMilestone(int before, int after) {
    for (final m in milestonesCents.reversed) {
      if (before < m && after >= m) return m;
    }
    return null;
  }
}
