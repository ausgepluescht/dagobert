import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dagobert/data/settings_repository.dart';
import 'package:dagobert/data/wish_repository.dart';
import 'package:dagobert/models/settings.dart';
import 'package:dagobert/models/wish_item.dart';
import 'package:dagobert/services/notification_service.dart';
import 'package:dagobert/services/reminder_policy.dart';
import 'package:dagobert/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory dir;
  late Box<String> wishBox;
  late Box<String> settingsBox;
  late NoopNotificationService notifications;
  late ProviderContainer container;

  final now = DateTime(2026, 11, 8, 12);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('dagobert_test');
    Hive.init(dir.path);
    wishBox = await Hive.openBox<String>('wishes_test');
    settingsBox = await Hive.openBox<String>('settings_test');
    notifications = NoopNotificationService();
    container = ProviderContainer(
      overrides: [
        wishRepositoryProvider.overrideWithValue(WishRepository(wishBox)),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(settingsBox)),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    await container.read(settingsProvider.notifier).update(
      (s) => const Settings(netMonthlyCents: 280000, hoursPerWeek: 40, onboardingDone: true),
    );
  });

  tearDown(() async {
    container.dispose();
    await wishBox.deleteFromDisk();
    await settingsBox.deleteFromDisk();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<WishItem> addWish({int price = 24900, WishType type = WishType.want}) {
    return withClock(Clock.fixed(now), () {
      return container.read(wishesProvider.notifier).add(
        title: 'Kopfhörer',
        priceCents: price,
        type: type,
        reminder: ReminderOption.sevenDays,
        trigger: WishTrigger.sale,
      );
    });
  }

  test('add speichert, plant Erinnerung im Zeitfenster', () async {
    final item = await addWish();
    expect(container.read(wishesProvider).length, 1);
    expect(item.remindAt, DateTime(2026, 11, 15, 12));
    expect(notifications.scheduled.containsKey(item.notificationId), isTrue);
    expect(item.priceHistory.single.cents, 24900);
  });

  test('skip zählt als gespart, mit Stundenlohn-Snapshot, und storniert Notification', () async {
    final item = await addWish();
    await withClock(Clock.fixed(now.add(const Duration(days: 7))), () async {
      await container.read(wishesProvider.notifier).skip(item.id);
    });
    final savings = container.read(savingsProvider);
    expect(savings.totalCents, 24900);
    expect(savings.count, 1);
    expect(savings.hours, closeTo(15.4, 0.1));
    expect(notifications.cancelled, contains(item.notificationId));
    final stored = container.read(wishesProvider).single;
    expect(stored.hourlyRateSnapshotCents, 1615);
    expect(container.read(waitingWishesProvider), isEmpty);
  });

  test('Gehaltsänderung ändert gesparte Stunden nicht (Snapshot)', () async {
    final item = await addWish();
    await container.read(wishesProvider.notifier).skip(item.id);
    final before = container.read(savingsProvider).hours;
    await container.read(settingsProvider.notifier).update(
      (s) => s.copyWith(netMonthlyCents: 560000),
    );
    expect(container.read(savingsProvider).hours, before);
  });

  test('restore macht Verzicht rückgängig und plant neu', () async {
    final item = await addWish();
    await container.read(wishesProvider.notifier).skip(item.id);
    expect(container.read(savingsProvider).totalCents, 24900);
    await container.read(wishesProvider.notifier).restore(item.id);
    expect(container.read(savingsProvider).totalCents, 0);
    expect(container.read(waitingWishesProvider).length, 1);
    expect(notifications.scheduled.containsKey(item.notificationId), isTrue);
  });

  test('buy loggt Preis und zählt nicht als gespart', () async {
    final item = await addWish();
    await container.read(wishesProvider.notifier).buy(item.id, paidCents: 19900);
    expect(container.read(savingsProvider).totalCents, 0);
    final stored = container.read(wishesProvider).single;
    expect(stored.status, WishStatus.bought);
    expect(stored.decidedPriceCents, 19900);
  });

  test('snooze setzt neuen Timer und zählt hoch', () async {
    final item = await addWish();
    await withClock(Clock.fixed(now.add(const Duration(days: 7))), () async {
      await container.read(wishesProvider.notifier).snooze(item.id, ReminderOption.threeDays);
    });
    final stored = container.read(wishesProvider).single;
    expect(stored.snoozeCount, 1);
    expect(stored.remindAt, DateTime(2026, 11, 18, 12));
  });

  test('delete entfernt ohne zu sparen', () async {
    final item = await addWish();
    await container.read(wishesProvider.notifier).delete(item.id);
    expect(container.read(wishesProvider), isEmpty);
    expect(container.read(savingsProvider).totalCents, 0);
    expect(notifications.cancelled, contains(item.notificationId));
  });

  test('ripeWishes enthält nur abgelaufene Timer', () async {
    final item = await addWish();
    expect(
      withClock(Clock.fixed(now.add(const Duration(days: 1))), () => item.isRipe()),
      isFalse,
    );
    expect(
      withClock(Clock.fixed(now.add(const Duration(days: 8))), () => item.isRipe()),
      isTrue,
    );
  });

  test('Notification-IDs sind eindeutig und steigen', () async {
    final a = await addWish();
    final b = await addWish(price: 100);
    expect(b.notificationId, greaterThan(a.notificationId));
  });

  test('Erinnerungstext nennt Titel, Preis und Wartezeit', () async {
    final item = await addWish();
    final body = WishesNotifier.reminderBody(item, 1615);
    expect(body, contains('Kopfhörer'));
    expect(body, contains('249'));
    expect(body, contains('seit 7 Tagen'));
    expect(body, contains('Std Arbeit'));
  });
}
