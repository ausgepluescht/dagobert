import '../models/wish_item.dart';

/// Themenblock einer Frage.
enum CheckSection {
  core('Kernfragen', 'Die fünf Fragen aus „Happy Money“. Für jeden Kauf.'),
  deeper('Weiter nachgedacht', 'Passt der Kauf zu dir und zu deinem Geld?'),
  forward('Mit Blick nach vorn', 'Wie siehst du das in einem Jahr?'),
  moment('Im Moment der Entscheidung', 'Die drei Fallen an der Kasse.'),
  need('Brauche ich', 'Nicht ob, sondern wie: Reparatur, Folgekosten, Aufwand.');

  const CheckSection(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// Umfang des Checks.
enum CheckMode {
  core('Kernfragen', 'Die fünf Happy-Money-Fragen. Für jeden Kauf.', [CheckSection.core]),
  impulse('Spontankauf', 'Kernfragen plus die drei Fallen an der Kasse.', [
    CheckSection.core,
    CheckSection.moment,
  ]),
  big('Großer Kauf', 'Alle Fragen für Entscheidungen, die zählen.', [
    CheckSection.core,
    CheckSection.deeper,
    CheckSection.forward,
    CheckSection.moment,
  ]);

  const CheckMode(this.title, this.description, this.sections);
  final String title;
  final String description;
  final List<CheckSection> sections;
}

class CheckQuestion {
  const CheckQuestion({
    required this.id,
    required this.section,
    required this.question,
    required this.background,
    required this.limit,
    required this.prompt,
  });

  final String id;
  final CheckSection section;
  final String question;

  /// Forschungshintergrund, ein Absatz pro Eintrag.
  final List<String> background;

  /// Grenzen der Befundlage.
  final String limit;

  /// Kurzer Denkanstoß.
  final String prompt;
}

enum CheckVerdict {
  smart,
  letItRipen,
  leakage;

  String get title => switch (this) {
    CheckVerdict.smart => 'Klingt nach einer klugen Ausgabe.',
    CheckVerdict.letItRipen => 'Lass es reifen.',
    CheckVerdict.leakage => 'Hier versickert Geld.',
  };

  String get body => switch (this) {
    CheckVerdict.smart =>
      'Das Geld kauft dir Zeit, Erlebnisse oder Nähe. Gönn es dir mit gutem Gewissen.',
    CheckVerdict.letItRipen =>
      'Kein klares Ja, kein klares Nein. Gib dem Wunsch ein paar Tage, dann entscheidest du mit kühlem Kopf.',
    CheckVerdict.leakage =>
      'Wahrscheinlich macht dich das elf Tage lang glücklich, danach liegt es in der Schublade.',
  };
}

abstract final class CheckQuestions {
  static const version = 2;

  static const core = <CheckQuestion>[
    CheckQuestion(
      id: 'time',
      section: CheckSection.core,
      question: 'Kauft mir das Zeit oder stiehlt es mir welche?',
      background: [
        'Ashley Whillans, Elizabeth Dunn und Kollegen haben Tausende Erwachsene in den USA, Kanada, Dänemark und den Niederlanden befragt. Wer regelmäßig Geld ausgibt, um Zeit zu sparen, etwa für Hilfe im Haushalt, einen kürzeren Arbeitsweg oder abgegebene Aufgaben, ist zufriedener mit seinem Leben.',
        'Die typische Falle ist das große Haus im Grünen, das vor allem den Arbeitsweg verlängert. Mehr Wohnfläche wird gegen Lebensstunden getauscht. Trotzdem unterschätzen wir den Wert von Zeit systematisch.',
        'Entscheidend ist, was du mit der gewonnenen Zeit machst. Füllst du sie mit mehr Arbeit, verpufft der Effekt. Nutzt du sie für Freunde, Bewegung, Lesen oder Ruhe, wird sie zum echten Gewinn.',
      ],
      limit:
          'Das Feldexperiment hatte nur 60 Teilnehmende und kleine Beträge. Wie gut der Effekt bei großen Summen trägt, ist offen.',
      prompt: 'Nimmt es Reibung aus deinem Alltag? Und wofür nutzt du die gewonnene Zeit?',
    ),
    CheckQuestion(
      id: 'story',
      section: CheckSection.core,
      question: 'Wird das eine Erinnerung oder nur ein Gegenstand?',
      background: [
        'Über viele Studien hinweg gilt: Erlebnisse schlagen Besitz, sobald die Grundbedürfnisse gedeckt sind. Erlebnisse werden Teil deiner Identität, lassen sich schwer vergleichen und werden in der Erinnerung oft schöner. An Dinge gewöhnst du dich.',
        'Wichtige Ergänzung von Darwin Guevarra und Ryan Howell: Dinge, mit denen du etwas tust, etwa ein Instrument, Sportausrüstung oder ein Brettspiel, machen ähnlich glücklich wie Erlebnisse und deutlich glücklicher als reiner Besitz.',
        'Die entscheidende Frage ist also weniger Ding oder Erlebnis, sondern ob du damit etwas erlebst oder es nur besitzt.',
      ],
      limit:
          'Die meisten Studien beruhen auf Selbstauskünften über frühere Käufe, nicht auf Experimenten mit Zufallszuteilung.',
      prompt: 'Bist du in sechs Monaten froh darüber, oder liegt es dann in der Schublade?',
    ),
    CheckQuestion(
      id: 'people',
      section: CheckSection.core,
      question: 'Bringt mich das anderen Menschen näher?',
      background: [
        'Geld für andere macht im Schnitt glücklicher als Geld für sich selbst. Der Effekt wurde bei Kleinkindern, in Uganda, in Kanada und in Befragungen aus über 130 Ländern gefunden.',
        'Am stärksten wirkt es, wenn du freiwillig gibst, ohne Schuldgefühl, für jemanden, der dir wichtig ist, und wenn du die Wirkung siehst. Eine Spende an eine große, abstrakte Organisation bringt oft wenig. Konkrete Hilfe mit sichtbarem Ergebnis bringt viel.',
        'Auch Erlebnisse wirken oft deshalb so gut, weil man sie mit anderen teilt.',
      ],
      limit:
          'Eine große vorregistrierte Wiederholungsstudie von Lara Aknin und Kollegen bestätigte den Effekt im Experiment, fand ihn beim bloßen Erinnern an frühere Käufe aber nicht. Der Effekt ist echt, aber kleiner als oft dargestellt.',
      prompt: 'Wer hat etwas davon außer dir? Teilst du es, schenkst du es, erlebst du es mit jemandem?',
    ),
    CheckQuestion(
      id: 'treat',
      section: CheckSection.core,
      question: 'Bleibt das etwas Besonderes, oder wird es zur Gewohnheit?',
      background: [
        'Die Forschung nennt das hedonische Anpassung. Das schicke Auto ist bei der ersten Fahrt großartig, bei der zehnten normal und bei der zwanzigsten selbstverständlich. Dieselbe Freude, zu oft gekauft, wird zur neuen Grundlinie.',
        'Häufigkeit nutzt Freude ab, Seltenheit stellt sie wieder her. Wenn alles besonders ist, ist nichts mehr besonders.',
        'Dazu passt ein Befund von Dunn, Gilbert und Wilson: Wie glücklich Menschen sind, hängt stärker davon ab, wie oft sie Schönes erleben, als davon, wie intensiv es ist. Viele kleine Freuden sind oft die bessere Investition als eine große.',
      ],
      limit:
          'Dass wir uns an Gutes gewöhnen, ist sehr gut belegt. Wie gut bewusste Seltenheit im Alltag dagegen hilft, ist weniger direkt untersucht.',
      prompt: 'Wie selten müsste es sein, damit es besonders bleibt?',
    ),
    CheckQuestion(
      id: 'anticipation',
      section: CheckSection.core,
      question: 'Kann ich jetzt zahlen und später genießen?',
      background: [
        'Vorfreude ist selbst eine Form von Glück und macht aus einem Moment viele. Wer vorher bezahlt, trennt den Schmerz des Bezahlens vom Genuss.',
        'Amit Kumar, Matthew Killingsworth und Thomas Gilovich haben gezeigt, dass Menschen glücklicher sind, während sie an ein kommendes Erlebnis denken. Das Warten auf Erlebnisse fühlt sich nach Vorfreude an, das Warten auf Dinge eher nach Ungeduld.',
        'Wer mit Abstand entscheidet, wählt außerdem oft besser als im Moment selbst. Kauf also nicht nur Erlebnisse, sondern auch Vorfreude.',
      ],
      limit:
          'Gut belegt ist der Wert der Vorfreude. Dass Vorauszahlen den Genuss steigert, stützt sich auf weniger direkte Studien.',
      prompt: 'Gibt es etwas, worauf du dich freuen kannst?',
    ),
  ];

  static const deeper = <CheckQuestion>[
    CheckQuestion(
      id: 'opportunity',
      section: CheckSection.deeper,
      question: 'Ist mir das mehr wert als alles andere, was ich mit dem Geld machen könnte?',
      background: [
        'Jedem Kauf steht eine Alternative gegenüber, nur denken wir sie selten mit. Shane Frederick und Kollegen nennen das Vernachlässigung der Opportunitätskosten.',
        'In ihrer bekanntesten Studie sank der Anteil der Kaufwilligen für eine DVD von 75 auf 55 Prozent, sobald beim Nichtkaufen nur der Hinweis stand, dass man das Geld dann für anderes behält. Allein die Frage nach der Alternative macht dich klarer.',
      ],
      limit: 'Eine Meta-Analyse bestätigt den Effekt als robust, aber deutlich kleiner als in der Originalstudie.',
      prompt: 'Was wäre die beste Alternative für dieses Geld?',
    ),
    CheckQuestion(
      id: 'fit',
      section: CheckSection.deeper,
      question: 'Passt das wirklich zu mir?',
      background: [
        'Sandra Matz und Kollegen haben rund 77.000 echte Kontobewegungen britischer Bankkunden mit deren Persönlichkeit abgeglichen. Wer mehr für Dinge ausgab, die zu seiner Persönlichkeit passen, war zufriedener. Dieser Zusammenhang war stärker als der mit Einkommen oder Gesamtausgaben.',
        'Im Folgeexperiment profitierten Extrovertierte mehr von einem Barbesuch und Introvertierte mehr vom Buchladen. Es gibt also kein allgemein richtiges Ausgeben, sondern eines, das zu dir passt.',
      ],
      limit: 'Bisher vor allem eine große Feldstudie mit einem Folgeexperiment, weitere Bestätigungen stehen aus.',
      prompt: 'Welche Seite von dir zeigt sich darin?',
    ),
    CheckQuestion(
      id: 'status',
      section: CheckSection.deeper,
      question: 'Kaufe ich das für mich, nicht um andere zu beeindrucken?',
      background: [
        'Eine große Meta-Analyse von Helga Dittmar, Tim Kasser und Kollegen hat 259 Stichproben ausgewertet. Je wichtiger Menschen Geld, Besitz und Status nehmen, desto geringer ist im Schnitt ihr Wohlbefinden.',
        'Die Erklärung: Dabei kommen grundlegende Bedürfnisse zu kurz, etwa Verbundenheit, Selbstbestimmung und das Gefühl, etwas zu können. Die Gegenprobe lautet, ob du den Kauf auch tätigen würdest, wenn ihn niemand sieht.',
      ],
      limit: 'Die Befunde sind sehr konsistent, aber überwiegend korrelativ.',
      prompt: 'Welches echte Bedürfnis erfüllt es dir?',
    ),
    CheckQuestion(
      id: 'ordinary_day',
      section: CheckSection.deeper,
      question: 'Habe ich an einen ganz normalen Tag damit gedacht?',
      background: [
        'Beim Kaufen schauen wir auf die auffälligen Seiten und übersehen die versteckten. Das Beispiel von Dunn, Gilbert und Wilson ist das größere Haus, das wie ein gutes Geschäft aussieht, bis die Samstage mit Freunden zu Samstagen mit Handwerkern werden.',
        'Dazu passt ihre Warnung vor dem Produktvergleich: Beim Vergleichen achten wir auf die Merkmale, in denen sich Angebote unterscheiden, obwohl im Alltag oft ganz andere Dinge zählen.',
      ],
      limit: 'Die Denkfehler sind gut erforscht, die direkte Wirkung dieser Übung auf Kaufentscheidungen weniger.',
      prompt: 'Was ändert sich an einem normalen Dienstag?',
    ),
    CheckQuestion(
      id: 'others_experience',
      section: CheckSection.deeper,
      question: 'Sind Menschen, die das schon haben, damit wirklich zufrieden?',
      background: [
        'Unsere Vorstellung davon, wie sehr uns etwas freuen wird, ist erstaunlich ungenau. Dunn, Gilbert und Wilson empfehlen deshalb, auf die Erfahrungen anderer zu schauen. Wir kennen uns selbst besser, aber andere kennen das Produkt besser.',
        'Freunde und Bekannte haben gegenüber Online-Bewertungen einen Vorteil, denn sie können einschätzen, ob es zu dir passt.',
      ],
      limit: 'Die Grundlage sind Laborstudien zu Gefühlsvorhersagen, nicht Studien zu echten Käufen.',
      prompt: 'Wen hast du gefragt?',
    ),
    CheckQuestion(
      id: 'buffer',
      section: CheckSection.deeper,
      question: 'Kann ich das bezahlen, ohne meinen Puffer anzugreifen oder Schulden zu machen?',
      background: [
        'Peter Ruberton, Joe Gladstone und Sonja Lyubomirsky haben Kontodaten von 585 Bankkunden ausgewertet. Wie viel Geld jemand auf Giro- und Sparkonto hatte, hing stärker mit der Lebenszufriedenheit zusammen als Einkommen, Geldanlagen oder Schulden. Der Weg führt über das Gefühl finanzieller Sicherheit.',
        'Eine Meta-Analyse von Thomas Richardson und Kollegen zeigt zudem einen deutlichen Zusammenhang zwischen Konsumschulden und psychischen Belastungen.',
      ],
      limit: 'Beide Arbeiten zeigen Zusammenhänge, keine eindeutige Ursache.',
      prompt: 'Wie lange brauchst du, um das Geld wieder anzusparen?',
    ),
  ];

  static const forward = <CheckQuestion>[
    CheckQuestion(
      id: 'regret',
      section: CheckSection.forward,
      question: 'Würde ich es eher bereuen, das nicht zu tun?',
      background: [
        'Emily Rosenzweig und Thomas Gilovich haben in fünf Studien untersucht, welche Art von Reue Käufe auslösen. Bei Dingen bereuen Menschen eher, dass sie gekauft haben. Bei Erlebnissen bereuen sie eher, dass sie es nicht getan haben.',
        'Der Grund: Erlebnisse gelten als einmalig, Dinge als austauschbar. Bei einem Ding fragst du also, ob du in einem Jahr Kaufreue hättest. Bei einem Erlebnis fragst du, ob du es verpasst hättest.',
      ],
      limit: 'Die Befunde stammen überwiegend aus Rückblicken auf frühere Käufe.',
      prompt: 'Was genau würdest du verpassen?',
    ),
    CheckQuestion(
      id: 'savoring',
      section: CheckSection.forward,
      question: 'Nehme ich mir Zeit, das bewusst zu genießen?',
      background: [
        'Genießen ist eine Fähigkeit. Dazu gehört, im Moment zu bleiben, sich vorher zu freuen, später zurückzudenken und anderen davon zu erzählen. Menschen, die das gut können, sind nachweislich glücklicher.',
        'Jordi Quoidbach, Elizabeth Dunn und Kollegen fanden, dass wohlhabendere Menschen schlechter genießen können. Ein Kauf bringt nur so viel Freude, wie du dir Zeit nimmst, ihn auszukosten.',
      ],
      limit: 'Dass Genießen glücklich macht, ist gut gestützt. Experimente mit bloßen Geldreizen ließen sich oft schlecht wiederholen.',
      prompt: 'Wie willst du es auskosten?',
    ),
    CheckQuestion(
      id: 'future_self',
      section: CheckSection.forward,
      question: 'Würde mein Ich in einem Jahr diesen Kauf gutheißen?',
      background: [
        'Viele Menschen erleben ihr zukünftiges Ich fast wie eine fremde Person. Deshalb fällt es schwer, heute für später zu verzichten.',
        'Hal Hershfield und Kollegen ließen Menschen ihr eigenes, digital gealtertes Gesicht sehen. Danach legten sie mehr Geld für später zurück. Stell dir kurz konkret vor, wie du in einem Jahr auf diese Entscheidung schaust.',
      ],
      limit: 'Die Experimente maßen überwiegend hypothetische Spar-Entscheidungen.',
      prompt: 'Was würde dein Ich in einem Jahr sagen?',
    ),
    CheckQuestion(
      id: 'commit',
      section: CheckSection.forward,
      question: 'Kann ich mich danach festlegen, statt mir alles offenzuhalten?',
      background: [
        'Daniel Gilbert und Jane Ebert gaben Fotografie-Studierenden einen Abzug ihres Lieblingsfotos. Ein Teil durfte das Bild noch tauschen, der andere nicht. Wer sich endgültig festgelegt hatte, war zufriedener.',
        'Wir halten Rückgaberechte für Freiheit, sie halten uns aber gedanklich bei der Entscheidung fest. Solange eine Entscheidung offen ist, fallen uns die Schwächen der gewählten Option stärker auf.',
      ],
      limit: 'Gut untersucht im Labor mit kleineren Stichproben. Bei Fehlkäufen bleibt ein Rückgaberecht sinnvoll.',
      prompt: 'Wie gehst du nach dem Kauf damit um?',
    ),
  ];

  static const moment = <CheckQuestion>[
    CheckQuestion(
      id: 'cash',
      section: CheckSection.moment,
      question: 'Würde ich das auch kaufen, wenn ich bar bezahlen müsste?',
      background: [
        'Bargeld zu übergeben tut ein bisschen weh, Karte oder Handy kaum. Die Forschung nennt das den Schmerz des Bezahlens.',
        'Eine Meta-Analyse von Lachlan Schomburgk und Kollegen über 71 Studien findet, dass Menschen bargeldlos im Schnitt mehr ausgeben. Das gilt für Kreditkarte, Girokarte und Später-zahlen-Angebote gleichermaßen.',
      ],
      limit: 'Der Effekt ist klein, aber stabil.',
      prompt: 'Wie willst du bezahlen?',
    ),
    CheckQuestion(
      id: 'good_day',
      section: CheckSection.moment,
      question: 'Würde ich das auch an einem guten Tag kaufen?',
      background: [
        'Jennifer Lerner, Cynthia Cryder und Kollegen haben gezeigt, dass schon leichte Traurigkeit die Zahlungsbereitschaft deutlich erhöht. Dahinter steht der Versuch, sich über einen Kauf aufzuwerten.',
        'Bemerkenswert: Die traurigen Teilnehmenden waren überzeugt, ihre Stimmung habe keinen Einfluss. Deshalb lohnt es sich, kurz innezuhalten, statt sich auf das eigene Gefühl zu verlassen.',
      ],
      limit: 'Laborexperimente mit kleinen Stichproben.',
      prompt: 'Wie fühlst du dich gerade?',
    ),
    CheckQuestion(
      id: 'good_enough',
      section: CheckSection.moment,
      question: 'Ist das gut genug, auch wenn es nicht das Allerbeste ist?',
      background: [
        'Barry Schwartz und Kollegen unterscheiden Maximierer, die immer die beste Option suchen, von Zufriedenen, die nehmen, was ihre Ansprüche erfüllt. Maximierer waren weniger zufrieden mit ihren Käufen, verglichen sich mehr und bereuten mehr.',
        'Für dich heißt das: vorher festlegen, was der Kauf können muss, und beim ersten Angebot zugreifen, das das erfüllt.',
      ],
      limit: 'Die Messung von Maximieren ist umstritten.',
      prompt: 'Wie viele Optionen hast du verglichen?',
    ),
  ];

  /// Zusatzfragen im Modus "Brauche ich": nicht ob, sondern wie.
  static const need = <CheckQuestion>[
    CheckQuestion(
      id: 'repair',
      section: CheckSection.need,
      question: 'Habe ich eine Reparatur geprüft?',
      background: [
        'Eine Reparatur kostet oft ein Viertel des Neupreises und bringt dir dasselbe Ergebnis.',
      ],
      limit: '',
      prompt: 'Hast du einen Preis für die Reparatur eingeholt?',
    ),
    CheckQuestion(
      id: 'lifetime',
      section: CheckSection.need,
      question: 'Habe ich Lebensdauer und Folgekosten mitgerechnet?',
      background: [
        'Der günstigste Kaufpreis ist selten der günstigste Gesamtpreis. Energie, Verbrauchsmaterial und Haltbarkeit zählen mit.',
      ],
      limit: '',
      prompt: 'Was kostet das Gerät über fünf Jahre, nicht nur heute?',
    ),
    CheckQuestion(
      id: 'convenience',
      section: CheckSection.need,
      question: 'Spart mir eine Variante spürbar Aufwand?',
      background: [
        'Lieferung, Aufbau und Mitnahme des Altgeräts kosten etwas, geben dir aber einen Samstag zurück.',
      ],
      limit: '',
      prompt: 'Lohnt sich der Aufpreis für Lieferung und Aufbau?',
    ),
  ];

  static List<CheckQuestion> forSection(CheckSection s) => switch (s) {
    CheckSection.core => core,
    CheckSection.deeper => deeper,
    CheckSection.forward => forward,
    CheckSection.moment => moment,
    CheckSection.need => need,
  };

  /// Fragen für Modus und Typ. "Brauche ich" hängt die Zusatzfragen an.
  static List<CheckQuestion> forMode(CheckMode mode, WishType type) {
    final list = <CheckQuestion>[
      for (final s in mode.sections) ...forSection(s),
    ];
    if (type == WishType.need) list.addAll(need);
    return list;
  }

  static List<CheckQuestion> get all => [
    ...core,
    ...deeper,
    ...forward,
    ...moment,
    ...need,
  ];

  static CheckQuestion? byId(String id) =>
      all.where((q) => q.id == id).firstOrNull;

  /// Bewertung der fünf Kernfragen. Teils = 0,5 Punkte.
  static double score(Map<String, CheckAnswer> answers) {
    double sum = 0;
    for (final q in core) {
      final a = answers[q.id];
      if (a != null) sum += a.points;
    }
    return sum;
  }

  /// Punkte über eine beliebige Fragenliste.
  static double scoreFor(
    List<CheckQuestion> questions,
    Map<String, CheckAnswer> answers,
  ) {
    double sum = 0;
    for (final q in questions) {
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

  /// Urteil anteilig für längere Fragenlisten (60 % / 20 % der Punkte).
  static CheckVerdict verdictFor(double score, int total) {
    if (total <= 0) return CheckVerdict.leakage;
    final ratio = score / total;
    if (ratio >= 0.6) return CheckVerdict.smart;
    if (ratio >= 0.2) return CheckVerdict.letItRipen;
    return CheckVerdict.leakage;
  }

  static String formatScore(double score) {
    if (score == score.roundToDouble()) return score.toInt().toString();
    return score.toString().replaceAll('.', ',');
  }
}
