// Vorschau-Einstieg mit Demodaten (für Screenshots und Web-Preview).
// Start: flutter run -t lib/main_preview.dart -d chrome
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/settings_repository.dart';
import 'data/wish_repository.dart';
import 'models/settings.dart';
import 'models/wish_item.dart';
import 'services/notification_service.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE');
  await Hive.initFlutter();
  final wishBox = await Hive.openBox<String>('wishes_preview');
  final settingsBox = await Hive.openBox<String>('settings_preview');
  await wishBox.clear();
  await settingsBox.clear();

  final wishes = WishRepository(wishBox);
  final settings = SettingsRepository(settingsBox);
  await settings.save(
    const Settings(
      netMonthlyCents: 280000,
      hoursPerWeek: 40,
      onboardingDone: true,
      savingsGoalTitle: 'Island-Reise',
      savingsGoalCents: 200000,
      userName: 'Martin',
    ),
  );

  final now = DateTime.now();
  WishItem make(
    String id,
    String title,
    int cents, {
    required int daysAgo,
    required int remindInDays,
    WishType type = WishType.want,
    WishCategory? category,
    WishTrigger? trigger,
    String? url,
    Map<String, CheckAnswer> answers = const {},
    WishStatus status = WishStatus.waiting,
    int? decidedDaysAgo,
    int? desire,
    DateTime? experienceDate,
  }) {
    final created = now.subtract(Duration(days: daysAgo));
    return WishItem(
      id: id,
      notificationId: 1000 + id.hashCode % 1000,
      title: title,
      priceCents: cents,
      priceHistory: [PricePoint(cents: cents, at: created)],
      type: type,
      category: category,
      trigger: trigger,
      url: url,
      desireAtCreate: desire,
      createdAt: created,
      updatedAt: created,
      remindAt: created.add(Duration(days: remindInDays)),
      checkAnswers: answers,
      status: status,
      decidedAt: decidedDaysAgo == null ? null : now.subtract(Duration(days: decidedDaysAgo)),
      hourlyRateSnapshotCents: status == WishStatus.waiting ? null : 1615,
      experienceDate: experienceDate,
    );
  }

  await wishes.putAll([
    make(
      'w1',
      'Kopfhörer Sony WH-1000XM6',
      24900,
      daysAgo: 7,
      remindInDays: 7,
      category: WishCategory.tech,
      trigger: WishTrigger.ads,
      url: 'https://www.amazon.de/dp/B0F1XYZ',
      desire: 4,
      answers: const {
        'time': CheckAnswer.yes,
        'story': CheckAnswer.partly,
        'people': CheckAnswer.no,
        'treat': CheckAnswer.yes,
        'anticipation': CheckAnswer.partly,
      },
    ),
    make(
      'w2',
      'Waschmaschine',
      44900,
      daysAgo: 0,
      remindInDays: 1,
      type: WishType.need,
      category: WishCategory.household,
      trigger: WishTrigger.realNeed,
    ),
    make(
      'w3',
      'Porzellan-Set 12-tlg.',
      8900,
      daysAgo: 3,
      remindInDays: 7,
      category: WishCategory.household,
      trigger: WishTrigger.sale,
      desire: 3,
      answers: const {'time': CheckAnswer.no, 'story': CheckAnswer.no, 'people': CheckAnswer.partly},
    ),
    make(
      'w4',
      'Wochenende Kopenhagen',
      38000,
      daysAgo: 4,
      remindInDays: 14,
      category: WishCategory.travel,
      url: 'https://www.booking.com/x',
      desire: 5,
      answers: const {
        'time': CheckAnswer.partly,
        'story': CheckAnswer.yes,
        'people': CheckAnswer.yes,
        'treat': CheckAnswer.yes,
        'anticipation': CheckAnswer.yes,
      },
    ),
    make('s1', 'Smartwatch', 32900, daysAgo: 20, remindInDays: 14, category: WishCategory.tech, trigger: WishTrigger.ads, status: WishStatus.skipped, decidedDaysAgo: 6),
    make('s2', 'Zweite Jeans', 8900, daysAgo: 40, remindInDays: 7, category: WishCategory.clothing, trigger: WishTrigger.sale, status: WishStatus.skipped, decidedDaysAgo: 33),
    make('s3', 'Küchenmaschine', 49900, daysAgo: 75, remindInDays: 30, category: WishCategory.household, trigger: WishTrigger.sale, status: WishStatus.skipped, decidedDaysAgo: 45),
    make('s4', 'Gaming-Stuhl', 32900, daysAgo: 100, remindInDays: 14, category: WishCategory.tech, trigger: WishTrigger.boredom, status: WishStatus.skipped, decidedDaysAgo: 86),
    make(
      'b1',
      'Konzert Hamburg',
      9800,
      daysAgo: 30,
      remindInDays: 7,
      category: WishCategory.leisure,
      status: WishStatus.bought,
      decidedDaysAgo: 23,
      experienceDate: now.add(const Duration(days: 12)),
    ),
  ]);

  runApp(
    ProviderScope(
      overrides: [
        wishRepositoryProvider.overrideWithValue(wishes),
        settingsRepositoryProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(NoopNotificationService()),
      ],
      child: const DagobertApp(),
    ),
  );
}
