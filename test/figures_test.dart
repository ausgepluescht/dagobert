import 'package:flipo/data/lessons.dart';
import 'package:flipo/model/drawing.dart';
import 'package:flipo/model/scoring.dart';
import 'package:flipo/model/stroke_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Alle Figuren haben eindeutige IDs und mindestens einen Schritt', () {
    final ids = <String>{};
    for (final lesson in allLessons) {
      expect(lesson.figures, isNotEmpty, reason: lesson.id);
      for (final f in lesson.figures) {
        expect(ids.add(f.id), isTrue, reason: 'Doppelte ID ${f.id}');
        expect(f.id.startsWith('${lesson.id}.'), isTrue, reason: f.id);
        expect(f.steps, isNotEmpty, reason: f.id);
        expect(f.mnemonic, isNotEmpty, reason: f.id);
        for (final step in f.steps) {
          expect(step.strokes, isNotEmpty, reason: '${f.id}/${step.title}');
          expect(step.hint, isNotEmpty, reason: '${f.id}/${step.title}');
        }
      }
    }
  });

  test('Alle Punkte liegen im Blatt (0..100) und Striche haben Länge', () {
    for (final lesson in allLessons) {
      for (final f in lesson.figures) {
        for (final s in f.allStrokes) {
          expect(s.points.length, greaterThanOrEqualTo(2), reason: f.id);
          for (final p in s.points) {
            expect(p.dx, inInclusiveRange(0, 100), reason: '${f.id}: $p');
            expect(p.dy, inInclusiveRange(0, 100), reason: '${f.id}: $p');
          }
          expect(s.length, greaterThan(0), reason: f.id);
        }
        expect(figureInkLength(f), greaterThan(20), reason: f.id);
      }
    }
  });

  test('prefix liefert einen Anfangsabschnitt der Polylinie', () {
    final s = StrokeSpec(Shapes.line(0, 0, 10, 0));
    expect(s.length, 10);
    expect(s.prefix(4).last, const Offset(4, 0));
    expect(s.prefix(100).last, const Offset(10, 0));
  });

  test('Exaktes Nachzeichnen ergibt einen hohen Wert, leeres Blatt null', () {
    final f = findFigure('basics.square')!;
    final traced = [
      for (final s in f.allStrokes) UserStroke(color: s.color, width: s.width, points: List.of(s.points)),
    ];
    final good = scoreDrawing(traced, f);
    expect(good.percent, greaterThanOrEqualTo(95));
    expect(scoreDrawing(const [], f).percent, 0);

    final wrong = [UserStroke(color: MarkerColor.black, width: MarkerWidth.medium, points: Shapes.line(0, 0, 2, 2))];
    expect(scoreDrawing(wrong, f).percent, lessThan(20));
  });

  test('Lektionen lassen sich über IDs finden', () {
    expect(findFigure('people.figure')?.name, 'Flipchart-Figur');
    expect(findFigure('gibt.es.nicht'), isNull);
  });
}
