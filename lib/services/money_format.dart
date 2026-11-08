import 'package:intl/intl.dart';

abstract final class MoneyFormat {
  static final _whole = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 0,
  );
  static final _cents = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );
  static final _plain = NumberFormat.decimalPattern('de_DE');

  /// "249 €" oder "249,99 €". Ganze Beträge ohne Nachkommastellen.
  static String euro(int cents, {bool forceCents = false}) {
    if (!forceCents && cents % 100 == 0) return _whole.format(cents / 100);
    return _cents.format(cents / 100);
  }

  /// "1.248" für Eingabefelder.
  static String plain(int cents) {
    if (cents % 100 == 0) return _plain.format(cents ~/ 100);
    return NumberFormat('#,##0.00', 'de_DE').format(cents / 100);
  }

  /// Parst "1.249,99", "1249.99", "249" → Cent. null bei Unsinn.
  static int? parseCents(String input) {
    var s = input.trim().replaceAll('€', '').replaceAll(' ', '');
    if (s.isEmpty) return null;
    final lastComma = s.lastIndexOf(',');
    final lastDot = s.lastIndexOf('.');
    if (lastComma > lastDot) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (lastDot > lastComma) {
      final afterDot = s.length - lastDot - 1;
      if (afterDot == 3 && !s.contains(',')) {
        s = s.replaceAll('.', '');
      } else {
        s = s.replaceAll(',', '');
      }
    }
    final value = double.tryParse(s);
    if (value == null || value < 0) return null;
    return (value * 100).round();
  }
}
