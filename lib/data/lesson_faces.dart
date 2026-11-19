import '../model/figure.dart';
import '../model/stroke_spec.dart';
import 'figure_helpers.dart';

/// Gesichtskreis, den alle Emotionen teilen.
StrokeSpec _face() => Fig.s(Shapes.circle(50, 50, 28));

final lessonFaces = Lesson(
  id: 'faces',
  title: 'Gesichter und Emotionen',
  subtitle: 'Mit Punkten, Bögen und Brauen Gefühle zeigen',
  intro: 'Zwei Punkte und ein Bogen reichen für ein Gesicht. Die Emotion machen Mund und Augenbrauen: '
      'Ein Bogen nach oben lächelt, einer nach unten trauert, schräge Brauen zeigen Ärger oder Sorge.',
  figures: [
    Figure(
      id: 'faces.happy',
      name: 'Fröhlich',
      meaning: 'Zufriedenheit, Erfolg, gute Stimmung',
      mnemonic: 'Augen als Punkte, Mund als Bogen nach oben. Je weiter der Bogen, desto breiter das Grinsen.',
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein großer Kreis.', strokes: [_face()]),
        FigureStep(title: 'Augen', hint: 'Zwei Punkte, etwa auf der Mittellinie, ein Augenabstand dazwischen.', strokes: [
          Fig.dot(40, 44, r: 2.2),
          Fig.dot(60, 44, r: 2.2),
        ]),
        FigureStep(title: 'Mund', hint: 'Ein Bogen nach oben, unterhalb der Mitte.', strokes: [
          Fig.s(Shapes.arc(50, 50, 15, 30, 120)),
        ]),
      ],
    ),
    Figure(
      id: 'faces.sad',
      name: 'Traurig',
      meaning: 'Enttäuschung, Verlust, Problem',
      mnemonic: 'Alles hängt: Der Mund ist ein Bogen nach unten, die Brauen steigen zur Mitte hin an.',
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein großer Kreis.', strokes: [_face()]),
        FigureStep(title: 'Augen', hint: 'Zwei Punkte.', strokes: [
          Fig.dot(40, 46, r: 2.2),
          Fig.dot(60, 46, r: 2.2),
        ]),
        FigureStep(title: 'Mund', hint: 'Ein Bogen nach unten, der untere Rand der Mundkurve zeigt zum Kinn.', strokes: [
          Fig.s(Shapes.arc(50, 76, 13, 215, 110)),
        ]),
        FigureStep(title: 'Brauen', hint: 'Zwei kurze Striche, die außen tiefer liegen und zur Mitte hin ansteigen.', strokes: [
          Fig.s(Shapes.line(34, 38, 45, 36)),
          Fig.s(Shapes.line(55, 36, 66, 38)),
        ]),
        FigureStep(title: 'Träne', hint: 'Eine kleine blaue Träne unter einem Auge. Farbe nur hier.', strokes: [
          Fig.blue(Shapes.poly([62, 52, 64, 58, 62, 61, 60, 58, 62, 52])),
        ]),
      ],
    ),
    Figure(
      id: 'faces.surprised',
      name: 'Überrascht',
      meaning: 'Aha-Moment, Neuigkeit, Schreck',
      mnemonic: 'Alles wird rund und weit: Augen als Kreise, Mund als kleiner Kreis, Brauen hoch.',
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein großer Kreis.', strokes: [_face()]),
        FigureStep(title: 'Augen', hint: 'Zwei kleine Kreise statt Punkte.', strokes: [
          Fig.s(Shapes.circle(40, 46, 3.5)),
          Fig.s(Shapes.circle(60, 46, 3.5)),
        ]),
        FigureStep(title: 'Mund', hint: 'Ein kleiner Kreis unterhalb der Mitte.', strokes: [
          Fig.s(Shapes.circle(50, 65, 5)),
        ]),
        FigureStep(title: 'Brauen', hint: 'Zwei kurze Bögen hoch über den Augen.', strokes: [
          Fig.s(Shapes.arc(40, 42, 9, -140, 100)),
          Fig.s(Shapes.arc(60, 42, 9, -140, 100)),
        ]),
      ],
    ),
    Figure(
      id: 'faces.angry',
      name: 'Wütend',
      meaning: 'Konflikt, Frust, Widerstand',
      mnemonic: 'Die Brauen bilden ein V zur Nase hin. Der Mund ist ein gerader Strich. Rote Blitze am Kopf verstärken.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein großer Kreis.', strokes: [_face()]),
        FigureStep(title: 'Augen', hint: 'Zwei Punkte.', strokes: [
          Fig.dot(40, 47, r: 2.2),
          Fig.dot(60, 47, r: 2.2),
        ]),
        FigureStep(title: 'Brauen', hint: 'Zwei Striche, die außen hoch sind und zur Mitte hin steil nach unten gehen.', strokes: [
          Fig.s(Shapes.line(33, 36, 45, 42)),
          Fig.s(Shapes.line(67, 36, 55, 42)),
        ]),
        FigureStep(title: 'Mund', hint: 'Ein gerader, kurzer Strich.', strokes: [
          Fig.s(Shapes.line(41, 66, 59, 66)),
        ]),
        FigureStep(title: 'Blitze', hint: 'Zwei rote Zacken rechts oben am Kopf.', strokes: [
          Fig.red(Shapes.poly([74, 22, 80, 18, 77, 26, 84, 22])),
          Fig.red(Shapes.poly([80, 34, 88, 32, 84, 38, 91, 37])),
        ]),
      ],
    ),
    Figure(
      id: 'faces.thinking',
      name: 'Nachdenklich',
      meaning: 'Offene Frage, Abwägen, Unsicherheit',
      mnemonic: 'Eine Braue hoch, der Mund schräg und klein, dazu die Gedankenblase mit Fragezeichen.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein großer Kreis, etwas nach links unten versetzt, damit rechts oben Platz bleibt.', strokes: [
          Fig.s(Shapes.circle(44, 56, 26)),
        ]),
        FigureStep(title: 'Augen', hint: 'Zwei Punkte, der Blick geht nach oben rechts: Punkte leicht nach rechts oben setzen.', strokes: [
          Fig.dot(36, 50, r: 2.2),
          Fig.dot(54, 48, r: 2.2),
        ]),
        FigureStep(title: 'Braue und Mund', hint: 'Eine Braue über dem rechten Auge hochgezogen, der Mund ein kurzer schräger Strich.', strokes: [
          Fig.s(Shapes.line(48, 38, 60, 40)),
          Fig.s(Shapes.line(38, 70, 50, 68)),
        ]),
        FigureStep(title: 'Gedankenblase', hint: 'Zwei kleine Kreise und eine runde Blase rechts oben.', strokes: [
          Fig.s(Shapes.circle(68, 32, 2.5)),
          Fig.s(Shapes.circle(74, 24, 4)),
          Fig.s(Shapes.circle(84, 14, 11)),
        ]),
        FigureStep(title: 'Fragezeichen', hint: 'Ein Bogen wie ein Haken, ein kurzer Strich, ein Punkt.', strokes: [
          Fig.s(Shapes.join([Shapes.arc(84, 11, 3.5, 180, 270), Shapes.line(84, 14.5, 84, 16.5)])),
          Fig.dot(84, 20, r: 1.2),
        ]),
      ],
    ),
    Figure(
      id: 'faces.wink',
      name: 'Zwinkern',
      meaning: 'Augenzwinkern, Humor, Insider',
      mnemonic: 'Ein Auge Punkt, ein Auge Bogen. Der Mund lächelt schräg nach oben zum geschlossenen Auge.',
      difficulty: 2,
      steps: [
        FigureStep(title: 'Kopf', hint: 'Ein großer Kreis.', strokes: [_face()]),
        FigureStep(title: 'Augen', hint: 'Links ein Punkt, rechts ein kleiner Bogen nach unten wie ein zugekniffenes Auge.', strokes: [
          Fig.dot(40, 45, r: 2.2),
          Fig.s(Shapes.arc(60, 42, 4.5, 20, 140)),
        ]),
        FigureStep(title: 'Mund', hint: 'Ein Lächeln, das rechts etwas höher endet.', strokes: [
          Fig.s(Shapes.quad(38, 62, 52, 74, 64, 60)),
        ]),
        FigureStep(title: 'Wangen', hint: 'Zwei kurze rote Striche auf den Wangen, ganz leicht.', strokes: [
          Fig.red(Shapes.line(30, 56, 36, 57), width: MarkerWidth.thin),
          Fig.red(Shapes.line(66, 56, 72, 55), width: MarkerWidth.thin),
        ]),
      ],
    ),
  ],
);
