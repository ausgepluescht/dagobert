import 'stroke_spec.dart';

/// Ein Schritt beim Zeichnen einer Figur: ein oder mehrere Striche plus eine
/// kurze Anleitung.
class FigureStep {
  const FigureStep({required this.title, required this.hint, required this.strokes});

  /// Kurzer Name des Schritts, z. B. "Kopf".
  final String title;

  /// Was genau zu tun ist, in einem Satz.
  final String hint;

  final List<StrokeSpec> strokes;
}

/// Eine zeichenbare Figur mit Schritt-für-Schritt-Anleitung.
class Figure {
  const Figure({
    required this.id,
    required this.name,
    required this.meaning,
    required this.mnemonic,
    required this.steps,
    this.difficulty = 1,
  });

  /// Stabile ID für den Fortschritt, z. B. "basics.circle".
  final String id;

  final String name;

  /// Wofür die Figur auf dem Flipchart steht.
  final String meaning;

  /// Merkhilfe oder Eselsbrücke.
  final String mnemonic;

  /// 1 = leicht, 3 = knifflig.
  final int difficulty;

  final List<FigureStep> steps;

  Iterable<StrokeSpec> get allStrokes => steps.expand((s) => s.strokes);
}

/// Ein thematisches Kapitel aus mehreren Figuren.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.figures,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Zwei, drei Sätze Einführung ins Kapitel.
  final String intro;

  final List<Figure> figures;
}
