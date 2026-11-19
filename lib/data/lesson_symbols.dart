import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonSymbols = Lesson(
  id: 'symbols',
  title: 'Symbole: Die Klassiker',
  subtitle: 'Glühbirne, Zielscheibe, Uhr, Zahnrad, Lupe, Haken',
  intro: 'Diese sechs Symbole kommen auf fast jedem Flipchart vor. Jedes besteht aus Grundformen, die du schon '
      'kannst. Schatten rechts unten, Farbe nur als einzelner Akzent.',
  figures: [
    Figure(
      id: 'symbols.bulb',
      name: 'Glühbirne',
      meaning: 'Idee, Einfall, Inspiration',
      mnemonic: 'Ein Kreis, der unten nicht zugeht, sondern in einen Hals mit Gewinde läuft. Strahlen drumherum.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Birne', hint: 'Fast ein Kreis: unten links starten, über oben herum, unten rechts aufhören.', strokes: [
          Fig.s(Shapes.arc(50, 40, 22, 135, 270)),
        ]),
        FigureStep(title: 'Hals', hint: 'Von beiden Enden zwei kurze Linien schräg nach innen unten.', strokes: [
          Fig.s(Shapes.line(34.4, 55.6, 40, 68)),
          Fig.s(Shapes.line(65.6, 55.6, 60, 68)),
        ]),
        FigureStep(title: 'Gewinde', hint: 'Drei waagerechte Striche, nach unten kürzer, und ein kurzer Fuß.', strokes: [
          Fig.s(Shapes.line(40, 68, 60, 68)),
          Fig.s(Shapes.line(41, 73, 59, 73)),
          Fig.s(Shapes.line(43, 78, 57, 78)),
          Fig.s(Shapes.line(46, 83, 54, 83)),
        ]),
        FigureStep(title: 'Glühfaden', hint: 'Ein kleiner Zickzack in der Birne.', strokes: [
          Fig.s(Shapes.poly([44, 54, 47, 46, 50, 54, 53, 46, 56, 54]), width: MarkerWidth.thin),
        ]),
        FigureStep(title: 'Strahlen', hint: 'Kurze Striche rund um die Birne, mit Abstand. Vier oder fünf reichen.', strokes: [
          Fig.s(Shapes.line(50, 6, 50, 12)),
          Fig.s(Shapes.line(28, 14, 32, 19)),
          Fig.s(Shapes.line(72, 14, 68, 19)),
          Fig.s(Shapes.line(18, 40, 24, 40)),
          Fig.s(Shapes.line(82, 40, 76, 40)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen an der rechten unteren Seite der Birne.', strokes: [
          Fig.circleShadow(50, 40, 22, startDeg: -10, sweepDeg: 60),
        ]),
      ],
    ),
    Figure(
      id: 'symbols.target',
      name: 'Zielscheibe',
      meaning: 'Ziel, Fokus, Treffer',
      mnemonic: 'Drei Kreise ineinander, der innerste rot ausgemalt. Der Pfeil kommt von oben rechts und steckt in der Mitte.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Ringe', hint: 'Drei Kreise um denselben Mittelpunkt, der Abstand bleibt gleich.', strokes: [
          Fig.s(Shapes.circle(48, 54, 30)),
          Fig.s(Shapes.circle(48, 54, 19)),
          Fig.s(Shapes.circle(48, 54, 8)),
        ]),
        FigureStep(title: 'Mitte', hint: 'Den innersten Kreis rot ausmalen.', strokes: [
          Fig.red(Shapes.circle(48, 54, 7), fill: true),
        ]),
        FigureStep(title: 'Pfeil', hint: 'Ein Strich von oben rechts bis kurz vor die Mitte, hinten zwei Federn.', strokes: [
          Fig.s(Shapes.line(86, 14, 53, 49)),
          Fig.s(Shapes.poly([84, 6, 86, 14, 94, 16])),
          Fig.s(Shapes.poly([78, 10, 80, 20, 90, 22])),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten am äußeren Ring.', strokes: [
          Fig.circleShadow(48, 54, 30, startDeg: 10, sweepDeg: 80),
        ]),
      ],
    ),
    Figure(
      id: 'symbols.clock',
      name: 'Uhr',
      meaning: 'Zeit, Termin, Dauer, Pause',
      mnemonic: 'Kreis, vier Markierungen bei 12, 3, 6 und 9, dann zwei Zeiger aus der Mitte: einer kurz, einer lang.',
      steps: [
        FigureStep(title: 'Zifferblatt', hint: 'Ein großer Kreis.', strokes: [
          Fig.s(Shapes.circle(50, 50, 30)),
        ]),
        FigureStep(title: 'Markierungen', hint: 'Vier kurze Striche innen am Rand: oben, rechts, unten, links.', strokes: [
          Fig.s(Shapes.line(50, 22, 50, 27)),
          Fig.s(Shapes.line(78, 50, 73, 50)),
          Fig.s(Shapes.line(50, 78, 50, 73)),
          Fig.s(Shapes.line(22, 50, 27, 50)),
        ]),
        FigureStep(title: 'Zeiger', hint: 'Vom Mittelpunkt: kurzer Zeiger nach oben, langer nach rechts unten. Punkt in die Mitte.', strokes: [
          Fig.s(Shapes.line(50, 50, 50, 34)),
          Fig.s(Shapes.line(50, 50, 65, 59)),
          Fig.dot(50, 50, r: 2),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten.', strokes: [
          Fig.circleShadow(50, 50, 30, startDeg: 10, sweepDeg: 80),
        ]),
      ],
    ),
    Figure(
      id: 'symbols.gear',
      name: 'Zahnrad',
      meaning: 'Prozess, Technik, Zusammenspiel',
      mnemonic: 'Ein Kreis mit Zacken: rein, raus, rein, raus. Acht Zähne reichen. In die Mitte ein kleines Loch.',
      difficulty: 3,
      steps: [
        FigureStep(title: 'Zahnkranz', hint: 'Oben starten, im Uhrzeigersinn: Zahn hoch, Zahn runter, immer gleich breit.', strokes: [
          Fig.s(Fig.gear(50, 50, 30, 23)),
        ]),
        FigureStep(title: 'Loch', hint: 'Ein kleiner Kreis in der Mitte.', strokes: [
          Fig.s(Shapes.circle(50, 50, 9)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten, außen entlang der Zähne.', strokes: [
          Fig.circleShadow(50, 50, 31, gap: 3.5, startDeg: 15, sweepDeg: 70),
        ]),
      ],
    ),
    Figure(
      id: 'symbols.magnifier',
      name: 'Lupe',
      meaning: 'Analyse, Suche, Details, Fokus',
      mnemonic: 'Kreis plus dicker Griff nach rechts unten. Der Griff zeigt immer in die Schatten-Ecke.',
      steps: [
        FigureStep(title: 'Glas', hint: 'Ein Kreis links oben.', strokes: [
          Fig.s(Shapes.circle(42, 42, 20)),
        ]),
        FigureStep(title: 'Griff', hint: 'Ein dicker Strich vom Kreisrand schräg nach rechts unten.', strokes: [
          Fig.s(Shapes.line(57, 57, 80, 80), width: MarkerWidth.thick),
        ]),
        FigureStep(title: 'Glanz', hint: 'Ein dünner grauer Bogen innen links oben, da wo das Licht herkommt.', strokes: [
          Fig.grey(Shapes.arc(42, 42, 14, 195, 50)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten am Glas, kurz vor dem Griff.', strokes: [
          Fig.circleShadow(42, 42, 20, startDeg: 60, sweepDeg: 60),
        ]),
      ],
    ),
    Figure(
      id: 'symbols.check',
      name: 'Haken',
      meaning: 'Erledigt, Zustimmung, Ergebnis',
      mnemonic: 'Kurz runter, lang hoch. Der Haken ist grün, der Kreis drumherum schwarz.',
      steps: [
        FigureStep(title: 'Kreis', hint: 'Ein großer Kreis.', strokes: [
          Fig.s(Shapes.circle(50, 50, 30)),
        ]),
        FigureStep(title: 'Haken', hint: 'Grün und dick: ein kurzer Strich nach rechts unten, dann ein langer nach rechts oben.', strokes: [
          Fig.green(Shapes.poly([34, 52, 45, 64, 68, 36]), width: MarkerWidth.thick),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten.', strokes: [
          Fig.circleShadow(50, 50, 30, startDeg: 10, sweepDeg: 80),
        ]),
      ],
    ),
  ],
);
