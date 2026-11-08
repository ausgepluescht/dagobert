import '../models/wish_item.dart';

class CheckQuestion {
  const CheckQuestion({
    required this.id,
    required this.question,
    required this.why,
    required this.prompt,
  });

  final String id;
  final String question;
  final String why;
  final String prompt;
}

enum CheckVerdict {
  smart,
  letItRipen,
  leakage;

  String get title => switch (this) {
    CheckVerdict.smart => 'Klingt nach einer klugen Ausgabe.',
    CheckVerdict.letItRipen => 'Lass es reifen.',
    CheckVerdict.leakage => 'Stille Leckage. Willst du wirklich?',
  };

  String get body => switch (this) {
    CheckVerdict.smart =>
      'Drei oder mehr Punkte. Das Geld kauft dir Zeit, Erlebnisse oder Nähe. Gönn es dir bewusst.',
    CheckVerdict.letItRipen =>
      'Ein bis zwei Punkte. Nicht schlecht, aber auch kein klares Ja. Gib dem Wunsch Zeit, dann entscheidest du mit kühlem Kopf.',
    CheckVerdict.leakage =>
      'Null Punkte. Wahrscheinlich macht dich das elf Tage lang glücklich und dann liegt es in der Schublade.',
  };
}

abstract final class CheckQuestions {
  static const version = 1;

  /// Die fünf Happy-Money-Fragen (Dunn & Norton).
  static const core = <CheckQuestion>[
    CheckQuestion(
      id: 'time',
      question: 'Kauft mir das Zeit oder stiehlt es sie?',
      why:
          'Menschen, die Geld ausgeben, um Zeit zu sparen, sind messbar zufriedener als Menschen, die Dinge kaufen. Trotzdem unterschätzen wir Zeit systematisch.',
      prompt:
          'Nimmt es Reibung aus deinem Alltag? Und was machst du mit der gewonnenen Zeit?',
    ),
    CheckQuestion(
      id: 'story',
      question: 'Ist das eine Geschichte oder nur ein Ding?',
      why:
          'Erlebnisse werden Teil deiner Identität, lassen sich kaum vergleichen und werden in der Erinnerung besser. Dinge nutzen sich ab. Geschichten gewinnen.',
      prompt:
          'Bist du in sechs Monaten froh darüber, oder liegt es dann in der Schublade?',
    ),
    CheckQuestion(
      id: 'people',
      question: 'Bringt mich das anderen Menschen näher?',
      why:
          'Geld für andere oder mit anderen auszugeben macht glücklicher als Geld nur für dich. Solo-Freude flacht ab, geteilte Freude verstärkt sich.',
      prompt:
          'Wer profitiert außer dir? Teilst du es, schenkst du es, erlebst du es mit jemandem?',
    ),
    CheckQuestion(
      id: 'treat',
      question: 'Kann ich es zum Treat statt zur Gewohnheit machen?',
      why:
          'Das zehnte Mal fühlt sich normal an, das zwanzigste erwartbar. Hedonische Anpassung. Seltenheit stellt den Genuss wieder her.',
      prompt:
          'Wie oft wäre "besonders"? Kannst du Leitplanken um das Vergnügen bauen?',
    ),
    CheckQuestion(
      id: 'anticipation',
      question: 'Kann ich jetzt zahlen und später genießen?',
      why:
          'Vorfreude ist eine Form von Glück und macht aus einem Moment viele. Wer vorher zahlt, denkt beim Erleben nicht mehr an die Kosten.',
      prompt: 'Gibt es etwas, worauf du dich freuen kannst?',
    ),
  ];

  /// Zusatzfragen im Modus "Brauche ich": Es geht nicht um *ob*, sondern *wie*.
  static const need = <CheckQuestion>[
    CheckQuestion(
      id: 'repair',
      question: 'Reparieren statt neu kaufen?',
      why:
          'Eine Reparatur kostet oft ein Viertel des Neupreises und bringt dir dasselbe Ergebnis.',
      prompt: 'Hast du eine Reparatur geprüft oder einen Preis dafür eingeholt?',
    ),
    CheckQuestion(
      id: 'lifetime',
      question: 'Habe ich Lebensdauer und Folgekosten bedacht?',
      why:
          'Der günstigste Kaufpreis ist selten der günstigste Gesamtpreis. Energie, Verbrauchsmaterial und Haltbarkeit zählen mit.',
      prompt: 'Was kostet das Gerät über fünf Jahre, nicht nur heute?',
    ),
    CheckQuestion(
      id: 'convenience',
      question: 'Spart eine Variante spürbar Zeit?',
      why:
          'Lieferung, Aufbau und Altgeräte-Mitnahme kosten etwas, geben dir aber einen Samstag zurück.',
      prompt: 'Lohnt sich der Aufpreis für Lieferung und Aufbau?',
    ),
  ];

  static List<CheckQuestion> forType(WishType type) =>
      type == WishType.need ? [...core, ...need] : core;

  /// Bewertung der fünf Kernfragen. Teils = 0,5 Punkte.
  static double score(Map<String, CheckAnswer> answers) {
    double sum = 0;
    for (final q in core) {
      final a = answers[q.id];
      if (a != null) sum += a.points;
    }
    return sum;
  }

  static CheckVerdict verdict(double score) {
    if (score >= 3) return CheckVerdict.smart;
    if (score >= 1) return CheckVerdict.letItRipen;
    return CheckVerdict.leakage;
  }

  static String formatScore(double score) {
    if (score == score.roundToDouble()) return score.toInt().toString();
    return score.toString().replaceAll('.', ',');
  }
}
