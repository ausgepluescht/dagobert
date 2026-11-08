import 'package:flutter/material.dart';

import '../models/wish_item.dart';

enum ReminderOption {
  oneDay(Duration(hours: 24), '24 h', 'in 24 Stunden'),
  threeDays(Duration(days: 3), '3 Tage', 'in 3 Tagen'),
  sevenDays(Duration(days: 7), '7 Tage', 'in 7 Tagen'),
  twoWeeks(Duration(days: 14), '2 Wochen', 'in 2 Wochen'),
  oneMonth(Duration(days: 30), '1 Monat', 'in 1 Monat');

  const ReminderOption(this.duration, this.label, this.sentence);

  final Duration duration;
  final String label;
  final String sentence;
}

abstract final class ReminderPolicy {
  /// Vorauswahl nach Arbeitsstunden. "Brauche ich" bleibt kurz.
  static ReminderOption suggest({
    required WishType type,
    required double? workHours,
  }) {
    if (type == WishType.need) return ReminderOption.oneDay;
    final h = workHours;
    if (h == null) return ReminderOption.threeDays;
    if (h <= 2) return ReminderOption.oneDay;
    if (h <= 8) return ReminderOption.threeDays;
    if (h <= 24) return ReminderOption.sevenDays;
    if (h <= 80) return ReminderOption.twoWeeks;
    return ReminderOption.oneMonth;
  }

  /// Verschiebt [at] in das Zeitfenster [start]–[end].
  /// Vor dem Fenster → Fensterbeginn am selben Tag.
  /// Nach dem Fenster → Fensterbeginn am Folgetag.
  static DateTime clampToWindow(
    DateTime at, {
    required TimeOfDay start,
    required TimeOfDay end,
  }) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final atMinutes = at.hour * 60 + at.minute;
    if (startMinutes >= endMinutes) return at;
    if (atMinutes < startMinutes) {
      return DateTime(at.year, at.month, at.day, start.hour, start.minute);
    }
    if (atMinutes > endMinutes) {
      final next = at.add(const Duration(days: 1));
      return DateTime(next.year, next.month, next.day, start.hour, start.minute);
    }
    return at;
  }

  static DateTime remindAtFor(
    DateTime now,
    ReminderOption option, {
    required TimeOfDay windowStart,
    required TimeOfDay windowEnd,
  }) {
    return clampToWindow(
      now.add(option.duration),
      start: windowStart,
      end: windowEnd,
    );
  }
}
