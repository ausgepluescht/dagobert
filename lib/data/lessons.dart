import '../model/figure.dart';
import 'lesson_arrows.dart';
import 'lesson_basics.dart';
import 'lesson_containers.dart';
import 'lesson_faces.dart';
import 'lesson_people.dart';
import 'lesson_places.dart';
import 'lesson_symbols.dart';
import 'lesson_work.dart';

/// Alle Lektionen in der empfohlenen Reihenfolge.
final List<Lesson> allLessons = [
  lessonBasics,
  lessonContainers,
  lessonArrows,
  lessonPeople,
  lessonFaces,
  lessonSymbols,
  lessonWork,
  lessonPlaces,
];

Figure? findFigure(String id) {
  for (final lesson in allLessons) {
    for (final figure in lesson.figures) {
      if (figure.id == id) return figure;
    }
  }
  return null;
}
