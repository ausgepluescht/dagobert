import 'package:clock/clock.dart';
import 'package:dagobert/models/wish_item.dart';
import 'package:dagobert/services/check_questions.dart';
import 'package:dagobert/services/money_format.dart';
import 'package:dagobert/services/reminder_policy.dart';
import 'package:dagobert/services/work_hours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkHours', () {
    test('Stundenlohn aus Netto und Wochenstunden (52/12 Wochen)', () {
      final rate = WorkHours.hourlyRateCents(
        netMonthlyCents: 280000,
        hoursPerWeek: 40,
      );
      // 2800 / (40 * 4,333) = 16,15 €
      expect(rate, 1615);
    });

    test('null bei fehlendem Einkommen oder 0 Stunden', () {
      expect(WorkHours.hourlyRateCents(netMonthlyCents: null, hoursPerWeek: 40), isNull);
      expect(WorkHours.hourlyRateCents(netMonthlyCents: 0, hoursPerWeek: 40), isNull);
      expect(WorkHours.hourlyRateCents(netMonthlyCents: 280000, hoursPerWeek: 0), isNull);
      expect(WorkHours.hoursFor(24900, null), isNull);
    });

    test('Stunden für Preis und Formatierung', () {
      final h = WorkHours.hoursFor(24900, 1615)!;
      expect(h, closeTo(15.4, 0.1));
      expect(WorkHours.format(h), '≈ 15 Std');
      expect(WorkHours.format(2.5), '≈ 2,5 Std');
      expect(WorkHours.format(0.5), '≈ 30 Min');
      expect(WorkHours.format(null), '–');
    });

    test('Arbeitstage: Wochenstunden / 5, ab einem Tag angehängt', () {
      expect(WorkDays.hoursPerDay(40), 8);
      expect(WorkDays.hoursPerDay(null), 8);
      expect(WorkDays.formatWithDays(5, 8), '≈ 5 Std');
      expect(WorkDays.formatWithDays(14.4, 8), '≈ 14 Std · 1,8 Arbeitstage');
      expect(WorkDays.formatWithDays(8, 8), '≈ 8 Std · 1 Arbeitstag');
      expect(WorkDays.formatWithDays(96, 8), '≈ 96 Std · 12 Arbeitstage');
    });
  });

  group('MoneyFormat', () {
    test('parst deutsche und englische Schreibweisen', () {
      expect(MoneyFormat.parseCents('249'), 24900);
      expect(MoneyFormat.parseCents('249,99'), 24999);
      expect(MoneyFormat.parseCents('1.249,99'), 124999);
      expect(MoneyFormat.parseCents('1249.99'), 124999);
      expect(MoneyFormat.parseCents('1.249'), 124900);
      expect(MoneyFormat.parseCents('12 €'), 1200);
      expect(MoneyFormat.parseCents(''), isNull);
      expect(MoneyFormat.parseCents('abc'), isNull);
    });
  });

  group('ReminderPolicy', () {
    test('Vorauswahl nach Arbeitsstunden', () {
      expect(ReminderPolicy.suggest(type: WishType.want, workHours: 1), ReminderOption.oneDay);
      expect(ReminderPolicy.suggest(type: WishType.want, workHours: 5), ReminderOption.threeDays);
      expect(ReminderPolicy.suggest(type: WishType.want, workHours: 14), ReminderOption.sevenDays);
      expect(ReminderPolicy.suggest(type: WishType.want, workHours: 50), ReminderOption.twoWeeks);
      expect(ReminderPolicy.suggest(type: WishType.want, workHours: 200), ReminderOption.oneMonth);
      expect(ReminderPolicy.suggest(type: WishType.want, workHours: null), ReminderOption.threeDays);
      expect(ReminderPolicy.suggest(type: WishType.need, workHours: 200), ReminderOption.oneDay);
    });

    test('Zeitfenster: zu früh → Fensterbeginn, zu spät → nächster Tag', () {
      const start = TimeOfDay(hour: 9, minute: 0);
      const end = TimeOfDay(hour: 20, minute: 0);
      final early = ReminderPolicy.clampToWindow(DateTime(2026, 11, 10, 6, 30), start: start, end: end);
      expect(early, DateTime(2026, 11, 10, 9, 0));
      final late = ReminderPolicy.clampToWindow(DateTime(2026, 11, 10, 23, 40), start: start, end: end);
      expect(late, DateTime(2026, 11, 11, 9, 0));
      final fine = ReminderPolicy.clampToWindow(DateTime(2026, 11, 10, 14, 0), start: start, end: end);
      expect(fine, DateTime(2026, 11, 10, 14, 0));
    });

    test('remindAtFor addiert Dauer und klemmt ins Fenster', () {
      final now = DateTime(2026, 11, 8, 23, 40);
      final at = ReminderPolicy.remindAtFor(
        now,
        ReminderOption.oneDay,
        windowStart: const TimeOfDay(hour: 9, minute: 0),
        windowEnd: const TimeOfDay(hour: 20, minute: 0),
      );
      expect(at, DateTime(2026, 11, 10, 9, 0));
    });
  });

  group('CheckQuestions', () {
    test('Score zählt nur Kernfragen, Teils = 0,5', () {
      final score = CheckQuestions.score({
        'time': CheckAnswer.yes,
        'story': CheckAnswer.partly,
        'people': CheckAnswer.no,
        'repair': CheckAnswer.yes, // Zusatzfrage zählt nicht
      });
      expect(score, 1.5);
      expect(CheckQuestions.formatScore(score), '1,5');
      expect(CheckQuestions.formatScore(3), '3');
    });

    test('Urteil nach Schwellen', () {
      expect(CheckQuestions.verdict(3), CheckVerdict.smart);
      expect(CheckQuestions.verdict(2.5), CheckVerdict.letItRipen);
      expect(CheckQuestions.verdict(1), CheckVerdict.letItRipen);
      expect(CheckQuestions.verdict(0.5), CheckVerdict.leakage);
      expect(CheckQuestions.verdict(0), CheckVerdict.leakage);
    });

    test('Modi und Need-Zusatzfragen', () {
      expect(CheckQuestions.forMode(CheckMode.core, WishType.want).length, 5);
      expect(CheckQuestions.forMode(CheckMode.core, WishType.need).length, 8);
      expect(CheckQuestions.forMode(CheckMode.impulse, WishType.want).length, 8);
      expect(CheckQuestions.forMode(CheckMode.big, WishType.want).length, 18);
      expect(CheckQuestions.all.map((q) => q.id).toSet().length, CheckQuestions.all.length);
    });

    test('Anteiliges Urteil für lange Listen', () {
      expect(CheckQuestions.verdictFor(12, 18), CheckVerdict.smart);
      expect(CheckQuestions.verdictFor(5, 18), CheckVerdict.letItRipen);
      expect(CheckQuestions.verdictFor(2, 18), CheckVerdict.leakage);
    });
  });

  group('WishItem', () {
    final created = DateTime(2026, 11, 1, 10);
    final item = WishItem(
      id: 'a',
      notificationId: 1001,
      title: 'Kopfhörer',
      priceCents: 24900,
      type: WishType.want,
      createdAt: created,
      updatedAt: created,
      remindAt: created.add(const Duration(days: 7)),
    );

    test('reif, wenn Erinnerung erreicht ist', () {
      expect(item.isRipe(created.add(const Duration(days: 3))), isFalse);
      expect(item.isRipe(created.add(const Duration(days: 7))), isTrue);
      expect(item.copyWith(status: WishStatus.skipped).isRipe(created.add(const Duration(days: 9))), isFalse);
    });

    test('Reife-Fortschritt 0..1', () {
      expect(item.ripeness(created), 0);
      expect(item.ripeness(created.add(const Duration(days: 3, hours: 12))), closeTo(0.5, 0.01));
      expect(item.ripeness(created.add(const Duration(days: 30))), 1);
    });

    test('JSON-Rundlauf behält alle Felder', () {
      final full = item.copyWith(
        category: WishCategory.tech,
        trigger: WishTrigger.sale,
        url: 'https://example.com/x',
        desireAtCreate: 4,
        checkAnswers: {'time': CheckAnswer.yes, 'story': CheckAnswer.partly},
        expectedUses: 20,
        status: WishStatus.skipped,
        decidedAt: created.add(const Duration(days: 8)),
        hourlyRateSnapshotCents: 1615,
      );
      final back = WishItem.fromJson(full.toJson());
      expect(back.title, full.title);
      expect(back.category, WishCategory.tech);
      expect(back.trigger, WishTrigger.sale);
      expect(back.url, 'https://example.com/x');
      expect(back.desireAtCreate, 4);
      expect(back.checkAnswers['story'], CheckAnswer.partly);
      expect(back.expectedUses, 20);
      expect(back.status, WishStatus.skipped);
      expect(back.hourlyRateSnapshotCents, 1615);
      expect(back.remindAt, full.remindAt);
      expect(back.savedCents, 24900);
    });

    test('fromJson ist tolerant gegenüber fehlenden Feldern', () {
      final minimal = WishItem.fromJson({
        'id': 'b',
        'notificationId': 7,
        'title': 'X',
        'priceCents': 100,
        'type': 'need',
        'createdAt': created.toIso8601String(),
      });
      expect(minimal.status, WishStatus.waiting);
      expect(minimal.checkAnswers, isEmpty);
      expect(minimal.updatedAt, created);
    });

    test('waitingSince nutzt injizierte Uhr', () {
      withClock(Clock.fixed(created.add(const Duration(days: 5))), () {
        expect(item.waitingSince().inDays, 5);
      });
    });
  });
}
