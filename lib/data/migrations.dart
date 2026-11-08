import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// Schema-Migrationen für gespeicherte JSON-Einträge.
///
/// Jeder Eintrag trägt `schemaVersion`. Fehlt der Schlüssel, gilt Version 1.
/// Neue Versionen bekommen hier eine Funktion, die den Map in Place anpasst.
abstract final class Migrations {
  static const currentWishVersion = 1;

  static final _wishSteps = <int, void Function(Map<String, dynamic>)>{
    // 2: (m) { m['neuesFeld'] = ...; },
  };

  static Future<void> migrateWishes(Box<String> box) async {
    final updates = <String, String>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      Map<String, dynamic> map;
      try {
        map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        continue;
      }
      var version = (map['schemaVersion'] as int?) ?? 1;
      var changed = false;
      while (version < currentWishVersion) {
        version += 1;
        _wishSteps[version]?.call(map);
        map['schemaVersion'] = version;
        changed = true;
      }
      if (changed) updates[key as String] = jsonEncode(map);
    }
    if (updates.isNotEmpty) await box.putAll(updates);
  }
}
