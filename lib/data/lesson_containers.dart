import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonContainers = Lesson(
  id: 'containers',
  title: 'Container und Rahmen',
  subtitle: 'Kästen, Banner, Sprech- und Gedankenblasen, Zettel, Schilder',
  intro: 'Container fassen Inhalte zusammen und geben dem Flipchart Struktur. Erst der Text, dann der '
      'Rahmen drumherum, zuletzt der graue Schatten. So passt der Rahmen immer zum Inhalt.',
  figures: [
    Figure(
      id: 'containers.frame',
      name: 'Rahmen mit Schatten',
      meaning: 'Überschriften, Kernaussagen, Zusammenfassungen',
      mnemonic: 'Ecken leicht abrunden, dann wirkt der Kasten freundlich. Schatten rechts und unten.',
      steps: [
        FigureStep(title: 'Rahmen', hint: 'Abgerundetes Rechteck in einem Zug. Starte an einer Kante, nicht an einer Ecke.', strokes: [
          Fig.s(Shapes.roundRect(14, 26, 72, 48, 7)),
        ]),
        FigureStep(title: 'Textzeilen', hint: 'Zwei dünne graue Linien stehen für den Text. Die Platzhalter helfen beim Üben der Proportionen.', strokes: [
          Fig.grey(Shapes.line(26, 44, 74, 44)),
          Fig.grey(Shapes.line(26, 56, 62, 56)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau, dick, mit Abstand: rechts und unten entlang.', strokes: Fig.boxShadow(14, 26, 72, 48)),
      ],
    ),
    Figure(
      id: 'containers.banner',
      name: 'Banner',
      meaning: 'Titel, Mottos, Schlagworte',
      mnemonic: 'Erst die Box, dann die Flügel. Die Flügel bekommen einen Knick wie ein Schwalbenschwanz.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Box', hint: 'Ein liegendes Rechteck in der Mitte.', strokes: [
          Fig.s(Shapes.rect(28, 36, 44, 24)),
        ]),
        FigureStep(title: 'Flügel', hint: 'Links und rechts je ein Band mit eingekerbtem Ende. Die Bänder setzen unterhalb der Oberkante an und reichen etwas unter die Box.', strokes: [
          Fig.s(Shapes.poly([28, 46, 12, 46, 17, 56, 12, 66, 28, 66])),
          Fig.s(Shapes.poly([72, 46, 88, 46, 83, 56, 88, 66, 72, 66])),
        ]),
        FigureStep(title: 'Falten', hint: 'Unter der Box je ein kleines Dreieck zum Band hin: So läuft das Band sichtbar hinten herum.', strokes: [
          Fig.s(Shapes.poly([28, 66, 34, 66, 28, 60])),
          Fig.s(Shapes.poly([72, 66, 66, 66, 72, 60])),
        ]),
        FigureStep(title: 'Schatten', hint: 'Ein grauer Strich unter der Box.', strokes: [
          Fig.grey(Shapes.line(38, 70, 70, 70), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'containers.speech',
      name: 'Sprechblase',
      meaning: 'Zitate, Aussagen, Stimmen aus dem Team',
      mnemonic: 'Die Blase bleibt unten links offen, der Schnabel schließt sie. Die Spitze zeigt zum Sprecher.',
      steps: [
        FigureStep(title: 'Blase', hint: 'Ein Oval, das unten links eine Lücke lässt.', strokes: [
          Fig.s(Shapes.ellipse(50, 42, 34, 22, startDeg: 135, sweepDeg: 330)),
        ]),
        FigureStep(title: 'Schnabel', hint: 'Von der Lücke aus zur Spitze unten links und wieder zurück zur Blase.', strokes: [
          Fig.s(Shapes.poly([41.2, 63.3, 26, 78, 26, 57.6])),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten.', strokes: [
          Fig.circleShadow(50, 42, 34, startDeg: -10, sweepDeg: 80).copyWith(width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'containers.thought',
      name: 'Gedankenblase',
      meaning: 'Ideen, Wünsche, unausgesprochene Gedanken',
      mnemonic: 'Eine Wolke plus zwei kleine Kreise, die zum Denker hin kleiner werden.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Wolke', hint: 'Ein Oval aus lauter kleinen Bögen. Nicht absetzen, einfach Bogen an Bogen.', strokes: [
          Fig.s(Fig.cloud(50, 40, 30, 20, bumps: 5, depth: 0.14)),
        ]),
        FigureStep(title: 'Blasen', hint: 'Zwei kleine Kreise unten links, der untere kleiner als der obere.', strokes: [
          Fig.s(Shapes.circle(32, 72, 4.5)),
          Fig.s(Shapes.circle(24, 82, 2.5)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Bogen rechts unten an der Wolke.', strokes: [
          Fig.circleShadow(50, 42, 33, startDeg: 0, sweepDeg: 70),
        ]),
      ],
    ),
    Figure(
      id: 'containers.note',
      name: 'Zettel',
      meaning: 'Notizen, Aufgaben, Dokumente',
      mnemonic: 'Ein Rechteck, dem unten rechts die Ecke fehlt. Die fehlende Ecke klappt sich als kleines Dreieck um.',
      steps: [
        FigureStep(title: 'Blatt', hint: 'Hochkant-Rechteck, aber die untere rechte Ecke schräg abschneiden.', strokes: [
          Fig.s(Shapes.poly([28, 20, 72, 20, 72, 60, 60, 72, 28, 72], close: true)),
        ]),
        FigureStep(title: 'Eselsohr', hint: 'Von der Schrägen ein kleines Dreieck nach innen.', strokes: [
          Fig.s(Shapes.poly([72, 60, 61, 61, 60, 72])),
        ]),
        FigureStep(title: 'Textzeilen', hint: 'Drei dünne graue Linien, die letzte kürzer.', strokes: [
          Fig.grey(Shapes.line(36, 34, 64, 34)),
          Fig.grey(Shapes.line(36, 44, 64, 44)),
          Fig.grey(Shapes.line(36, 54, 54, 54)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Rechts und unten, grau, mit Abstand.', strokes: [
          Fig.grey(Shapes.line(75, 28, 75, 60), width: MarkerWidth.thick),
          Fig.grey(Shapes.line(34, 75, 60, 75), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'containers.sign',
      name: 'Wegweiser',
      meaning: 'Richtung, Ziel, nächster Schritt',
      mnemonic: 'Ein Rechteck, dessen rechte Seite zu einer Spitze wird. Der Pfahl steht mittig darunter.',
      steps: [
        FigureStep(title: 'Schild', hint: 'Links gerade, rechts eine Spitze wie ein Pfeil.', strokes: [
          Fig.s(Shapes.poly([20, 30, 70, 30, 82, 42, 70, 54, 20, 54], close: true)),
        ]),
        FigureStep(title: 'Pfahl', hint: 'Ein senkrechter Strich vom Schild bis zum Boden.', strokes: [
          Fig.s(Shapes.line(48, 54, 48, 86)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau unter dem Schild und ein flacher Bodenschatten.', strokes: [
          Fig.grey(Shapes.line(26, 58, 74, 58), width: MarkerWidth.thick),
          Fig.groundShadow(52, 88, 14),
        ]),
      ],
    ),
  ],
);
