import 'package:clock/clock.dart';

/// Brauche ich (need) oder will ich (want).
enum WishType {
  need,
  want;

  String get label => switch (this) {
    WishType.need => 'Brauche ich',
    WishType.want => 'Will ich',
  };
}

enum WishStatus {
  waiting,
  bought,
  skipped,
  deleted;

  String get label => switch (this) {
    WishStatus.waiting => 'Wartet',
    WishStatus.bought => 'Gekauft',
    WishStatus.skipped => 'Verzichtet',
    WishStatus.deleted => 'Gelöscht',
  };
}

enum WishCategory {
  household,
  tech,
  clothing,
  leisure,
  travel,
  gift,
  other;

  String get label => switch (this) {
    WishCategory.household => 'Haushalt',
    WishCategory.tech => 'Technik',
    WishCategory.clothing => 'Kleidung',
    WishCategory.leisure => 'Freizeit',
    WishCategory.travel => 'Reisen',
    WishCategory.gift => 'Geschenk',
    WishCategory.other => 'Sonstiges',
  };

  /// Erlebnis-Kategorien bekommen einen Vorfreude-Countdown.
  bool get isExperience =>
      this == WishCategory.travel || this == WishCategory.leisure;
}

/// Was den Wunsch ausgelöst hat.
enum WishTrigger {
  boredom,
  sale,
  ads,
  stress,
  realNeed;

  String get label => switch (this) {
    WishTrigger.boredom => 'Langeweile',
    WishTrigger.sale => 'Rabatt / Sale',
    WishTrigger.ads => 'Werbung / Social Media',
    WishTrigger.stress => 'Frust / Stress',
    WishTrigger.realNeed => 'Echter Bedarf',
  };
}

/// Antwort auf eine Check-Frage.
enum CheckAnswer {
  no,
  partly,
  yes;

  double get points => switch (this) {
    CheckAnswer.no => 0,
    CheckAnswer.partly => 0.5,
    CheckAnswer.yes => 1,
  };

  String get label => switch (this) {
    CheckAnswer.no => 'Nein',
    CheckAnswer.partly => 'Teils',
    CheckAnswer.yes => 'Ja',
  };
}

class PricePoint {
  const PricePoint({required this.cents, required this.at});

  final int cents;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'cents': cents,
    'at': at.toIso8601String(),
  };

  factory PricePoint.fromJson(Map<dynamic, dynamic> json) => PricePoint(
    cents: json['cents'] as int,
    at: DateTime.parse(json['at'] as String),
  );
}

class WishItem {
  const WishItem({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.priceCents,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.priceHistory = const [],
    this.category,
    this.trigger,
    this.note,
    this.url,
    this.desireAtCreate,
    this.desireAtDecision,
    this.remindAt,
    this.snoozeCount = 0,
    this.checkVersion = 1,
    this.checkAnswers = const {},
    this.expectedUses,
    this.status = WishStatus.waiting,
    this.decidedAt,
    this.decidedPriceCents,
    this.hourlyRateSnapshotCents,
    this.experienceDate,
    this.worthItAnswer,
  });

  static const schemaVersion = 1;

  final String id;

  /// Stabile Android-Notification-ID (int), am Eintrag gespeichert.
  final int notificationId;
  final String title;
  final int priceCents;
  final List<PricePoint> priceHistory;
  final WishType type;
  final WishCategory? category;
  final WishTrigger? trigger;
  final String? note;
  final String? url;

  /// Wunsch-Thermometer 1–5 beim Anlegen.
  final int? desireAtCreate;

  /// Wunsch-Thermometer 1–5 im Entscheidungsmoment.
  final int? desireAtDecision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? remindAt;
  final int snoozeCount;
  final int checkVersion;

  /// Frage-ID → Antwort.
  final Map<String, CheckAnswer> checkAnswers;

  /// Geschätzte Nutzungen für "Kosten pro Nutzung".
  final int? expectedUses;
  final WishStatus status;
  final DateTime? decidedAt;

  /// Tatsächlich gezahlter Preis (bei "Gekauft").
  final int? decidedPriceCents;

  /// Netto-Stundenlohn zum Zeitpunkt der Entscheidung, damit eine spätere
  /// Gehaltsänderung die Vergangenheit nicht umschreibt.
  final int? hourlyRateSnapshotCents;

  /// Datum eines gekauften Erlebnisses für den Vorfreude-Countdown.
  final DateTime? experienceDate;

  /// "War es das wert?" 30 Tage nach dem Kauf: true/false, null = offen.
  final bool? worthItAnswer;

  bool get isWaiting => status == WishStatus.waiting;

  /// Reif = Timer abgelaufen und noch nicht entschieden.
  bool isRipe([DateTime? now]) {
    if (!isWaiting) return false;
    final at = remindAt;
    if (at == null) return true;
    return !(now ?? clock.now()).isBefore(at);
  }

  Duration waitingSince([DateTime? now]) =>
      (now ?? clock.now()).difference(createdAt);

  /// Betrag, der beim Verzicht als gespart zählt.
  int get savedCents => status == WishStatus.skipped ? priceCents : 0;

  /// Fortschritt 0..1 zwischen Anlegen (bzw. letztem Snooze) und Erinnerung.
  double ripeness([DateTime? now]) {
    final at = remindAt;
    if (at == null) return 1;
    final n = now ?? clock.now();
    final start = priceHistory.isNotEmpty ? createdAt : createdAt;
    final total = at.difference(start).inSeconds;
    if (total <= 0) return 1;
    final done = n.difference(start).inSeconds;
    return (done / total).clamp(0, 1).toDouble();
  }

  double get checkScore =>
      checkAnswers.values.fold<double>(0, (sum, a) => sum + a.points);

  WishItem copyWith({
    String? title,
    int? priceCents,
    List<PricePoint>? priceHistory,
    WishType? type,
    Object? category = _unset,
    Object? trigger = _unset,
    Object? note = _unset,
    Object? url = _unset,
    Object? desireAtCreate = _unset,
    Object? desireAtDecision = _unset,
    DateTime? updatedAt,
    Object? remindAt = _unset,
    int? snoozeCount,
    int? checkVersion,
    Map<String, CheckAnswer>? checkAnswers,
    Object? expectedUses = _unset,
    WishStatus? status,
    Object? decidedAt = _unset,
    Object? decidedPriceCents = _unset,
    Object? hourlyRateSnapshotCents = _unset,
    Object? experienceDate = _unset,
    Object? worthItAnswer = _unset,
  }) {
    return WishItem(
      id: id,
      notificationId: notificationId,
      title: title ?? this.title,
      priceCents: priceCents ?? this.priceCents,
      priceHistory: priceHistory ?? this.priceHistory,
      type: type ?? this.type,
      category: category == _unset
          ? this.category
          : category as WishCategory?,
      trigger: trigger == _unset ? this.trigger : trigger as WishTrigger?,
      note: note == _unset ? this.note : note as String?,
      url: url == _unset ? this.url : url as String?,
      desireAtCreate: desireAtCreate == _unset
          ? this.desireAtCreate
          : desireAtCreate as int?,
      desireAtDecision: desireAtDecision == _unset
          ? this.desireAtDecision
          : desireAtDecision as int?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? clock.now(),
      remindAt: remindAt == _unset ? this.remindAt : remindAt as DateTime?,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      checkVersion: checkVersion ?? this.checkVersion,
      checkAnswers: checkAnswers ?? this.checkAnswers,
      expectedUses: expectedUses == _unset
          ? this.expectedUses
          : expectedUses as int?,
      status: status ?? this.status,
      decidedAt: decidedAt == _unset ? this.decidedAt : decidedAt as DateTime?,
      decidedPriceCents: decidedPriceCents == _unset
          ? this.decidedPriceCents
          : decidedPriceCents as int?,
      hourlyRateSnapshotCents: hourlyRateSnapshotCents == _unset
          ? this.hourlyRateSnapshotCents
          : hourlyRateSnapshotCents as int?,
      experienceDate: experienceDate == _unset
          ? this.experienceDate
          : experienceDate as DateTime?,
      worthItAnswer: worthItAnswer == _unset
          ? this.worthItAnswer
          : worthItAnswer as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'notificationId': notificationId,
    'title': title,
    'priceCents': priceCents,
    'priceHistory': priceHistory.map((p) => p.toJson()).toList(),
    'type': type.name,
    'category': category?.name,
    'trigger': trigger?.name,
    'note': note,
    'url': url,
    'desireAtCreate': desireAtCreate,
    'desireAtDecision': desireAtDecision,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'remindAt': remindAt?.toIso8601String(),
    'snoozeCount': snoozeCount,
    'checkVersion': checkVersion,
    'checkAnswers': checkAnswers.map((k, v) => MapEntry(k, v.name)),
    'expectedUses': expectedUses,
    'status': status.name,
    'decidedAt': decidedAt?.toIso8601String(),
    'decidedPriceCents': decidedPriceCents,
    'hourlyRateSnapshotCents': hourlyRateSnapshotCents,
    'experienceDate': experienceDate?.toIso8601String(),
    'worthItAnswer': worthItAnswer,
  };

  factory WishItem.fromJson(Map<dynamic, dynamic> json) {
    DateTime? date(Object? v) => v == null ? null : DateTime.parse(v as String);
    final answers = <String, CheckAnswer>{};
    final rawAnswers = json['checkAnswers'];
    if (rawAnswers is Map) {
      for (final entry in rawAnswers.entries) {
        final a = CheckAnswer.values
            .where((c) => c.name == entry.value)
            .firstOrNull;
        if (a != null) answers[entry.key as String] = a;
      }
    }
    return WishItem(
      id: json['id'] as String,
      notificationId: json['notificationId'] as int,
      title: json['title'] as String,
      priceCents: json['priceCents'] as int,
      priceHistory: ((json['priceHistory'] as List?) ?? const [])
          .map((e) => PricePoint.fromJson(e as Map))
          .toList(),
      type: WishType.values.byName(json['type'] as String),
      category: _enumOrNull(WishCategory.values, json['category']),
      trigger: _enumOrNull(WishTrigger.values, json['trigger']),
      note: json['note'] as String?,
      url: json['url'] as String?,
      desireAtCreate: json['desireAtCreate'] as int?,
      desireAtDecision: json['desireAtDecision'] as int?,
      createdAt: date(json['createdAt'])!,
      updatedAt: date(json['updatedAt']) ?? date(json['createdAt'])!,
      remindAt: date(json['remindAt']),
      snoozeCount: (json['snoozeCount'] as int?) ?? 0,
      checkVersion: (json['checkVersion'] as int?) ?? 1,
      checkAnswers: answers,
      expectedUses: json['expectedUses'] as int?,
      status: WishStatus.values.byName(
        (json['status'] as String?) ?? 'waiting',
      ),
      decidedAt: date(json['decidedAt']),
      decidedPriceCents: json['decidedPriceCents'] as int?,
      hourlyRateSnapshotCents: json['hourlyRateSnapshotCents'] as int?,
      experienceDate: date(json['experienceDate']),
      worthItAnswer: json['worthItAnswer'] as bool?,
    );
  }
}

const _unset = Object();

T? _enumOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name == null) return null;
  return values.where((v) => v.name == name).firstOrNull;
}
