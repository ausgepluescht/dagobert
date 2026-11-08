import '../models/wish_item.dart';

/// Abstraktion über lokale Benachrichtigungen, damit Tests und Web einen
/// Fake nutzen können.
abstract class NotificationService {
  Future<void> init();

  /// Fragt die Berechtigung an (Android 13+). Gibt zurück, ob erlaubt.
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  Future<void> scheduleReminder(WishItem item, {required String body});

  Future<void> scheduleWorthIt(WishItem item, {required DateTime at});

  Future<void> cancel(int notificationId);

  Future<void> cancelAll();

  Future<void> showTest();

  /// Payload der Benachrichtigung, mit der die App gestartet wurde.
  Future<String?> initialPayload();

  /// Stream von Payloads, wenn der Nutzer auf eine Benachrichtigung tippt.
  Stream<NotificationTap> get taps;
}

class NotificationTap {
  const NotificationTap({required this.wishId, this.action});

  final String wishId;

  /// "skip" oder "snooze", null = Benachrichtigung selbst angetippt.
  final String? action;

  static NotificationTap? parse(String? payload, String? actionId) {
    if (payload == null || payload.isEmpty) return null;
    final id = payload.startsWith('wish:') ? payload.substring(5) : payload;
    return NotificationTap(
      wishId: id,
      action: (actionId == null || actionId.isEmpty) ? null : actionId,
    );
  }
}

/// Für Web und Tests: tut nichts, merkt sich aber Aufrufe.
class NoopNotificationService implements NotificationService {
  final scheduled = <int, WishItem>{};
  final cancelled = <int>[];

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> scheduleReminder(WishItem item, {required String body}) async {
    scheduled[item.notificationId] = item;
  }

  @override
  Future<void> scheduleWorthIt(WishItem item, {required DateTime at}) async {}

  @override
  Future<void> cancel(int notificationId) async {
    scheduled.remove(notificationId);
    cancelled.add(notificationId);
  }

  @override
  Future<void> cancelAll() async => scheduled.clear();

  @override
  Future<void> showTest() async {}

  @override
  Future<String?> initialPayload() async => null;

  @override
  Stream<NotificationTap> get taps => const Stream.empty();
}
