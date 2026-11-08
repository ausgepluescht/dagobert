/// Deutsche Dauer-Texte für Wartezeit und Erinnerungen.
abstract final class TimeFormat {
  /// "seit 7 Tagen", "seit 5 Std", "seit gerade eben".
  static String since(Duration d) {
    if (d.inMinutes < 60) return 'seit gerade eben';
    if (d.inHours < 24) return 'seit ${d.inHours} Std';
    final days = d.inDays;
    if (days == 1) return 'seit 1 Tag';
    if (days < 60) return 'seit $days Tagen';
    final months = (days / 30).floor();
    return months == 1 ? 'seit 1 Monat' : 'seit $months Monaten';
  }

  /// "nach 7 Tagen", "nach 5 Std".
  static String after(Duration d) {
    if (d.inHours < 1) return 'sofort';
    if (d.inHours < 24) return 'nach ${d.inHours} Std';
    final days = d.inDays;
    return days == 1 ? 'nach 1 Tag' : 'nach $days Tagen';
  }

  /// "in 2 Tagen", "in 5 Std", "jetzt".
  static String until(Duration d) {
    if (d.isNegative || d.inMinutes < 1) return 'jetzt';
    if (d.inMinutes < 60) return 'in ${d.inMinutes} Min';
    if (d.inHours < 24) return 'in ${d.inHours} Std';
    final days = d.inDays;
    return days == 1 ? 'in 1 Tag' : 'in $days Tagen';
  }

  /// "7 Tage", "5 Std".
  static String compact(Duration d) {
    if (d.inHours < 1) return '${d.inMinutes} Min';
    if (d.inHours < 24) return '${d.inHours} Std';
    final days = d.inDays;
    return days == 1 ? '1 Tag' : '$days Tage';
  }

  /// "Noch 12 Tage".
  static String daysLeft(Duration d) {
    if (d.isNegative) return 'Heute';
    final days = d.inDays;
    if (days == 0) return 'Heute';
    if (days == 1) return 'Noch 1 Tag';
    return 'Noch $days Tage';
  }
}
