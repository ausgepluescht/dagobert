import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

final lessonPeople = Lesson(
  id: 'people',
  title: 'Figuren',
  subtitle: 'Vom Sternmännchen zur Flipchart-Figur mit Körper',
  intro: 'Menschen machen jedes Flipchart lebendig. Die Flipchart-Figur hat einen runden Kopf, einen '
      'Körper wie ein Kasten und kommt ganz ohne Hals, Hände und Gesicht aus. Arme und Beine sind einfache '
      'Striche. Haltung erzählt die Geschichte.',
  figures: [
    Figure(
      id: 'people.star',
      name: 'Sternmännchen',
      meaning: 'Schnelle Figur, wenn es nur um Personen geht',
      mnemonic: 'Kopf, Strich, Stern: Aus einem Punkt am Körper gehen vier Strahlen weg, zwei Arme oben, zwei Beine unten.',
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein kleiner Kreis oben in der Mitte.', strokes: [
          Fig.s(Shapes.circle(50, 22, 8)),
        ]),
        FigureStep(title: 'Körper', hint: 'Ein Strich senkrecht nach unten, mit etwas Abstand zum Kopf.', strokes: [
          Fig.s(Shapes.line(50, 32, 50, 60)),
        ]),
        FigureStep(title: 'Arme', hint: 'Von einem Punkt im oberen Drittel des Körpers schräg nach links und rechts unten.', strokes: [
          Fig.s(Shapes.line(50, 38, 30, 54)),
          Fig.s(Shapes.line(50, 38, 70, 54)),
        ]),
        FigureStep(title: 'Beine', hint: 'Vom unteren Ende des Körpers schräg auseinander.', strokes: [
          Fig.s(Shapes.line(50, 60, 36, 86)),
          Fig.s(Shapes.line(50, 60, 64, 86)),
        ]),
      ],
    ),
    Figure(
      id: 'people.figure',
      name: 'Flipchart-Figur',
      meaning: 'Die Standardperson für alles: Kunden, Team, Rollen',
      mnemonic: 'Kopf ohne Hals, Körper wie ein Kasten, der nach unten breiter wird. Kein Gesicht, keine Hände: Haltung reicht.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein Kreis. Lass darunter eine kleine Lücke, dort kommt kein Hals hin.', strokes: [
          Fig.s(Shapes.circle(50, 19, 9)),
        ]),
        FigureStep(title: 'Körper', hint: 'Ein Kasten, oben schmaler als unten. Schultern etwa so breit wie zwei Köpfe.', strokes: [
          Fig.s(Shapes.poly([38, 33, 62, 33, 66, 68, 34, 68], close: true)),
        ]),
        FigureStep(title: 'Arme', hint: 'Zwei Striche von den Schultern schräg nach außen unten.', strokes: [
          Fig.s(Shapes.line(39, 37, 24, 60)),
          Fig.s(Shapes.line(61, 37, 76, 60)),
        ]),
        FigureStep(title: 'Beine', hint: 'Zwei kurze Striche nach unten, leicht auseinander.', strokes: [
          Fig.s(Shapes.line(42, 68, 40, 90)),
          Fig.s(Shapes.line(58, 68, 60, 90)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Eine flache graue Ellipse unter den Füßen. Die Figur steht damit auf dem Boden.', strokes: [
          Fig.groundShadow(52, 92, 20),
        ]),
      ],
    ),
    Figure(
      id: 'people.talking',
      name: 'Figur mit Sprechblase',
      meaning: 'Zitate, Kundenstimmen, Fragen aus dem Raum',
      mnemonic: 'Ein Arm geht hoch Richtung Blase, der Schnabel der Blase zeigt zum Kopf.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Kopf und Körper', hint: 'Kleine Figur links: Kreis, darunter der Kasten.', strokes: [
          Fig.s(Shapes.circle(30, 40, 7)),
          Fig.s(Shapes.poly([21, 51, 39, 51, 42, 80, 18, 80], close: true)),
        ]),
        FigureStep(title: 'Arme und Beine', hint: 'Der rechte Arm zeigt nach oben zur Blase, der linke hängt. Beine kurz.', strokes: [
          Fig.s(Shapes.line(22, 54, 12, 70)),
          Fig.s(Shapes.line(38, 54, 50, 44)),
          Fig.s(Shapes.line(24, 80, 23, 94)),
          Fig.s(Shapes.line(36, 80, 37, 94)),
        ]),
        FigureStep(title: 'Blase', hint: 'Ein Oval rechts oben, links eine Lücke lassen.', strokes: [
          Fig.s(Shapes.ellipse(68, 28, 22, 14, startDeg: 180, sweepDeg: 330)),
        ]),
        FigureStep(title: 'Schnabel', hint: 'Von der Lücke zur Spitze Richtung Kopf und zurück.', strokes: [
          Fig.s(Shapes.poly([49, 35, 44, 42, 46, 28])),
        ]),
        FigureStep(title: 'Schatten', hint: 'Bodenschatten unter der Figur.', strokes: [
          Fig.groundShadow(32, 96, 16),
        ]),
      ],
    ),
    Figure(
      id: 'people.group',
      name: 'Gruppe',
      meaning: 'Team, Zielgruppe, Abteilung',
      mnemonic: 'Die vordere Figur zuerst und ganz. Die hinteren stehen etwas höher und zeigen nur, was nicht verdeckt ist.',
      difficulty: 3,
      steps: [
        FigureStep(title: 'Vordere Figur', hint: 'Kopf und Körper in der Mitte, etwas größer als die anderen.', strokes: [
          Fig.s(Shapes.circle(50, 30, 8)),
          Fig.s(Shapes.poly([41, 42, 59, 42, 62, 76, 38, 76], close: true)),
        ]),
        FigureStep(title: 'Linke Figur', hint: 'Kopf etwas höher und kleiner, Körper endet vor dem vorderen Körper.', strokes: [
          Fig.s(Shapes.circle(28, 36, 7)),
          Fig.s(Shapes.poly([20, 46, 36, 46, 37, 72, 19, 72], close: true)),
        ]),
        FigureStep(title: 'Rechte Figur', hint: 'Spiegelgleich zur linken.', strokes: [
          Fig.s(Shapes.circle(72, 36, 7)),
          Fig.s(Shapes.poly([64, 46, 80, 46, 81, 72, 63, 72], close: true)),
        ]),
        FigureStep(title: 'Beine', hint: 'Je zwei kurze Striche unter jedem Körper.', strokes: [
          Fig.s(Shapes.line(44, 76, 43, 90)),
          Fig.s(Shapes.line(56, 76, 57, 90)),
          Fig.s(Shapes.line(24, 72, 24, 84)),
          Fig.s(Shapes.line(33, 72, 33, 84)),
          Fig.s(Shapes.line(67, 72, 67, 84)),
          Fig.s(Shapes.line(76, 72, 76, 84)),
        ]),
        FigureStep(title: 'Schatten', hint: 'Ein gemeinsamer Bodenschatten für die ganze Gruppe.', strokes: [
          Fig.groundShadow(52, 92, 34),
        ]),
      ],
    ),
    Figure(
      id: 'people.presenter',
      name: 'Figur am Flipchart',
      meaning: 'Moderation, Präsentation, Training',
      mnemonic: 'Erst das Flipchart als Kasten mit drei Beinen, dann die Figur daneben. Der Arm zeigt auf das Blatt.',
      difficulty: 3,
      steps: [
        FigureStep(title: 'Flipchart', hint: 'Ein hochkant Rechteck rechts, darunter drei Beine: zwei schräg, eins gerade.', strokes: [
          Fig.s(Shapes.rect(56, 16, 32, 46)),
          Fig.s(Shapes.line(60, 62, 56, 88)),
          Fig.s(Shapes.line(84, 62, 88, 88)),
          Fig.s(Shapes.line(72, 62, 72, 88)),
        ]),
        FigureStep(title: 'Kopf und Körper', hint: 'Figur links vom Flipchart, Kopf auf Höhe der Blattmitte.', strokes: [
          Fig.s(Shapes.circle(28, 36, 7)),
          Fig.s(Shapes.poly([20, 47, 36, 47, 38, 76, 18, 76], close: true)),
        ]),
        FigureStep(title: 'Arme', hint: 'Der rechte Arm zeigt zum Blatt, der linke hängt locker.', strokes: [
          Fig.s(Shapes.line(36, 50, 54, 38)),
          Fig.s(Shapes.line(21, 50, 14, 68)),
        ]),
        FigureStep(title: 'Beine', hint: 'Zwei kurze Striche.', strokes: [
          Fig.s(Shapes.line(24, 76, 23, 92)),
          Fig.s(Shapes.line(34, 76, 35, 92)),
        ]),
        FigureStep(title: 'Inhalt und Schatten', hint: 'Zwei graue Linien als Text auf dem Blatt, dazu der Bodenschatten.', strokes: [
          Fig.grey(Shapes.line(62, 28, 82, 28)),
          Fig.grey(Shapes.line(62, 38, 76, 38)),
          Fig.groundShadow(30, 94, 14),
        ]),
      ],
    ),
    Figure(
      id: 'people.running',
      name: 'Laufende Figur',
      meaning: 'Tempo, Aufbruch, Dringlichkeit',
      mnemonic: 'Alles kippt nach vorn: Kopf vor dem Körper, Körper schräg, ein Bein weit hinten. Bewegungslinien hinten dran.',
      difficulty: 3,
      steps: [
        FigureStep(title: 'Kopf', hint: 'Der Kreis sitzt etwas weiter rechts als sonst, die Figur lehnt sich vor.', strokes: [
          Fig.s(Shapes.circle(52, 22, 8)),
        ]),
        FigureStep(title: 'Körper', hint: 'Der Kasten ist nach rechts gekippt.', strokes: [
          Fig.s(Shapes.poly([40, 35, 62, 33, 70, 64, 46, 68], close: true)),
        ]),
        FigureStep(title: 'Arme', hint: 'Ein Arm nach hinten unten, einer nach vorn oben.', strokes: [
          Fig.s(Shapes.line(42, 39, 26, 52)),
          Fig.s(Shapes.line(61, 37, 78, 46)),
        ]),
        FigureStep(title: 'Beine', hint: 'Hinteres Bein weit nach hinten, vorderes Bein nach vorn unten.', strokes: [
          Fig.s(Shapes.line(50, 68, 32, 84)),
          Fig.s(Shapes.line(66, 65, 78, 88)),
        ]),
        FigureStep(title: 'Bewegung', hint: 'Zwei, drei kurze graue Striche hinter der Figur. Fertig.', strokes: [
          Fig.grey(Shapes.line(14, 56, 26, 56)),
          Fig.grey(Shapes.line(10, 64, 24, 64)),
          Fig.grey(Shapes.line(14, 72, 26, 72)),
        ]),
      ],
    ),
  ],
);
