import 'dart:convert';

import 'package:clock/clock.dart';

import '../models/settings.dart';
import '../models/wish_item.dart';

/// JSON-Export und -Import aller Daten.
abstract final class Backup {
  static const formatVersion = 1;

  static String encode({
    required List<WishItem> wishes,
    required Settings settings,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'dagobert',
      'formatVersion': formatVersion,
      'exportedAt': clock.now().toIso8601String(),
      'settings': settings.toJson(),
      'wishes': wishes.map((w) => w.toJson()).toList(),
    });
  }

  static BackupData decode(String raw) {
    final map = jsonDecode(raw);
    if (map is! Map || map['app'] != 'dagobert') {
      throw const FormatException('Das ist keine Dagobert-Sicherung.');
    }
    final wishes = <WishItem>[];
    for (final w in (map['wishes'] as List? ?? const [])) {
      wishes.add(WishItem.fromJson(w as Map));
    }
    final settings = map['settings'] is Map
        ? Settings.fromJson(map['settings'] as Map)
        : null;
    return BackupData(wishes: wishes, settings: settings);
  }
}

class BackupData {
  const BackupData({required this.wishes, this.settings});
  final List<WishItem> wishes;
  final Settings? settings;
}
