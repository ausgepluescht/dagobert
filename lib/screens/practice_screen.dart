import 'package:flutter/material.dart';

import '../data/lessons.dart';
import '../data/progress_store.dart';
import '../model/drawing.dart';
import '../model/figure.dart';
import '../model/scoring.dart';
import '../model/stroke_spec.dart';
import '../theme/palette.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/figure_preview.dart';
import '../widgets/marker_toolbar.dart';
import '../widgets/sketchy_card.dart';

/// Übungsblatt für eine Figur. Ohne Figur: freies Blatt.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, this.figure, this.lesson});

  final Figure? figure;
  final Lesson? lesson;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  final _drawing = Drawing();
  MarkerColor _color = MarkerColor.black;
  MarkerWidth _width = MarkerWidth.medium;
  int _step = 0;
  bool _ghost = true;

  late final AnimationController _demo = AnimationController(vsync: this)
    ..addListener(() => setState(() {}))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _demo.status == AnimationStatus.completed) {
            setState(() => _demo.reset());
          }
        });
      }
    });

  Figure? get _figure => widget.figure;
  FigureStep? get _currentStep => _figure?.steps[_step];
  bool get _isLastStep => _figure != null && _step == _figure!.steps.length - 1;

  @override
  void initState() {
    super.initState();
    final step = _currentStep;
    if (step != null && step.strokes.isNotEmpty) {
      _adoptStepTool(step);
    }
  }

  @override
  void dispose() {
    _demo.dispose();
    super.dispose();
  }

  /// Farbe und Stärke des Schritts vorwählen, damit der richtige Marker in der Hand liegt.
  void _adoptStepTool(FigureStep step) {
    final first = step.strokes.first;
    _color = first.color;
    _width = first.width;
  }

  double _stepLength(FigureStep step) =>
      step.strokes.fold(0.0, (sum, s) => sum + s.length);

  void _playDemo() {
    final step = _currentStep;
    if (step == null) return;
    final len = _stepLength(step);
    _demo.duration = Duration(
      milliseconds: (600 + len * 14).round().clamp(700, 4500),
    );
    _demo.forward(from: 0);
  }

  /// Blatt leeren, aber beim aktuellen Schritt bleiben: noch einmal üben.
  void _restart() {
    setState(() {
      _demo.reset();
      _drawing.clear();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Blatt ist leer. Noch einmal.'),
          duration: Duration(seconds: 1),
        ),
      );
  }

  void _goToStep(int index) {
    final f = _figure;
    if (f == null) return;
    setState(() {
      _demo.reset();
      _step = index.clamp(0, f.steps.length - 1);
      final step = f.steps[_step];
      if (step.strokes.isNotEmpty) _adoptStepTool(step);
    });
  }

  Future<void> _finish() async {
    final f = _figure;
    if (f == null) return;
    final result = scoreDrawing(_drawing.strokes, f);
    final store = ProgressScope.of(context);
    await store.recordAttempt(f.id, result.percent);
    if (!mounted) return;
    final next = _nextFigure();
    final action = await showModalBottomSheet<_AfterFinish>(
      context: context,
      backgroundColor: Palette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: _ResultSheet(
          figure: f,
          result: result,
          next: next,
          empty: _drawing.isEmpty,
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _AfterFinish.again:
        setState(() {
          _drawing.clear();
          _goToStep(0);
        });
      case _AfterFinish.next:
        if (next != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  PracticeScreen(figure: next, lesson: widget.lesson),
            ),
          );
        }
      case _AfterFinish.back:
        Navigator.of(context).pop();
      case null:
        break;
    }
  }

  Figure? _nextFigure() {
    final lesson = widget.lesson;
    final f = _figure;
    if (lesson == null || f == null) return null;
    final i = lesson.figures.indexOf(f);
    if (i >= 0 && i + 1 < lesson.figures.length) return lesson.figures[i + 1];
    // Letzte Figur der Lektion: erste Figur der nächsten Lektion anbieten.
    final li = allLessons.indexOf(lesson);
    if (li >= 0 && li + 1 < allLessons.length) {
      return allLessons[li + 1].figures.first;
    }
    return null;
  }

  void _showInfo() {
    final f = _figure;
    if (f == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FigurePreview(f, size: 84),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        f.meaning,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Merkhilfe', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(f.mnemonic, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            Text('Schritte', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            for (var i = 0; i < f.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${i + 1}. ${f.steps[i].title}: ${f.steps[i].hint}',
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = _figure;
    final step = _currentStep;
    final demoLength =
        _demo.isAnimating || _demo.status == AnimationStatus.completed
        ? (step == null
              ? null
              : _stepLength(step) * Curves.easeInOut.transform(_demo.value))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(f?.name ?? 'Freies Blatt'),
        actions: [
          IconButton(
            tooltip: 'Neu üben: Blatt leeren',
            onPressed: _drawing.isEmpty ? null : _restart,
            icon: const Icon(Icons.refresh_rounded),
          ),
          if (f != null) ...[
            IconButton(
              tooltip: _ghost ? 'Vorlage ausblenden' : 'Vorlage einblenden',
              onPressed: () => setState(() => _ghost = !_ghost),
              icon: Icon(
                _ghost
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Vorführen',
              onPressed: _playDemo,
              icon: const Icon(Icons.play_circle_outline),
            ),
            IconButton(
              tooltip: 'Merkhilfe',
              onPressed: _showInfo,
              icon: const Icon(Icons.lightbulb_outline),
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (f != null && step != null)
              _StepHeader(figure: f, step: _step, onStep: _goToStep),
            Expanded(
              child: ClipRect(
                child: DrawingCanvas(
                  strokes: _drawing.strokes,
                  color: _color,
                  width: _width,
                  figure: f,
                  currentStep: _step,
                  showGhost: _ghost,
                  demoLength: demoLength,
                  onStrokeEnd: (s) => setState(() => _drawing.add(s)),
                ),
              ),
            ),
            if (f != null && step != null)
              _StepNavigation(
                step: step,
                index: _step,
                count: f.steps.length,
                onPrev: _step > 0 ? () => _goToStep(_step - 1) : null,
                onNext: _isLastStep ? _finish : () => _goToStep(_step + 1),
                isLast: _isLastStep,
              ),
            MarkerToolbar(
              color: _color,
              width: _width,
              onColor: (c) => setState(() => _color = c),
              onWidth: (w) => setState(() => _width = w),
              canUndo: _drawing.canUndo,
              canRedo: _drawing.canRedo,
              onUndo: () => setState(_drawing.undo),
              onRedo: () => setState(_drawing.redo),
              onClear: () => setState(_drawing.clear),
            ),
          ],
        ),
      ),
    );
  }
}

/// Schrittleiste: ein Punkt pro Schritt, der aktuelle gefüllt.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.figure,
    required this.step,
    required this.onStep,
  });

  final Figure figure;
  final int step;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          for (var i = 0; i < figure.steps.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onStep(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 8,
                  ),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < step
                          ? Palette.ink
                          : i == step
                          ? Palette.accent
                          : Palette.inkFaint,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepNavigation extends StatelessWidget {
  const _StepNavigation({
    required this.step,
    required this.index,
    required this.count,
    required this.onPrev,
    required this.onNext,
    required this.isLast,
  });

  final FigureStep step;
  final int index;
  final int count;
  final VoidCallback? onPrev;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      color: Palette.paper,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Schritt zurück',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schritt ${index + 1} von $count: ${step.title}',
                  style: text.titleSmall,
                ),
                Text(
                  step.hint,
                  style: text.bodySmall?.copyWith(color: Palette.ink),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isLast
              ? FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Fertig'),
                )
              : IconButton.filled(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: 'Nächster Schritt',
                  style: IconButton.styleFrom(
                    backgroundColor: Palette.ink,
                    foregroundColor: Palette.paper,
                  ),
                ),
        ],
      ),
    );
  }
}

enum _AfterFinish { again, next, back }

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.figure,
    required this.result,
    required this.next,
    required this.empty,
  });

  final Figure figure;
  final ScoreResult result;
  final Figure? next;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SketchyCard(
                seed: figure.id.hashCode,
                padding: const EdgeInsets.all(14),
                shadow: false,
                tilt: false,
                child: Text(
                  '${result.percent} %',
                  style: text.displaySmall?.copyWith(color: Palette.accent),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(figure.name, style: text.titleLarge),
                    Text(
                      empty
                          ? 'Leeres Blatt. Trau dich, der erste Strich zählt.'
                          : result.verdict,
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Deckung ${(result.coverage * 100).round()} %, Genauigkeit ${(result.precision * 100).round()} %',
            style: text.bodySmall,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_AfterFinish.again),
                  child: const Text('Noch einmal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(next != null ? _AfterFinish.next : _AfterFinish.back),
                  child: Text(
                    next != null ? 'Weiter: ${next!.name}' : 'Zur Übersicht',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
