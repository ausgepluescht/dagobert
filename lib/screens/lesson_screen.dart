import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../model/figure.dart';
import '../theme/palette.dart';
import '../widgets/figure_preview.dart';
import '../widgets/sketchy_card.dart';
import 'practice_screen.dart';

/// Eine Lektion: Einführung und die Figuren als Kacheln.
class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final store = ProgressScope.of(context);
    final text = Theme.of(context).textTheme;
    final firstOpen = lesson.figures.where((f) => !store.isDone(f.id)).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(lesson.intro, style: text.bodyLarge),
          const SizedBox(height: 14),
          if (firstOpen != null)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _open(context, firstOpen),
                icon: const Icon(Icons.brush_outlined),
                label: Text(store.doneCount(lesson) == 0 ? 'Lektion starten' : 'Weiter mit ${firstOpen.name}'),
              ),
            ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 190,
              mainAxisSpacing: 16,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: lesson.figures.length,
            itemBuilder: (context, i) => _FigureTile(
              figure: lesson.figures[i],
              index: i,
              onTap: () => _open(context, lesson.figures[i]),
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Figure figure) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PracticeScreen(figure: figure, lesson: lesson)));
  }
}

class _FigureTile extends StatelessWidget {
  const _FigureTile({required this.figure, required this.index, required this.onTap});

  final Figure figure;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = ProgressScope.of(context);
    final text = Theme.of(context).textTheme;
    final done = store.isDone(figure.id);
    final best = store.bestScore(figure.id);

    return SketchyCard(
      seed: figure.id.hashCode,
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, c) => FigurePreview(figure, size: c.biggest.shortestSide),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(figure.name, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (done) const Icon(Icons.check_circle_rounded, size: 18, color: Palette.markerGreen),
            ],
          ),
          Row(
            children: [
              for (var d = 0; d < 3; d++)
                Icon(
                  Icons.circle,
                  size: 7,
                  color: d < figure.difficulty ? Palette.inkSoft : Palette.inkFaint,
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(best != null ? 'Beste $best %' : figure.meaning, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
