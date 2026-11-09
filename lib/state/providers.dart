import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/settings_repository.dart';
import '../data/wish_repository.dart';
import '../models/settings.dart';
import '../models/wish_item.dart';
import '../services/money_format.dart';
import '../services/notification_service.dart';
import '../services/reminder_policy.dart';
import '../services/time_format.dart';
import '../services/work_hours.dart';

/// Werden in main() mit echten Instanzen überschrieben.
final wishRepositoryProvider = Provider<WishRepository>(
  (ref) => throw UnimplementedError('wishRepositoryProvider not overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) =>
      throw UnimplementedError('settingsRepositoryProvider not overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NoopNotificationService(),
);

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> update(Settings Function(Settings) change) async {
    state = change(state);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> reset() async {
    state = const Settings(onboardingDone: true);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

/// Netto-Stundenlohn in Cent oder null.
final hourlyRateProvider = Provider<int?>((ref) {
  final s = ref.watch(settingsProvider);
  return WorkHours.hourlyRateCents(
    netMonthlyCents: s.netMonthlyCents,
    hoursPerWeek: s.hoursPerWeek,
  );
});

/// Stunden pro Arbeitstag (Wochenstunden / 5, sonst 8).
final hoursPerDayProvider = Provider<double>((ref) {
  final s = ref.watch(settingsProvider);
  return WorkDays.hoursPerDay(s.hoursPerWeek);
});

// ---------------------------------------------------------------------------
// Wishes
// ---------------------------------------------------------------------------

class WishesNotifier extends Notifier<List<WishItem>> {
  static const _uuid = Uuid();

  WishRepository get _repo => ref.read(wishRepositoryProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  List<WishItem> build() => _repo.all();

  void _reload() => state = _repo.all();

  Future<WishItem> add({
    required String title,
    required int priceCents,
    required WishType type,
    required ReminderOption reminder,
    WishCategory? category,
    WishTrigger? trigger,
    String? note,
    String? url,
    int? desire,
  }) async {
    final now = clock.now();
    final settings = ref.read(settingsProvider);
    final item = WishItem(
      id: _uuid.v4(),
      notificationId: _repo.nextNotificationId(),
      title: title.trim(),
      priceCents: priceCents,
      priceHistory: [PricePoint(cents: priceCents, at: now)],
      type: type,
      category: category,
      trigger: trigger,
      note: _blankToNull(note),
      url: _blankToNull(url),
      desireAtCreate: desire,
      createdAt: now,
      updatedAt: now,
      remindAt: ReminderPolicy.remindAtFor(
        now,
        reminder,
        windowStart: settings.reminderWindowStart,
        windowEnd: settings.reminderWindowEnd,
      ),
    );
    await _repo.put(item);
    _reload();
    await _schedule(item);
    return item;
  }

  Future<void> update(WishItem item) async {
    await _repo.put(item.copyWith(updatedAt: clock.now()));
    _reload();
  }

  Future<void> saveCheck(
    String id,
    Map<String, CheckAnswer> answers, {
    int? expectedUses,
  }) async {
    final item = _repo.byId(id);
    if (item == null) return;
    await _repo.put(
      item.copyWith(
        checkAnswers: answers,
        expectedUses: expectedUses,
        updatedAt: clock.now(),
      ),
    );
    _reload();
  }

  Future<void> setDesireAtDecision(String id, int value) async {
    final item = _repo.byId(id);
    if (item == null) return;
    await _repo.put(item.copyWith(desireAtDecision: value));
    _reload();
  }

  Future<void> updatePrice(String id, int newPriceCents) async {
    final item = _repo.byId(id);
    if (item == null) return;
    await _repo.put(
      item.copyWith(
        priceCents: newPriceCents,
        priceHistory: [
          ...item.priceHistory,
          PricePoint(cents: newPriceCents, at: clock.now()),
        ],
      ),
    );
    _reload();
  }

  /// Verzichten: zählt als gespart.
  Future<WishItem?> skip(String id) async {
    final item = _repo.byId(id);
    if (item == null) return null;
    final updated = item.copyWith(
      status: WishStatus.skipped,
      decidedAt: clock.now(),
      hourlyRateSnapshotCents: ref.read(hourlyRateProvider),
    );
    await _repo.put(updated);
    await _notifications.cancel(item.notificationId);
    _reload();
    return updated;
  }

  /// Gekauft: wird geloggt, zählt nicht als gespart.
  Future<WishItem?> buy(
    String id, {
    int? paidCents,
    DateTime? experienceDate,
  }) async {
    final item = _repo.byId(id);
    if (item == null) return null;
    final now = clock.now();
    final updated = item.copyWith(
      status: WishStatus.bought,
      decidedAt: now,
      decidedPriceCents: paidCents ?? item.priceCents,
      experienceDate: experienceDate,
      hourlyRateSnapshotCents: ref.read(hourlyRateProvider),
    );
    await _repo.put(updated);
    await _notifications.cancel(item.notificationId);
    if (ref.read(settingsProvider).notificationsEnabled) {
      await _notifications.scheduleWorthIt(
        updated,
        at: now.add(const Duration(days: 30)),
      );
    }
    _reload();
    return updated;
  }

  /// Weiter reifen lassen: neuer Timer.
  Future<void> snooze(String id, ReminderOption option) async {
    final item = _repo.byId(id);
    if (item == null) return;
    final settings = ref.read(settingsProvider);
    final updated = item.copyWith(
      remindAt: ReminderPolicy.remindAtFor(
        clock.now(),
        option,
        windowStart: settings.reminderWindowStart,
        windowEnd: settings.reminderWindowEnd,
      ),
      snoozeCount: item.snoozeCount + 1,
      status: WishStatus.waiting,
    );
    await _repo.put(updated);
    _reload();
    await _schedule(updated);
  }

  /// Undo nach Verzicht/Kauf: zurück auf "wartet".
  Future<void> restore(String id) async {
    final item = _repo.byId(id);
    if (item == null) return;
    final updated = item.copyWith(
      status: WishStatus.waiting,
      decidedAt: null,
      decidedPriceCents: null,
      hourlyRateSnapshotCents: null,
      experienceDate: null,
    );
    await _repo.put(updated);
    await _notifications.cancel(item.notificationId);
    _reload();
    await _schedule(updated);
  }

  Future<void> answerWorthIt(String id, bool worthIt) async {
    final item = _repo.byId(id);
    if (item == null) return;
    await _repo.put(item.copyWith(worthItAnswer: worthIt));
    _reload();
  }

  /// Löschen: für Fehleinträge, zählt nie als gespart.
  Future<void> delete(String id) async {
    final item = _repo.byId(id);
    if (item == null) return;
    await _notifications.cancel(item.notificationId);
    await _repo.remove(id);
    _reload();
  }

  Future<void> deleteAll() async {
    await _notifications.cancelAll();
    await _repo.clear();
    _reload();
  }

  Future<void> importAll(List<WishItem> items) async {
    await _repo.putAll(items);
    _reload();
    await rescheduleAll();
  }

  /// Beim App-Start: alle offenen Erinnerungen neu planen (idempotent).
  Future<void> rescheduleAll() async {
    if (!ref.read(settingsProvider).notificationsEnabled) return;
    for (final item in state.where((w) => w.isWaiting)) {
      await _schedule(item);
    }
  }

  Future<void> _schedule(WishItem item) async {
    if (!ref.read(settingsProvider).notificationsEnabled) return;
    if (item.remindAt == null) return;
    await _notifications.cancel(item.notificationId);
    await _notifications.scheduleReminder(
      item,
      body: reminderBody(item, ref.read(hourlyRateProvider)),
    );
  }

  /// "Wolltest du die Kopfhörer noch? Sie warten seit 7 Tagen (249 €, ≈ 14 Std Arbeit)."
  static String reminderBody(WishItem item, int? hourlyRate) {
    final remindAt = item.remindAt ?? clock.now();
    final waited = TimeFormat.since(remindAt.difference(item.createdAt));
    final hours = WorkHours.hoursFor(item.priceCents, hourlyRate);
    final work = hours == null ? '' : ', ${WorkHours.format(hours)} Arbeit';
    return 'Willst du ${item.title} noch genauso wie am ersten Tag? '
        'Wartet $waited (${MoneyFormat.euro(item.priceCents)}$work).';
  }
}

final wishesProvider = NotifierProvider<WishesNotifier, List<WishItem>>(
  WishesNotifier.new,
);

String? _blankToNull(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

// ---------------------------------------------------------------------------
// Abgeleitete Daten
// ---------------------------------------------------------------------------

final waitingWishesProvider = Provider<List<WishItem>>((ref) {
  final all = ref.watch(wishesProvider);
  return all.where((w) => w.isWaiting).toList();
});

final ripeWishesProvider = Provider<List<WishItem>>((ref) {
  final now = clock.now();
  return ref
      .watch(waitingWishesProvider)
      .where((w) => w.isRipe(now))
      .toList();
});

final skippedWishesProvider = Provider<List<WishItem>>((ref) {
  final all = ref.watch(wishesProvider);
  final list = all.where((w) => w.status == WishStatus.skipped).toList();
  list.sort((a, b) => (b.decidedAt ?? b.updatedAt).compareTo(a.decidedAt ?? a.updatedAt));
  return list;
});

final boughtWishesProvider = Provider<List<WishItem>>((ref) {
  final all = ref.watch(wishesProvider);
  final list = all.where((w) => w.status == WishStatus.bought).toList();
  list.sort((a, b) => (b.decidedAt ?? b.updatedAt).compareTo(a.decidedAt ?? a.updatedAt));
  return list;
});

class Savings {
  const Savings({required this.totalCents, required this.hours, required this.count});

  final int totalCents;

  /// Zurückgewonnene Arbeitsstunden (mit Stundenlohn-Snapshot je Verzicht).
  final double? hours;
  final int count;

  static const empty = Savings(totalCents: 0, hours: null, count: 0);
}

final savingsProvider = Provider<Savings>((ref) {
  final skipped = ref.watch(skippedWishesProvider);
  final currentRate = ref.watch(hourlyRateProvider);
  var total = 0;
  double hours = 0;
  var anyRate = false;
  for (final w in skipped) {
    total += w.priceCents;
    final rate = w.hourlyRateSnapshotCents ?? currentRate;
    final h = WorkHours.hoursFor(w.priceCents, rate);
    if (h != null) {
      hours += h;
      anyRate = true;
    }
  }
  return Savings(
    totalCents: total,
    hours: anyRate ? hours : null,
    count: skipped.length,
  );
});

/// Gekaufte Erlebnisse mit Datum in der Zukunft (Vorfreude).
final upcomingExperiencesProvider = Provider<List<WishItem>>((ref) {
  final now = clock.now();
  final list = ref
      .watch(boughtWishesProvider)
      .where((w) => w.experienceDate != null && w.experienceDate!.isAfter(now))
      .toList();
  list.sort((a, b) => a.experienceDate!.compareTo(b.experienceDate!));
  return list;
});
