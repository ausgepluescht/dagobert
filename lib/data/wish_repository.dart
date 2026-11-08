import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../models/wish_item.dart';

/// Speichert Wünsche als JSON-Strings in einer Hive-Box. Kein TypeAdapter,
/// kein build_runner. Migrationen laufen in [migrations.dart].
class WishRepository {
  WishRepository(this._box);

  static const boxName = 'wishes';

  final Box<String> _box;

  List<WishItem> all() {
    final items = <WishItem>[];
    for (final raw in _box.values) {
      try {
        items.add(WishItem.fromJson(jsonDecode(raw) as Map));
      } catch (_) {
        // Kaputter Eintrag: lieber überspringen als die App blockieren.
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  WishItem? byId(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return WishItem.fromJson(jsonDecode(raw) as Map);
  }

  Future<void> put(WishItem item) =>
      _box.put(item.id, jsonEncode(item.toJson()));

  Future<void> putAll(Iterable<WishItem> items) => _box.putAll({
    for (final item in items) item.id: jsonEncode(item.toJson()),
  });

  Future<void> remove(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  Stream<void> watch() => _box.watch().map((_) {});

  /// Nächste freie Notification-ID (int32-sicher, nie 0).
  int nextNotificationId() {
    var max = 1000;
    for (final item in all()) {
      if (item.notificationId > max) max = item.notificationId;
    }
    return max + 1;
  }
}
