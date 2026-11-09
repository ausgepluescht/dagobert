/// Rechnet Preise in Netto-Arbeitszeit um.
abstract final class WorkHours {
  /// Durchschnittliche Wochen pro Monat.
  static const weeksPerMonth = 52 / 12;

  /// Netto-Stundenlohn in Cent oder null, wenn Einkommen oder Stunden fehlen.
  static int? hourlyRateCents({
    required int? netMonthlyCents,
    required double? hoursPerWeek,
  }) {
    if (netMonthlyCents == null || netMonthlyCents <= 0) return null;
    if (hoursPerWeek == null || hoursPerWeek <= 0) return null;
    final hoursPerMonth = hoursPerWeek * weeksPerMonth;
    return (netMonthlyCents / hoursPerMonth).round();
  }

  /// Arbeitsstunden für einen Preis oder null ohne Stundenlohn.
  static double? hoursFor(int priceCents, int? hourlyRateCents) {
    if (hourlyRateCents == null || hourlyRateCents <= 0) return null;
    return priceCents / hourlyRateCents;
  }

  /// Arbeitsminuten für einen Preis oder null ohne Stundenlohn.
  static int? minutesFor(int priceCents, int? hourlyRateCents) {
    final h = hoursFor(priceCents, hourlyRateCents);
    if (h == null) return null;
    return (h * 60).round();
  }

  /// "≈ 14 Std", "≈ 2,5 Std", "≈ 40 Min".
  static String format(double? hours) {
    if (hours == null) return '–';
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '≈ $minutes Min';
    }
    if (hours < 10) {
      final rounded = (hours * 2).round() / 2;
      final text = rounded == rounded.roundToDouble()
          ? rounded.toInt().toString()
          : rounded.toString().replaceAll('.', ',');
      return '≈ $text Std';
    }
    return '≈ ${hours.round()} Std';
  }
}

/// Arbeitstage: ein Tag = Wochenstunden / 5, ohne Angabe 8 Stunden.
extension WorkDays on WorkHours {
  static double hoursPerDay(double? hoursPerWeek) {
    if (hoursPerWeek == null || hoursPerWeek <= 0) return 8;
    return hoursPerWeek / 5;
  }

  /// "≈ 14 Std" bzw. ab einem vollen Arbeitstag "≈ 14 Std · 1,8 Arbeitstage".
  static String formatWithDays(double? hours, double hoursPerDay) {
    if (hours == null) return '–';
    final base = WorkHours.format(hours);
    final days = hours / hoursPerDay;
    if (days < 1) return base;
    return '$base · ${formatDays(days)}';
  }

  /// "1,8 Arbeitstage", "1 Arbeitstag", "12 Arbeitstage".
  static String formatDays(double days) {
    final String text;
    if (days >= 10) {
      text = days.round().toString();
    } else {
      final rounded = (days * 10).round() / 10;
      text = rounded == rounded.roundToDouble()
          ? rounded.toInt().toString()
          : rounded.toString().replaceAll('.', ',');
    }
    return text == '1' ? '1 Arbeitstag' : '$text Arbeitstage';
  }
}
