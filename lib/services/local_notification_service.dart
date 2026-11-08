import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/wish_item.dart';
import 'money_format.dart';
import 'notification_service.dart';

/// Echte Implementierung mit flutter_local_notifications (Android).
class LocalNotificationService implements NotificationService {
  LocalNotificationService();

  static const _reminderChannel = AndroidNotificationChannel(
    'reminders',
    'Erinnerungen',
    description: 'Dagobert erinnert dich, wenn ein Wunsch reif zur Entscheidung ist.',
    importance: Importance.high,
  );

  static const _worthItChannel = AndroidNotificationChannel(
    'worth_it',
    'Rückblick',
    description: 'Fragt 30 Tage nach einem Kauf, ob es das wert war.',
    importance: Importance.defaultImportance,
  );

  static const actionSkip = 'skip';
  static const actionSnooze = 'snooze';

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<NotificationTap>.broadcast();
  bool _initialized = false;

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  @override
  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }

    const android = AndroidInitializationSettings('ic_stat_dagobert');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_reminderChannel);
    await androidPlugin?.createNotificationChannel(_worthItChannel);
    _initialized = true;
  }

  void _onResponse(NotificationResponse response) {
    final tap = NotificationTap.parse(response.payload, response.actionId);
    if (tap != null) _taps.add(tap);
  }

  @override
  Future<String?> initialPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final response = details.notificationResponse;
    if (response == null) return null;
    final action = response.actionId;
    final payload = response.payload ?? '';
    return action == null || action.isEmpty ? payload : '$payload|$action';
  }

  @override
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  @override
  Future<bool> hasPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await androidPlugin?.areNotificationsEnabled();
    return enabled ?? true;
  }

  @override
  Future<void> scheduleReminder(WishItem item, {required String body}) async {
    final at = item.remindAt;
    if (at == null) return;
    final when = tz.TZDateTime.from(at, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannel.id,
        _reminderChannel.name,
        channelDescription: _reminderChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
        color: const Color(0xFFE2711D),
        actions: const [
          AndroidNotificationAction(
            actionSkip,
            'Verzichten',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            actionSnooze,
            'Später erinnern',
            showsUserInterface: true,
          ),
        ],
      ),
    );

    await _plugin.zonedSchedule(
      id: item.notificationId,
      title: '${item.title} · ${MoneyFormat.euro(item.priceCents)}',
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'wish:${item.id}',
    );
  }

  @override
  Future<void> scheduleWorthIt(WishItem item, {required DateTime at}) async {
    final when = tz.TZDateTime.from(at, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _worthItChannel.id,
        _worthItChannel.name,
        channelDescription: _worthItChannel.description,
        color: const Color(0xFFD9A425),
      ),
    );
    await _plugin.zonedSchedule(
      id: worthItId(item.notificationId),
      title: 'War es das wert?',
      body:
          'Vor 30 Tagen hast du ${item.title} gekauft. Bist du heute froh darüber?',
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'wish:${item.id}',
    );
  }

  /// Eigene ID für die Rückblick-Benachrichtigung.
  static int worthItId(int notificationId) => notificationId + 500000;

  @override
  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(id: notificationId);
    await _plugin.cancel(id: worthItId(notificationId));
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> showTest() async {
    await _plugin.show(
      id: 1,
      title: 'Dagobert meldet sich',
      body:
          'So sieht eine Erinnerung aus. Wenn du das liest, funktionieren Benachrichtigungen.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannel.id,
          _reminderChannel.name,
          channelDescription: _reminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFFE2711D),
        ),
      ),
    );
  }
}
