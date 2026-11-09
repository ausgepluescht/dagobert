import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wish_item.dart';
import '../../services/check_questions.dart';
import '../../services/money_format.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/answer_slider.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../decision/decision_screen.dart';

/// Kauf-Check auf einer Seite: alle Fragen untereinander, jede mit einem
/// Schieberegler Nein · Teils · Ja. Die Karte färbt sich mit der Antwort.
class CheckFlowScreen extends ConsumerStatefulWidget {
  const CheckFlowScreen({super.key, this.wishId, this.standalone = false});

  final String? wishId;

  /// true = als eigene Seite gepusht, false = als Tab.
  final bool standalone;

  @override
  ConsumerState<CheckFlowScreen> createState() => _CheckFlowScreenState();
}

class _CheckFlowScreenState extends ConsumerState<CheckFlowScreen> {
  final _answers = <String, CheckAnswer>{};
  CheckMode _mode = CheckMode.core;
  final _scroll = ScrollController();

  bool get _isPushed => widget.wishId != null || widget.standalone;

  WishItem? get _wish => widget.wishId == null
      ? null
      : ref.read(wishesProvider).where((w) => w.id == widget.wishId).firstOrNull;

  WishType get _type => _wish?.type ?? WishType.want;

  List<CheckQuestion> get _questions => CheckQuestions.forMode(_mode, _type);

  @override
  void initState() {
    super.initState();
    final w = _wish;
    if (w != null) {
      _answers.addAll(w.checkAnswers);
      // Modus anhand der gespeicherten Antworten wiederherstellen.
      final ids = w.checkAnswers.keys.toSet();
      if (ids.any((id) => CheckQuestions.deeper.any((q) => q.id == id))) {
        _mode = CheckMode.big;
      } else if (ids.any((id) => CheckQuestions.moment.any((q) => q.id == id))) {
        _mode = CheckMode.impulse;
      }
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final w = _wish;
    if (w != null) {
      await ref.read(wishesProvider.notifier).saveCheck(w.id, Map.of(_answers));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => DecisionScreen(wishId: w.id)),
      );
    } else if (_isPushed) {
      Navigator.of(context).maybePop();
    } else {
      setState(_answers.clear);
      _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showBackground(CheckQuestion q) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _BackgroundSheet(question: q),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questions;
    final answered = questions.where((q) => _answers.containsKey(q.id)).length;
    final score = CheckQuestions.scoreFor(questions, _answers);
    final verdict = CheckQuestions.verdictFor(score, questions.length);
    final allAnswered = answered == questions.length;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final wish = _wish;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              if (_isPushed) ...[
                const BackIconButton(),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wish == null ? 'Kauf-Check' : 'Kauf-Check', style: DgType.h1),
                    if (wish != null)
                      Text(
                        '${wish.title} · ${MoneyFormat.euro(wish.priceCents)}',
                        style: DgType.meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text('Bauchgefühl schieben, Farbe lesen.', style: DgType.meta),
                  ],
                ),
              ),
              _ScoreBadge(score: score, total: questions.length, answered: answered),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final m in CheckMode.values) ...[
                _ModeChip(
                  mode: m,
                  count: CheckQuestions.forMode(m, _type).length,
                  selected: _mode == m,
                  onTap: () => setState(() => _mode = m),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(20, 4, 20, _isPushed ? 16 : 110),
            itemCount: questions.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == questions.length) {
                return _Summary(
                  score: score,
                  total: questions.length,
                  answered: answered,
                  verdict: verdict,
                );
              }
              final q = questions[i];
              final prev = i == 0 ? null : questions[i - 1];
              final showSection = prev == null || prev.section != q.section;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSection && _questions.any((x) => x.section != CheckSection.core))
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 6, bottom: 8),
                      child: Text(
                        q.section.title.toUpperCase(),
                        style: DgType.label.copyWith(
                          color: q.section == CheckSection.need ? DgColors.blueText : DgColors.copper,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  _QuestionTile(
                    index: i + 1,
                    question: q,
                    answer: _answers[q.id],
                    onChanged: (a) => setState(() => _answers[q.id] = a),
                    onInfo: () => _showBackground(q),
                  ),
                ],
              );
            },
          ),
        ),
        if (_isPushed)
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
            child: FilledButton(
              onPressed: answered == 0 ? null : _finish,
              child: Text(
                wish == null
                    ? 'Fertig'
                    : allAnswered
                    ? 'Ergebnis speichern'
                    : 'Speichern ($answered von ${questions.length})',
              ),
            ),
          ),
      ],
    );

    if (_isPushed) {
      return Scaffold(
        backgroundColor: DgColors.warmWhite,
        body: SafeArea(bottom: false, child: body),
      );
    }
    return ColoredBox(
      color: DgColors.warmWhite,
      child: SafeArea(bottom: false, child: body),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.mode,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final CheckMode mode;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DgColors.orange : DgColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? DgColors.orange : DgColors.sand),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            '${mode.title} · $count',
            style: DgType.label.copyWith(
              fontSize: 13,
              color: selected ? DgColors.white : DgColors.espresso,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.index,
    required this.question,
    required this.answer,
    required this.onChanged,
    required this.onInfo,
  });

  final int index;
  final CheckQuestion question;
  final CheckAnswer? answer;
  final ValueChanged<CheckAnswer> onChanged;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final color = AnswerSlider.colorFor(answer);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AnswerSlider.tintFor(answer),
        borderRadius: BorderRadius.circular(DgRadius.card),
        border: Border.all(color: answer == null ? DgColors.sand : color, width: answer == null ? 1 : 1.5),
        boxShadow: answer == null ? DgShadow.card : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: answer == null ? DgColors.goldDust : color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: DgType.label.copyWith(
                    fontSize: 11,
                    color: answer == null ? DgColors.espresso : DgColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.question,
                  style: DgType.bodyStrong.copyWith(fontSize: 15, height: 1.3),
                ),
              ),
              const SizedBox(width: 6),
              Semantics(
                button: true,
                label: 'Hintergrund zur Frage',
                child: InkWell(
                  onTap: onInfo,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(DgIcons.question, size: 20, color: DgColors.cocoa),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnswerSlider(value: answer, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.total, required this.answered});
  final double score;
  final int total;
  final int answered;

  @override
  Widget build(BuildContext context) {
    final verdict = CheckQuestions.verdictFor(score, total);
    final color = answered == 0
        ? DgColors.cocoa
        : switch (verdict) {
            CheckVerdict.smart => DgColors.pineGreen,
            CheckVerdict.letItRipen => DgColors.copper,
            CheckVerdict.leakage => DgColors.brick,
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DgColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DgColors.sand),
      ),
      child: Column(
        children: [
          Text(
            '${CheckQuestions.formatScore(score)} / $total',
            style: DgType.bodyStrong.copyWith(fontSize: 16, color: color, fontFeatures: DgType.tabular),
          ),
          Text('Punkte', style: DgType.meta.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.score,
    required this.total,
    required this.answered,
    required this.verdict,
  });

  final double score;
  final int total;
  final int answered;
  final CheckVerdict verdict;

  @override
  Widget build(BuildContext context) {
    if (answered == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'Schieb den Regler dorthin, wo dein Bauchgefühl ist: links Nein, rechts Ja, Mitte Teils. Grün heißt Ja, Rot heißt Nein. Das Fragezeichen zeigt, was die Forschung dazu sagt.',
          style: DgType.meta,
          textAlign: TextAlign.center,
        ),
      );
    }
    final color = switch (verdict) {
      CheckVerdict.smart => DgColors.pineGreen,
      CheckVerdict.letItRipen => DgColors.copper,
      CheckVerdict.leakage => DgColors.brick,
    };
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DgColors.white,
        borderRadius: BorderRadius.circular(DgRadius.card),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answered < total ? '${verdict.title} (bisher $answered von $total beantwortet)' : verdict.title,
            style: DgType.bodyStrong.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(verdict.body, style: DgType.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _BackgroundSheet extends StatelessWidget {
  const _BackgroundSheet({required this.question});
  final CheckQuestion question;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      maxChildSize: 0.92,
      builder: (ctx, controller) => ListView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
        children: [
          Text(
            question.section.title.toUpperCase(),
            style: DgType.label.copyWith(color: DgColors.copper, fontSize: 11, letterSpacing: 0.6),
          ),
          const SizedBox(height: 6),
          Text(question.question, style: DgType.h1.copyWith(fontSize: 22)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: DgColors.goldDust, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(DgIcons.lightbulb, size: 18, color: DgColors.espresso),
                const SizedBox(width: 10),
                Expanded(child: Text(question.prompt, style: DgType.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final p in question.background) ...[
            Text(p, style: DgType.body.copyWith(fontSize: 14)),
            const SizedBox(height: 10),
          ],
          if (question.limit.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Grenzen der Befunde: ${question.limit}',
              style: DgType.meta.copyWith(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Schließen')),
        ],
      ),
    );
  }
}
