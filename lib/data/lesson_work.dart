import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonWork = Lesson(
  id: 'work',
  title: 'Symbole: Arbeit und Alltag',
  subtitle: 'Kaffeetasse, Laptop, Brief, Buch, Pokal, Herz',
  intro: 'Bilder aus dem Arbeitsalltag erkennt jeder sofort. Hier kommen Rechtecke, Trapeze und Bögen zusammen. '
      'Achte darauf, dass jede Figur auf dem Boden steht: Der Schatten verankert sie.',
  figures: [
    Figure(
      id: 'work.coffee',
      name: 'Kaffeetasse',
      meaning: 'Pause, Austausch, Energie',
      mnemonic: 'Ein Trapez, das nach unten schmaler wird, ein C als Henkel rechts, drei Wellen als Dampf.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Tasse', hint: 'Oben breit, unten schmaler. Die Oberkante gerade.', strokes: [
          Fig.s(Shapes.poly([30, 40, 70, 40, 65, 72, 35, 72], close: true)),
        ]),
        FigureStep(title: 'Henkel', hint: 'Ein C, das rechts an der Tasse hängt.', strokes: [
          Fig.s(Shapes.arc(71, 54, 9, -70, 140)),
        ]),
        FigureStep(title: 'Untertasse', hint: 'Eine flache Ellipse unter der Tasse.', strokes: [
          Fig.s(Shapes.join([Shapes.line(22, 74, 78, 74), Shapes.ellipse(50, 74, 28, 7, startDeg: 0, sweepDeg: 180)])),
        ]),
        FigureStep(title: 'Dampf', hint: 'Drei kleine S-Kurven über der Tasse, grau und dünn.', strokes: [
          Fig.grey(Shapes.cubic(40, 34, 35, 28, 45, 24, 40, 18)),
          Fig.grey(Shapes.cubic(50, 34, 45, 28, 55, 24, 50, 18)),
          Fig.grey(Shapes.cubic(60, 34, 55, 28, 65, 24, 60, 18)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Ein flacher grauer Bodenschatten unter der Untertasse, nach rechts versetzt.', strokes: [
          Fig.groundShadow(54, 86, 24),
        ]),
      ],
    ),
    Figure(
      id: 'work.laptop',
      name: 'Laptop',
      meaning: 'Digital, Homeoffice, Arbeit am Rechner',
      mnemonic: 'Ein Rechteck steht auf einem flachen Trapez. Die Tastatur ist eine einzige graue Linie.',
      steps: [
        FigureStep(title: 'Bildschirm', hint: 'Ein liegendes Rechteck mit leicht runden Ecken.', strokes: [
          Fig.s(Shapes.roundRect(28, 24, 44, 30, 2)),
        ]),
        FigureStep(title: 'Tastatur', hint: 'Ein flaches Trapez unter dem Bildschirm, nach vorn breiter.', strokes: [
          Fig.s(Shapes.poly([20, 54, 80, 54, 86, 64, 14, 64], close: true)),
          Fig.grey(Shapes.line(26, 59, 74, 59)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grauer Strich unter der Tastatur und am rechten Bildschirmrand.', strokes: [
          Fig.grey(Shapes.line(18, 68, 88, 68), width: MarkerWidth.thick),
          Fig.grey(Shapes.line(75, 30, 75, 52), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'work.mail',
      name: 'Brief',
      meaning: 'Nachricht, Kommunikation, Einladung',
      mnemonic: 'Rechteck plus ein V von den oberen Ecken zur Mitte. Das V ist die Lasche.',
      steps: [
        FigureStep(title: 'Umschlag', hint: 'Ein liegendes Rechteck.', strokes: [
          Fig.s(Shapes.rect(22, 32, 56, 38)),
        ]),
        FigureStep(title: 'Lasche', hint: 'Von der linken oberen Ecke zur Mitte und hoch zur rechten oberen Ecke.', strokes: [
          Fig.s(Shapes.poly([22, 32, 50, 56, 78, 32])),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau rechts und unten.', strokes: Fig.boxShadow(22, 32, 56, 38)),
      ],
    ),
    Figure(
      id: 'work.book',
      name: 'Buch',
      meaning: 'Wissen, Lernen, Regeln, Dokumentation',
      mnemonic: 'Zwei Seiten, die sich in der Mitte treffen und außen leicht hochgehen. Textzeilen folgen der Seitenneigung.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Linke Seite', hint: 'Von der Mitte aus: nach links oben, runter, zurück zur Mitte unten.', strokes: [
          Fig.s(Shapes.poly([50, 34, 20, 28, 20, 68, 50, 74], close: true)),
        ]),
        FigureStep(title: 'Rechte Seite', hint: 'Spiegelgleich nach rechts.', strokes: [
          Fig.s(Shapes.poly([50, 34, 80, 28, 80, 68, 50, 74], close: true)),
        ]),
        FigureStep(title: 'Text', hint: 'Je zwei dünne graue Linien pro Seite, leicht schräg wie die Seiten.', strokes: [
          Fig.grey(Shapes.line(26, 40, 44, 44)),
          Fig.grey(Shapes.line(26, 50, 44, 54)),
          Fig.grey(Shapes.line(56, 44, 74, 40)),
          Fig.grey(Shapes.line(56, 54, 74, 50)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau unter dem Buch, der Linie der Seiten folgend.', strokes: [
          Fig.grey(Shapes.poly([26, 72, 50, 78, 84, 71]), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'work.trophy',
      name: 'Pokal',
      meaning: 'Erfolg, Gewinn, Auszeichnung',
      mnemonic: 'Ein Becher, zwei Ohren, ein Stiel, ein Fuß. Von oben nach unten zeichnen.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Kelch', hint: 'Oben breit, nach unten rund zusammenlaufend.', strokes: [
          Fig.s(Shapes.poly([30, 20, 70, 20, 67, 44, 60, 54, 40, 54, 33, 44], close: true)),
        ]),
        FigureStep(title: 'Henkel', hint: 'Links und rechts je ein halber Kreis als Ohr.', strokes: [
          Fig.s(Shapes.arc(31, 32, 8, 90, 180)),
          Fig.s(Shapes.arc(69, 32, 8, -90, 180)),
        ]),
        FigureStep(title: 'Fuß', hint: 'Ein kurzer Stiel und ein flaches Trapez als Sockel.', strokes: [
          Fig.s(Shapes.line(50, 54, 50, 64)),
          Fig.s(Shapes.poly([38, 64, 62, 64, 68, 76, 32, 76], close: true)),
        ]),
        FigureStep(title: 'Akzent', hint: 'Ein kleiner roter Stern auf dem Kelch.', strokes: [
          Fig.red(Fig.star(50, 35, 7, 3)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Grau rechts am Kelch und unter dem Sockel.', strokes: [
          Fig.grey(Shapes.line(70, 26, 68, 44), width: MarkerWidth.thick),
          Fig.grey(Shapes.line(38, 80, 72, 80), width: MarkerWidth.thick),
        ]),
      ],
    ),
    Figure(
      id: 'work.heart',
      name: 'Herz',
      meaning: 'Werte, Leidenschaft, Kundenliebe',
      mnemonic: 'Zwei Bögen, die oben in der Mitte einen Knick machen und unten in einer Spitze zusammenkommen.',
      steps: [
        FigureStep(title: 'Linke Hälfte', hint: 'Unten an der Spitze starten, links hoch schwingen und oben in der Mitte landen.', strokes: [
          Fig.red(Shapes.cubic(50, 82, 8, 56, 16, 18, 50, 34), width: MarkerWidth.thick),
        ]),
        FigureStep(title: 'Rechte Hälfte', hint: 'Oben in der Mitte starten, rechts herum zurück zur Spitze.', strokes: [
          Fig.red(Shapes.cubic(50, 34, 84, 18, 92, 56, 50, 82), width: MarkerWidth.thick),
        ]),
        FigureStep(title: 'Schatten', hint: 'Ein grauer Bogen rechts unten, außen am Herz entlang.', strokes: [
          Fig.grey(Shapes.cubic(82, 54, 84, 62, 72, 74, 56, 86), width: MarkerWidth.thick),
        ]),
      ],
    ),
  ],
);
