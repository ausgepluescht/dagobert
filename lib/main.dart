import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/migrations.dart';
import 'data/settings_repository.dart';
import 'data/wish_repository.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Hive.initFlutter();
  final wishBox = await Hive.openBox<String>(WishRepository.boxName);
  final settingsBox = await Hive.openBox<String>(SettingsRepository.boxName);
  await Migrations.migrateWishes(wishBox);

  final NotificationService notifications;
  if (kIsWeb) {
    notifications = NoopNotificationService();
  } else {
    notifications = LocalNotificationService();
    await notifications.init();
  }

  runApp(
    ProviderScope(
      overrides: [
        wishRepositoryProvider.overrideWithValue(WishRepository(wishBox)),
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepository(settingsBox),
        ),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const DagobertApp(),
    ),
  );
}
