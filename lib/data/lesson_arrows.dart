import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonArrows = Lesson(
  id: 'arrows',
  title: 'Pfeile und Verbindungen',
  subtitle: 'Vom einfachen Pfeil bis zum Kreislauf',
  intro: 'Pfeile zeigen Richtung, Abfolge und Zusammenhang. Die Regel für alle: erst die Linie, dann die Spitze. '
      'Eine offene Spitze wie ein V wirkt leichter als ein ausgemaltes Dreieck.',
  figures: [
    Figure(
      id: 'arrows.simple',
      name: 'Einfacher Pfeil',
      meaning: 'Richtung, Folge, Übergang',
      mnemonic: 'Linie zuerst, Spitze zuletzt. Die Spitze ist ein offenes V, beide Schenkel gleich lang.',
      steps: [
        FigureStep(title: 'Linie', hint: 'Von links nach rechts, flott durchziehen.', strokes: [
          Fig.s(Shapes.line(14, 50, 80, 50)),
        ]),
        FigureStep(title: 'Spitze', hint: 'Von oben links zur Spitze und nach unten links zurück, in einem Zug.', strokes: [
          Fig.s(Fig.head(84, 50, 1, 0, len: 14, half: 10)),
        ]),
      ],
    ),
    Figure(
      id: 'arrows.block',
      name: 'Blockpfeil',
      meaning: 'Große Übergänge, Hauptrichtung',
      mnemonic: 'Ein liegendes Rechteck, das rechts in ein Dreieck läuft. Der Schatten liegt unten und an der Spitze rechts.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Umriss', hint: 'Links oben starten, zur Spitze rechts, unten zurück. Alles ein geschlossener Zug.', strokes: [
          Fig.s(Shapes.poly([14, 40, 58, 40, 58, 26, 86, 50, 58, 74, 58, 60, 14, 60], close: true)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau unter dem Schaft und entlang der unteren Spitzenkante.', strokes: [
          Fig.grey(Shapes.line(18, 64, 56, 64), width: MarkerWidth.thick),
          Fig.grey(Shapes.line(61, 77, 88, 54), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'arrows.curve',
      name: 'Schwungpfeil',
      meaning: 'Dynamik, Entwicklung, Sprung nach vorn',
      mnemonic: 'Der Bogen kommt aus dem Ellbogen. Die Spitze steht quer zur Bogenrichtung am Ende.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Bogen', hint: 'Unten links starten, hoch schwingen, rechts auslaufen lassen.', strokes: [
          Fig.s(Shapes.quad(18, 72, 34, 14, 80, 36)),
        ]),
        FigureStep(title: 'Spitze', hint: 'Das V zeigt in die Richtung, in die der Bogen zuletzt lief.', strokes: [
          Fig.s(Fig.head(82, 37, 45, 20)),
        ]),
      ],
    ),
    Figure(
      id: 'arrows.cycle',
      name: 'Kreislauf',
      meaning: 'Wiederholung, Prozess, Feedback-Schleife',
      mnemonic: 'Zwei halbe Kreise, die sich jagen. Jeder Bogen endet in einer Spitze, die auf den Anfang des nächsten zeigt.',
      difficulty: 3,
      steps: [
        FigureStep(title: 'Oberer Bogen', hint: 'Von links unten über oben nach rechts, ein knapper Halbkreis.', strokes: [
          Fig.s(Shapes.arc(50, 50, 28, -150, 120)),
        ]),
        FigureStep(title: 'Spitze oben', hint: 'Das V am Ende des oberen Bogens zeigt nach unten rechts.', strokes: [
          Fig.s(Fig.head(74.2, 36, 0.5, 0.866, len: 11, half: 7)),
        ]),
        FigureStep(title: 'Unterer Bogen', hint: 'Von rechts unten über unten nach links, spiegelgleich.', strokes: [
          Fig.s(Shapes.arc(50, 50, 28, 30, 120)),
        ]),
        FigureStep(title: 'Spitze unten', hint: 'Das zweite V zeigt nach oben links. Fertig ist der Kreislauf.', strokes: [
          Fig.s(Fig.head(25.8, 64, -0.5, -0.866, len: 11, half: 7)),
        ]),
      ],
    ),
    Figure(
      id: 'arrows.double',
      name: 'Doppelpfeil',
      meaning: 'Austausch, Spannung, Wechselwirkung',
      mnemonic: 'Eine Linie, zwei Spitzen. Beide V gleich groß.',
      steps: [
        FigureStep(title: 'Linie', hint: 'Von links nach rechts durchziehen.', strokes: [
          Fig.s(Shapes.line(20, 50, 80, 50)),
        ]),
        FigureStep(title: 'Spitzen', hint: 'Rechts das V nach rechts, links das V nach links.', strokes: [
          Fig.s(Fig.head(84, 50, 1, 0, len: 13, half: 9)),
          Fig.s(Fig.head(16, 50, -1, 0, len: 13, half: 9)),
        ]),
      ],
    ),
    Figure(
      id: 'arrows.chain',
      name: 'Prozesskette',
      meaning: 'Schritte nacheinander, Ablauf, Agenda',
      mnemonic: 'Kreise zuerst, dann kurze Pfeile dazwischen. Alle Kreise gleich groß, alle Pfeile gleich lang.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Drei Kreise', hint: 'Auf einer Linie mit gleichem Abstand.', strokes: [
          Fig.s(Shapes.circle(20, 50, 9)),
          Fig.s(Shapes.circle(50, 50, 9)),
          Fig.s(Shapes.circle(80, 50, 9)),
        ]),
        FigureStep(title: 'Pfeile', hint: 'Kurze Striche von Kreis zu Kreis, jeweils mit kleinem V.', strokes: [
          Fig.s(Shapes.line(31, 50, 38, 50)),
          Fig.s(Fig.head(40, 50, 1, 0, len: 5, half: 4)),
          Fig.s(Shapes.line(61, 50, 68, 50)),
          Fig.s(Fig.head(70, 50, 1, 0, len: 5, half: 4)),
        ]),
        FigureStep(title: 'Farbakzent', hint: 'Der aktuelle Schritt bekommt einen roten Punkt. Farbe sparsam einsetzen: eine Stelle, nicht drei.', strokes: [
          Fig.dot(50, 50, r: 3.5, color: MarkerColor.red),
        ]),
        FigureStep(title: 'Schatten', hint: 'Jeder Kreis bekommt einen kleinen grauen Bogen rechts unten.', strokes: [
          Fig.circleShadow(20, 50, 9, gap: 2.5, startDeg: 10, sweepDeg: 80),
          Fig.circleShadow(50, 50, 9, gap: 2.5, startDeg: 10, sweepDeg: 80),
          Fig.circleShadow(80, 50, 9, gap: 2.5, startDeg: 10, sweepDeg: 80),
        ]),
      ],
    ),
  ],
);
