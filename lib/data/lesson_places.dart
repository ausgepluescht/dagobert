import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonPlaces = Lesson(
  id: 'places',
  title: 'Symbole: Ziele und Aufbruch',
  subtitle: 'Berg mit Fahne, Haus, Baum, Rakete, Stern, Frage und Ausruf',
  intro: 'Zum Schluss Bilder, die Geschichten erzählen: Wo stehen wir, wohin wollen wir, was ist offen? '
      'Hier kommt alles zusammen: Grundformen, Container, Schatten und ein Farbakzent.',
  figures: [
    Figure(
      id: 'places.mountain',
      name: 'Berg mit Fahne',
      meaning: 'Ziel, Herausforderung, Meilenstein',
      mnemonic: 'Ein großer und ein kleiner Zacken, die Fahne steckt auf dem höheren. Schraffur auf der Schattenseite rechts.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Berg', hint: 'Von links unten hoch zum Gipfel, ein kleines Tal, ein zweiter Gipfel, rechts runter.', strokes: [
          Fig.s(Shapes.poly([8, 82, 40, 28, 54, 50, 66, 36, 92, 82])),
        ]),
        FigureStep(title: 'Mast', hint: 'Ein senkrechter Strich auf dem höheren Gipfel.', strokes: [
          Fig.s(Shapes.line(40, 28, 40, 10)),
        ]),
        FigureStep(title: 'Fahne', hint: 'Ein rotes Dreieck, das vom Mast nach rechts weht.', strokes: [
          Fig.red(Shapes.poly([40, 10, 56, 15, 40, 20], close: true), fill: true),
        ]),
        FigureStep(title: 'Schraffur', hint: 'Dünne graue Linien auf der rechten Bergseite, parallel zur Flanke.', strokes: [
          Fig.grey(Shapes.line(70, 50, 62, 60)),
          Fig.grey(Shapes.line(76, 60, 66, 72)),
          Fig.grey(Shapes.line(82, 70, 74, 80)),
        ]),
        FigureStep(title: 'Boden', hint: 'Eine Grundlinie mit grauem Schatten darunter.', strokes: [
          Fig.s(Shapes.line(8, 82, 92, 82)),
          Fig.grey(Shapes.line(14, 86, 94, 86), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'places.house',
      name: 'Haus',
      meaning: 'Zuhause, Standort, Basis, Unternehmen',
      mnemonic: 'Quadrat, Dreieck drauf, Tür in die Mitte. Das Dach steht links und rechts etwas über.',
      steps: [
        FigureStep(title: 'Wand', hint: 'Ein Quadrat in der unteren Hälfte.', strokes: [
          Fig.s(Shapes.rect(28, 50, 44, 34)),
        ]),
        FigureStep(title: 'Dach', hint: 'Ein Dreieck, das über die Wände hinausragt.', strokes: [
          Fig.s(Shapes.poly([22, 52, 50, 22, 78, 52])),
        ]),
        FigureStep(title: 'Tür und Fenster', hint: 'Ein hochkant Rechteck als Tür, ein kleines Quadrat als Fenster.', strokes: [
          Fig.s(Shapes.poly([44, 84, 44, 66, 56, 66, 56, 84])),
          Fig.s(Shapes.rect(32, 57, 9, 8)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau rechts an der Wand und unter dem Haus.', strokes: Fig.boxShadow(28, 50, 44, 34)),
      ],
    ),
    Figure(
      id: 'places.tree',
      name: 'Baum',
      meaning: 'Wachstum, Natur, Nachhaltigkeit, Wurzeln',
      mnemonic: 'Zwei Striche als Stamm, darüber eine Wolke als Krone. Der Stamm geht in die Krone hinein.',
      steps: [
        FigureStep(title: 'Stamm', hint: 'Zwei senkrechte Linien, unten leicht auseinander.', strokes: [
          Fig.s(Shapes.line(46, 58, 44, 88)),
          Fig.s(Shapes.line(54, 58, 56, 88)),
        ]),
        FigureStep(title: 'Krone', hint: 'Eine große Wolke aus Bögen, die unten auf dem Stamm sitzt.', strokes: [
          Fig.s(Fig.cloud(50, 38, 26, 22, bumps: 5, depth: 0.13)),
        ]),
        FigureStep(title: 'Farbe', hint: 'Ein grüner Bogen innen an der Krone, als Andeutung von Laub. Nicht ausmalen.', strokes: [
          Fig.green(Shapes.arc(50, 40, 16, 150, 160), width: MarkerWidth.thick),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten an der Krone und ein Bodenschatten.', strokes: [
          Fig.circleShadow(50, 40, 27, gap: 3, startDeg: 10, sweepDeg: 60),
          Fig.groundShadow(52, 90, 18),
        ]),
      ],
    ),
    Figure(
      id: 'places.rocket',
      name: 'Rakete',
      meaning: 'Start, Projektbeginn, Wachstum, Vision',
      mnemonic: 'Ein spitzes Oval, zwei Flossen, ein rundes Fenster, rote Flamme. Alles senkrecht aufbauen.',
      difficulty: 3,
      steps: [
        FigureStep(title: 'Körper', hint: 'Von der Spitze oben links herum nach unten, Boden gerade, rechts wieder hoch zur Spitze.', strokes: [
          Fig.s(Shapes.join([
            Shapes.cubic(50, 10, 34, 28, 34, 56, 38, 70),
            Shapes.line(38, 70, 62, 70),
            Shapes.cubic(62, 70, 66, 56, 66, 28, 50, 10),
          ])),
        ]),
        FigureStep(title: 'Fenster', hint: 'Ein Kreis im oberen Drittel.', strokes: [
          Fig.s(Shapes.circle(50, 38, 6)),
        ]),
        FigureStep(title: 'Flossen', hint: 'Links und rechts je ein Dreieck, das nach unten außen zeigt.', strokes: [
          Fig.s(Shapes.poly([37, 56, 26, 76, 38, 70])),
          Fig.s(Shapes.poly([63, 56, 74, 76, 62, 70])),
        ]),
        FigureStep(title: 'Flamme', hint: 'Ein rotes Zickzack-Dreieck unter dem Boden.', strokes: [
          Fig.red(Shapes.poly([42, 72, 46, 80, 50, 90, 54, 80, 58, 72])),
        ]),
        FigureStep(title: 'Schatten', hint: 'Ein grauer Bogen entlang der rechten Körperseite.', strokes: [
          Fig.grey(Shapes.cubic(60, 24, 64, 40, 64, 56, 61, 66), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'places.star',
      name: 'Stern',
      meaning: 'Highlight, Bewertung, Favorit',
      mnemonic: 'In einem Zug: hoch zur Spitze, runter rechts, nach links quer, hoch rechts, runter links, zurück. Nie absetzen.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Stern', hint: 'Fünf Zacken in einem Zug, die Zacken gleich lang.', strokes: [
          Fig.s(Fig.star(50, 50, 32, 14)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau rechts unten entlang der zwei unteren Zacken.', strokes: [
          Fig.grey(Shapes.poly([72, 54, 76, 78, 54, 68]), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'places.question',
      name: 'Frage und Ausruf',
      meaning: 'Offene Punkte, Wichtiges, Achtung',
      mnemonic: 'Das Fragezeichen ist ein Haken mit Punkt, das Ausrufezeichen ein dicker Strich mit Punkt. Der Ausruf ist rot.',
      steps: [
        FigureStep(title: 'Bogen', hint: 'Von links oben einen Halbkreis nach rechts herum bis zur Mitte unten.', strokes: [
          Fig.s(Shapes.arc(34, 32, 14, 180, 270), width: MarkerWidth.thick),
        ]),
        FigureStep(title: 'Strich und Punkt', hint: 'Vom Bogenende ein kurzer Strich nach unten, dann mit Abstand ein Punkt.', strokes: [
          Fig.s(Shapes.line(34, 46, 34, 60), width: MarkerWidth.thick),
          Fig.dot(34, 74, r: 3),
        ]),
        FigureStep(title: 'Ausrufezeichen', hint: 'Rot: ein dicker Strich von oben bis zur Höhe des Fragezeichen-Strichs, darunter ein Punkt.', strokes: [
          Fig.red(Shapes.line(68, 18, 68, 60), width: MarkerWidth.thick),
          Fig.dot(68, 74, r: 3, color: MarkerColor.red),
        ]),
        FigureStep(title: 'Schatten', hint: 'Je ein kurzer grauer Strich rechts an beiden Zeichen.', strokes: [
          Fig.grey(Shapes.line(38, 48, 38, 60), width: MarkerWidth.thick),
          Fig.grey(Shapes.line(72, 24, 72, 60), width: MarkerWidth.thick),
        ]),
      ],
    ),
  ],
);
