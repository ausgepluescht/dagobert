import 'package:flutter/material.dart';

class Settings {
  const Settings({
    this.netMonthlyCents,
    this.hoursPerWeek,
    this.reminderWindowStart = const TimeOfDay(hour: 9, minute: 0),
    this.reminderWindowEnd = const TimeOfDay(hour: 20, minute: 0),
    this.savingsGoalTitle,
    this.savingsGoalCents,
    this.onboardingDone = false,
    this.notificationsEnabled = true,
    this.swipeHintShown = false,
    this.userName,
  });

  static const schemaVersion = 1;

  /// Netto-Einkommen pro Monat in Cent. null = nicht gesetzt.
  final int? netMonthlyCents;

  /// Wochenarbeitsstunden. null = nicht gesetzt.
  final double? hoursPerWeek;

  /// Erinnerungen landen nur in diesem Zeitfenster.
  final TimeOfDay reminderWindowStart;
  final TimeOfDay reminderWindowEnd;

  /// Sparziel ("Wofür sparst du?").
  final String? savingsGoalTitle;
  final int? savingsGoalCents;
  final bool onboardingDone;
  final bool notificationsEnabled;
  final bool swipeHintShown;
  final String? userName;

  bool get hasIncome =>
      netMonthlyCents != null &&
      netMonthlyCents! > 0 &&
      hoursPerWeek != null &&
      hoursPerWeek! > 0;

  bool get hasGoal =>
      savingsGoalTitle != null &&
      savingsGoalTitle!.trim().isNotEmpty &&
      savingsGoalCents != null &&
      savingsGoalCents! > 0;

  Settings copyWith({
    Object? netMonthlyCents = _unset,
    Object? hoursPerWeek = _unset,
    TimeOfDay? reminderWindowStart,
    TimeOfDay? reminderWindowEnd,
    Object? savingsGoalTitle = _unset,
    Object? savingsGoalCents = _unset,
    bool? onboardingDone,
    bool? notificationsEnabled,
    bool? swipeHintShown,
    Object? userName = _unset,
  }) {
    return Settings(
      netMonthlyCents: netMonthlyCents == _unset
          ? this.netMonthlyCents
          : netMonthlyCents as int?,
      hoursPerWeek: hoursPerWeek == _unset
          ? this.hoursPerWeek
          : hoursPerWeek as double?,
      reminderWindowStart: reminderWindowStart ?? this.reminderWindowStart,
      reminderWindowEnd: reminderWindowEnd ?? this.reminderWindowEnd,
      savingsGoalTitle: savingsGoalTitle == _unset
          ? this.savingsGoalTitle
          : savingsGoalTitle as String?,
      savingsGoalCents: savingsGoalCents == _unset
          ? this.savingsGoalCents
          : savingsGoalCents as int?,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      swipeHintShown: swipeHintShown ?? this.swipeHintShown,
      userName: userName == _unset ? this.userName : userName as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'netMonthlyCents': netMonthlyCents,
    'hoursPerWeek': hoursPerWeek,
    'reminderWindowStart': _timeToString(reminderWindowStart),
    'reminderWindowEnd': _timeToString(reminderWindowEnd),
    'savingsGoalTitle': savingsGoalTitle,
    'savingsGoalCents': savingsGoalCents,
    'onboardingDone': onboardingDone,
    'notificationsEnabled': notificationsEnabled,
    'swipeHintShown': swipeHintShown,
    'userName': userName,
  };

  factory Settings.fromJson(Map<dynamic, dynamic> json) => Settings(
    netMonthlyCents: json['netMonthlyCents'] as int?,
    hoursPerWeek: (json['hoursPerWeek'] as num?)?.toDouble(),
    reminderWindowStart:
        _timeFromString(json['reminderWindowStart'] as String?) ??
        const TimeOfDay(hour: 9, minute: 0),
    reminderWindowEnd:
        _timeFromString(json['reminderWindowEnd'] as String?) ??
        const TimeOfDay(hour: 20, minute: 0),
    savingsGoalTitle: json['savingsGoalTitle'] as String?,
    savingsGoalCents: json['savingsGoalCents'] as int?,
    onboardingDone: (json['onboardingDone'] as bool?) ?? false,
    notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
    swipeHintShown: (json['swipeHintShown'] as bool?) ?? false,
    userName: json['userName'] as String?,
  );
}

const _unset = Object();

String _timeToString(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay? _timeFromString(String? s) {
  if (s == null) return null;
  final parts = s.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h, minute: m);
}
