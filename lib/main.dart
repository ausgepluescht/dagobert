import 'dart:async';

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
import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Erst zeichnen, dann initialisieren: Ein Fehler beim Start wird so
  // angezeigt statt in einem weißen Bildschirm zu enden.
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<_Deps> _init = _initialize();

  Future<_Deps> _initialize() async {
    try {
      await initializeDateFormatting('de_DE');
    } catch (_) {
      // Formatierung fällt dann auf Standardwerte zurück.
    }

    await Hive.initFlutter();
    final wishBox = await Hive.openBox<String>(WishRepository.boxName);
    final settingsBox = await Hive.openBox<String>(SettingsRepository.boxName);
    await Migrations.migrateWishes(wishBox);

    NotificationService notifications = NoopNotificationService();
    if (!kIsWeb) {
      try {
        final local = LocalNotificationService();
        await local.init().timeout(const Duration(seconds: 8));
        notifications = local;
      } catch (e, st) {
        // Ohne Benachrichtigungen läuft der Rest der App trotzdem.
        debugPrint('Notification init failed: $e\n$st');
      }
    }

    return _Deps(
      wishes: WishRepository(wishBox),
      settings: SettingsRepository(settingsBox),
      notifications: notifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Deps>(
      future: _init,
      builder: (context, snap) {
        if (snap.hasError) {
          return _StartupError(
            error: snap.error!,
            stack: snap.stackTrace,
            onRetry: () => setState(() => _init = _initialize()),
          );
        }
        if (!snap.hasData) {
          return const _Splash();
        }
        final deps = snap.data!;
        return ProviderScope(
          overrides: [
            wishRepositoryProvider.overrideWithValue(deps.wishes),
            settingsRepositoryProvider.overrideWithValue(deps.settings),
            notificationServiceProvider.overrideWithValue(deps.notifications),
          ],
          child: const DagobertApp(),
        );
      },
    );
  }
}

class _Deps {
  const _Deps({
    required this.wishes,
    required this.settings,
    required this.notifications,
  });

  final WishRepository wishes;
  final SettingsRepository settings;
  final NotificationService notifications;
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const Scaffold(
        backgroundColor: DgColors.warmWhite,
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({
    required this.error,
    required this.stack,
    required this.onRetry,
  });

  final Object error;
  final StackTrace? stack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final details = '$error\n\n${stack ?? ''}';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dagobert konnte nicht starten.', style: DgType.h1),
                const SizedBox(height: 8),
                Text(
                  'Das sollte nicht passieren. Der Fehlertext unten hilft beim Beheben. Antippen kopiert ihn.',
                  style: DgType.meta,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: details));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fehlertext kopiert.')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DgColors.warmWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: DgColors.sand),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          details,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: DgColors.espresso,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Noch einmal versuchen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
