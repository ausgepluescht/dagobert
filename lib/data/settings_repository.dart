import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../models/settings.dart';

class SettingsRepository {
  SettingsRepository(this._box);

  static const boxName = 'settings';
  static const _key = 'settings';

  final Box<String> _box;

  Settings load() {
    final raw = _box.get(_key);
    if (raw == null) return const Settings();
    try {
      return Settings.fromJson(jsonDecode(raw) as Map);
    } catch (_) {
      return const Settings();
    }
  }

  Future<void> save(Settings settings) =>
      _box.put(_key, jsonEncode(settings.toJson()));

  Future<void> clear() => _box.clear();
}
