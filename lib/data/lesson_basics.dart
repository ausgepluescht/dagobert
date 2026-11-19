import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonBasics = Lesson(
  id: 'basics',
  title: 'Grundformen',
  subtitle: 'Linie, Kreis, Quadrat, Dreieck und der erste Schatten',
  intro: 'Fast jede Flipchart-Figur besteht aus vier Grundformen. Wer die sauber hinbekommt, '
      'kann alles zeichnen. Dazu kommt der wichtigste Trick überhaupt: Licht kommt von oben links, '
      'der graue Schatten liegt rechts und unten.',
  figures: [
    Figure(
      id: 'basics.line',
      name: 'Gerade Linie',
      meaning: 'Rahmen, Verbindungen, Unterstreichungen',
      mnemonic: 'Aus der Schulter ziehen, nicht aus dem Handgelenk. Erst das Ziel anschauen, dann losziehen.',
      steps: [
        FigureStep(title: 'Waagerecht', hint: 'Von links nach rechts in einem Zug durchziehen, ohne abzusetzen.', strokes: [
          Fig.s(Shapes.line(14, 38, 86, 38)),
        ]),
        FigureStep(title: 'Senkrecht', hint: 'Von oben nach unten. Das Tempo gleichmäßig halten.', strokes: [
          Fig.s(Shapes.line(50, 50, 50, 88)),
        ]),
        FigureStep(title: 'Schräg', hint: 'Zwei Diagonalen. Ruhig zügig: Langsame Linien zittern.', strokes: [
          Fig.s(Shapes.line(16, 88, 40, 52)),
          Fig.s(Shapes.line(84, 88, 60, 52)),
        ]),
      ],
    ),
    Figure(
      id: 'basics.circle',
      name: 'Kreis',
      meaning: 'Köpfe, Zifferblätter, Zielscheiben, Punkte',
      mnemonic: 'Erst zweimal in der Luft kreisen, dann absetzen und in einem Schwung durchziehen.',
      steps: [
        FigureStep(title: 'Großer Kreis', hint: 'Oben starten, im Uhrzeigersinn, wieder oben ankommen. Muss nicht perfekt sein.', strokes: [
          Fig.s(Shapes.circle(50, 46, 28)),
        ]),
        FigureStep(title: 'Kleine Kreise', hint: 'Zwei kleine Kreise aus dem Handgelenk. Kleine Kreise sind die Köpfe deiner Figuren.', strokes: [
          Fig.s(Shapes.circle(30, 86, 7)),
          Fig.s(Shapes.circle(70, 86, 7)),
        ]),
      ],
    ),
    Figure(
      id: 'basics.square',
      name: 'Quadrat mit Schatten',
      meaning: 'Container, Kästen, Bausteine',
      mnemonic: 'Licht von oben links: Der Schatten liegt immer rechts und unten, mit einem kleinen Abstand zur Form.',
      steps: [
        FigureStep(title: 'Quadrat', hint: 'Vier Linien, Ecke an Ecke. Gern an den Ecken minimal überziehen, das wirkt handgezeichnet.', strokes: [
          Fig.s(Shapes.rect(26, 24, 48, 48)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Marker: ein Strich rechts, einer unten, jeweils ein wenig versetzt. Oben links bleibt frei.', strokes: Fig.boxShadow(26, 24, 48, 48)),
      ],
    ),
    Figure(
      id: 'basics.triangle',
      name: 'Dreieck',
      meaning: 'Pfeilspitzen, Dächer, Berge, Warnhinweise',
      mnemonic: 'Spitze zuerst setzen, dann beide Schenkel nach unten ziehen, Boden zum Schluss.',
      steps: [
        FigureStep(title: 'Schenkel', hint: 'Von der Spitze links runter, zurück zur Spitze, rechts runter.', strokes: [
          Fig.s(Shapes.poly([20, 76, 50, 22, 80, 76])),
        ]),
        FigureStep(title: 'Boden', hint: 'Die Grundlinie schließt das Dreieck.', strokes: [
          Fig.s(Shapes.line(20, 76, 80, 76)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Ein grauer Strich unter dem Boden, leicht nach rechts versetzt.', strokes: [
          Fig.grey(Shapes.line(26, 80, 84, 80), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'basics.wave',
      name: 'Welle und Bogen',
      meaning: 'Wolken, Wasser, Haare, Schwung in Pfeilen',
      mnemonic: 'Im Takt zählen: eins hoch, zwei runter. Gleich große Hügel entstehen durch gleichmäßiges Tempo.',
      steps: [
        FigureStep(title: 'Welle', hint: 'Von links nach rechts in einer Bewegung, drei Hügel.', strokes: [
          Fig.s(Shapes.wave(14, 86, 34, 7, 3)),
        ]),
        FigureStep(title: 'Bogen', hint: 'Ein weiter Bogen wie ein Regenbogen. Die Hand bewegt sich, nicht die Finger.', strokes: [
          Fig.s(Shapes.arc(50, 86, 32, 180, 180)),
        ]),
      ],
    ),
    Figure(
      id: 'basics.hatch',
      name: 'Schraffur',
      meaning: 'Flächen füllen, Schatten, Hervorhebungen',
      mnemonic: 'Alle Linien in dieselbe Richtung, gleicher Abstand, schräg nach rechts oben. Weniger ist mehr.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Rahmen', hint: 'Ein liegendes Rechteck als Fläche.', strokes: [
          Fig.s(Shapes.rect(22, 30, 56, 40)),
        ]),
        FigureStep(title: 'Schraffur', hint: 'Grau, dünn, schräg. Jede Linie beginnt und endet am Rand. Nicht zu eng setzen.', strokes: [
          for (final l in Shapes.hatch(22, 30, 56, 40, 9)) Fig.grey(l),
        ]),
      ],
    ),
  ],
);
