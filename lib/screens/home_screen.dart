import 'package:flutter/material.dart';

import '../data/lessons.dart';
import '../data/progress_store.dart';
import '../model/figure.dart';
import '../theme/palette.dart';
import '../widgets/figure_preview.dart';
import '../widgets/sketchy_card.dart';
import 'lesson_screen.dart';
import 'practice_screen.dart';

/// Startseite: alle Lektionen als Karten, dazu der Einstieg ins freie Blatt.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressScope.of(context);
    final text = Theme.of(context).textTheme;
    final totalFigures = allLessons.fold(0, (n, l) => n + l.figures.length);
    final doneFigures = allLessons.fold(0, (n, l) => n + store.doneCount(l));
    final nextLesson = allLessons.firstWhere((l) => !store.isLessonDone(l), orElse: () => allLessons.last);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flipo'),
        actions: [
          IconButton(
            tooltip: 'Freies Blatt',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PracticeScreen())),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'reset') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Palette.paper,
                    title: const Text('Fortschritt löschen?'),
                    content: const Text('Alle Haken und Bestwerte werden zurückgesetzt.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
                    ],
                  ),
                );
                if (ok == true) await store.reset();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'reset', child: Text('Fortschritt zurücksetzen')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text('Flipchart-Figuren zeichnen lernen', style: text.headlineSmall),
          const SizedBox(height: 4),
          const SketchyUnderline(width: 180),
          const SizedBox(height: 10),
          Text(
            'Strich für Strich, Lektion für Lektion. Die Vorlage liegt blass unter deinem Blatt, '
            'du malst sie nach. Licht von oben links, Schatten grau nach rechts unten.',
            style: text.bodyMedium?.copyWith(color: Palette.inkSoft),
          ),
          const SizedBox(height: 10),
          Text('$doneFigures von $totalFigures Figuren geübt', style: text.bodySmall),
          const SizedBox(height: 20),
          for (var i = 0; i < allLessons.length; i++) ...[
            _LessonCard(lesson: allLessons[i], index: i, recommended: allLessons[i] == nextLesson),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.index, required this.recommended});

  final Lesson lesson;
  final int index;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final store = ProgressScope.of(context);
    final text = Theme.of(context).textTheme;
    final done = store.doneCount(lesson);
    final preview = lesson.figures[(lesson.figures.length / 2).floor()];

    return SketchyCard(
      seed: index * 31 + 7,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson))),
      child: Row(
        children: [
          FigurePreview(preview, size: 76),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Lektion ${index + 1}', style: text.bodySmall),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(color: Palette.accent, width: 1.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Dran', style: text.bodySmall?.copyWith(color: Palette.accent)),
                      ),
                    ],
                  ],
                ),
                Text(lesson.title, style: text.titleMedium),
                Text(lesson.subtitle, style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < lesson.figures.length; i++)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < done ? Palette.markerGreen : Colors.transparent,
                          border: Border.all(color: i < done ? Palette.markerGreen : Palette.inkFaint, width: 1.4),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text('$done/${lesson.figures.length}', style: text.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
        ],
      ),
    );
  }
}
