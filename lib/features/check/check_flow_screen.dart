import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wish_item.dart';
import '../../services/check_questions.dart';
import '../../services/money_format.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../decision/decision_screen.dart';

/// 5-Fragen-Check. Mit [wishId] für einen Eintrag, ohne als Schnell-Check.
/// Als Tab eingebettet zeigt er eine Startkarte, im Push-Modus läuft er direkt.
class CheckFlowScreen extends ConsumerStatefulWidget {
  const CheckFlowScreen({super.key, this.wishId, this.standalone = false});

  final String? wishId;

  /// true = als eigene Seite gepusht (mit Zurück), false = als Tab.
  final bool standalone;

  @override
  ConsumerState<CheckFlowScreen> createState() => _CheckFlowScreenState();
}

class _CheckFlowScreenState extends ConsumerState<CheckFlowScreen> {
  final _answers = <String, CheckAnswer>{};
  int _index = 0;
  bool _started = false;
  bool _done = false;
  int? _expectedUses;
  final _usesController = TextEditingController();

  bool get _isPushed => widget.wishId != null || widget.standalone;

  WishItem? get _wish => widget.wishId == null
      ? null
      : ref.read(wishesProvider).where((w) => w.id == widget.wishId).firstOrNull;

  List<CheckQuestion> get _questions =>
      CheckQuestions.forType(_wish?.type ?? WishType.want);

  @override
  void initState() {
    super.initState();
    _started = _isPushed;
    final w = _wish;
    if (w != null) {
      _answers.addAll(w.checkAnswers);
      _expectedUses = w.expectedUses;
      if (_expectedUses != null) _usesController.text = '$_expectedUses';
    }
  }

  @override
  void dispose() {
    _usesController.dispose();
    super.dispose();
  }

  void _answer(CheckAnswer a) {
    HapticFeedback.selectionClick();
    setState(() {
      _answers[_questions[_index].id] = a;
      if (_index < _questions.length - 1) {
        _index++;
      } else {
        _done = true;
      }
    });
  }

  void _back() {
    if (_done) {
      setState(() => _done = false);
      return;
    }
    if (_index > 0) {
      setState(() => _index--);
    } else if (_isPushed) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _started = false);
    }
  }

  Future<void> _finish() async {
    final w = _wish;
    if (w != null) {
      await ref
          .read(wishesProvider.notifier)
          .saveCheck(w.id, Map.of(_answers), expectedUses: _expectedUses);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => DecisionScreen(wishId: w.id)),
      );
    } else if (_isPushed) {
      Navigator.of(context).maybePop();
    } else {
      setState(() {
        _started = false;
        _done = false;
        _index = 0;
        _answers.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = !_started
        ? _Intro(onStart: () => setState(() => _started = true))
        : _done
        ? _Result(
            answers: _answers,
            wish: _wish,
            expectedUses: _expectedUses,
            onBack: _back,
            onFinish: _finish,
          )
        : _QuestionCard(
            question: _questions[_index],
            index: _index,
            total: _questions.length,
            isCore: _index < CheckQuestions.core.length,
            current: _answers[_questions[_index].id],
            wish: _wish,
            score: CheckQuestions.score(_answers),
            onAnswer: _answer,
            onBack: _back,
            onSkip: () => setState(() => _done = true),
            usesController: _usesController,
            onUsesChanged: (v) => setState(() => _expectedUses = int.tryParse(v)),
          );

    if (_isPushed) {
      return Scaffold(
        backgroundColor: DgColors.warmWhite,
        body: SafeArea(child: body),
      );
    }
    return ColoredBox(
      color: _started ? DgColors.warmWhite : DgColors.white,
      child: SafeArea(bottom: false, child: body),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        const Text('5-Fragen-Check', style: DgType.h1),
        const SizedBox(height: 6),
        Text(
          'Fünf Fragen aus der Glücksforschung. Keine Verbote, nur ein klarer Blick. Drei oder mehr Punkte: wahrscheinlich eine kluge Ausgabe.',
          style: DgType.meta.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 20),
        for (final (i, q) in CheckQuestions.core.indexed) ...[
          SurfaceCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: DgColors.goldDust,
                    shape: BoxShape.circle,
                  ),
                  child: Text('${i + 1}', style: DgType.label.copyWith(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(q.question, style: DgType.bodyStrong.copyWith(fontSize: 15)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(DgIcons.check, size: 20),
          label: const Text('Schnell-Check starten'),
        ),
        const SizedBox(height: 10),
        Text(
          'Tipp: Starte den Check direkt beim Merken eines Wunschs, dann wird das Ergebnis am Eintrag gespeichert.',
          style: DgType.meta.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.total,
    required this.isCore,
    required this.current,
    required this.wish,
    required this.score,
    required this.onAnswer,
    required this.onBack,
    required this.onSkip,
    required this.usesController,
    required this.onUsesChanged,
  });

  final CheckQuestion question;
  final int index;
  final int total;
  final bool isCore;
  final CheckAnswer? current;
  final WishItem? wish;
  final double score;
  final ValueChanged<CheckAnswer> onAnswer;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final TextEditingController usesController;
  final ValueChanged<String> onUsesChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rate = ref.watch(hourlyRateProvider);
    final showCostPerUse = question.id == 'treat' && wish != null;
    final uses = int.tryParse(usesController.text);
    final perUse = showCostPerUse && uses != null && uses > 0
        ? (wish!.priceCents / uses).round()
        : null;
    final perUseMinutes = perUse == null ? null : WorkHours.minutesFor(perUse, rate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              BackIconButton(onPressed: onBack),
              Expanded(
                child: Column(
                  children: [
                    if (wish != null)
                      Text(
                        '${wish!.title} · ${MoneyFormat.euro(wish!.priceCents)}',
                        style: DgType.label.copyWith(color: DgColors.cocoa, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < total; i++)
                          Container(
                            width: total > 5 ? 16 : 22,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i <= index
                                  ? (i < CheckQuestions.core.length ? DgColors.orange : DgColors.calmBlue)
                                  : DgColors.sand,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            children: [
              Text(
                isCore
                    ? 'FRAGE ${index + 1} VON ${CheckQuestions.core.length}'
                    : 'BRAUCHE ICH · ZUSATZFRAGE ${index + 1 - CheckQuestions.core.length} VON ${total - CheckQuestions.core.length}',
                style: DgType.label.copyWith(
                  color: isCore ? DgColors.copper : DgColors.blueText,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                question.question,
                style: DgType.h1.copyWith(fontSize: 30, height: 1.15, letterSpacing: -0.5),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: DgColors.white,
                  borderRadius: BorderRadius.circular(DgRadius.card),
                  border: Border.all(color: DgColors.sand),
                  boxShadow: DgShadow.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: DgIcons.lightbulb,
                      iconBg: DgColors.goldDust,
                      iconColor: DgColors.espresso,
                      label: 'Warum?',
                      text: question.why,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(),
                    ),
                    _InfoRow(
                      icon: DgIcons.question,
                      iconBg: DgColors.warmWhite,
                      iconColor: DgColors.copper,
                      label: 'Denkanstoß',
                      text: question.prompt,
                      strong: true,
                    ),
                    if (showCostPerUse) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(),
                      ),
                      Text('Kosten pro Nutzung', style: DgType.label.copyWith(color: DgColors.cocoa, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: usesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: onUsesChanged,
                              style: DgType.bodyStrong.copyWith(fontFeatures: DgType.tabular),
                              decoration: const InputDecoration(
                                hintText: '20',
                                suffixText: '×',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              perUse == null
                                  ? 'Wie oft wirst du es realistisch nutzen?'
                                  : '${MoneyFormat.euro(perUse, forceCents: true)} pro Nutzung'
                                        '${perUseMinutes == null ? '' : ', etwa $perUseMinutes Arbeitsminuten'}',
                              style: DgType.meta.copyWith(
                                fontWeight: FontWeight.w600,
                                color: perUse == null ? DgColors.cocoa : DgColors.espresso,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AnswerButton(
                      label: 'Nein',
                      icon: DgIcons.close,
                      selected: current == CheckAnswer.no,
                      onTap: () => onAnswer(CheckAnswer.no),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnswerButton(
                      label: 'Teils',
                      icon: Icons.remove_rounded,
                      selected: current == CheckAnswer.partly,
                      onTap: () => onAnswer(CheckAnswer.partly),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnswerButton(
                      label: 'Ja',
                      icon: DgIcons.skipped,
                      primary: true,
                      selected: current == CheckAnswer.yes,
                      onTap: () => onAnswer(CheckAnswer.yes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Bisher: ',
                      style: DgType.meta.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: '${CheckQuestions.formatScore(score)} Punkte',
                          style: DgType.label.copyWith(fontSize: 12, fontFeatures: DgType.tabular),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: onSkip, child: const Text('Überspringen')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.text,
    this.strong = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
            border: iconBg == DgColors.warmWhite ? Border.all(color: DgColors.sand) : null,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DgType.label.copyWith(color: DgColors.cocoa, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                text,
                style: DgType.body.copyWith(
                  fontSize: 14,
                  fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? DgColors.copper : (selected ? DgColors.goldDust : DgColors.white);
    final fg = primary ? DgColors.white : (selected ? DgColors.espresso : DgColors.cocoa);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary ? DgColors.copper : DgColors.sand),
            boxShadow: primary
                ? const [BoxShadow(color: Color(0x4DB85A12), blurRadius: 20, offset: Offset(0, 8))]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: DgType.label.copyWith(
                  fontSize: 14,
                  color: fg,
                  fontWeight: primary ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({
    required this.answers,
    required this.wish,
    required this.expectedUses,
    required this.onBack,
    required this.onFinish,
  });

  final Map<String, CheckAnswer> answers;
  final WishItem? wish;
  final int? expectedUses;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = CheckQuestions.score(answers);
    final verdict = CheckQuestions.verdict(score);
    final color = switch (verdict) {
      CheckVerdict.smart => DgColors.savingsGreen,
      CheckVerdict.letItRipen => DgColors.gold,
      CheckVerdict.leakage => DgColors.brick,
    };
    final textColor = switch (verdict) {
      CheckVerdict.smart => DgColors.pineGreen,
      CheckVerdict.letItRipen => DgColors.copper,
      CheckVerdict.leakage => DgColors.brick,
    };
    final questions = CheckQuestions.forType(wish?.type ?? WishType.want);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [BackIconButton(onPressed: onBack)]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DgColors.white,
                    border: Border.all(color: color, width: 6),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CheckQuestions.formatScore(score),
                        style: DgType.display.copyWith(fontSize: 40, color: textColor),
                      ),
                      Text('von 5', style: DgType.meta.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(verdict.title, style: DgType.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                verdict.body,
                style: DgType.body.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (final q in questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(q.question, style: DgType.body.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        answers[q.id]?.label ?? '–',
                        style: DgType.label.copyWith(
                          color: switch (answers[q.id]) {
                            CheckAnswer.yes => DgColors.pineGreen,
                            CheckAnswer.partly => DgColors.copper,
                            CheckAnswer.no => DgColors.cocoa,
                            null => DgColors.cocoa,
                          },
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: FilledButton(
            onPressed: onFinish,
            child: Text(wish == null ? 'Fertig' : 'Ergebnis speichern'),
          ),
        ),
      ],
    );
  }
}
