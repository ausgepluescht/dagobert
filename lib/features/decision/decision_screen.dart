import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/wish_item.dart';
import '../../services/check_questions.dart';
import '../../services/money_format.dart';
import '../../services/time_format.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../../widgets/wish_card.dart';
import '../check/check_flow_screen.dart';
import 'decision_actions.dart';

enum DecisionAutoAction { skip, snooze }

/// Entscheidungsmoment: Detail eines Wunschs mit Thermometer und Aktionen.
class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key, required this.wishId, this.autoAction});

  final String wishId;
  final DecisionAutoAction? autoAction;

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends ConsumerState<DecisionScreen> {
  final _skipKey = GlobalKey();
  bool _autoHandled = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runAuto());
    }
  }

  Future<void> _runAuto() async {
    if (_autoHandled) return;
    _autoHandled = true;
    final item = ref.read(wishesProvider).where((w) => w.id == widget.wishId).firstOrNull;
    if (item == null || !item.isWaiting) return;
    switch (widget.autoAction!) {
      case DecisionAutoAction.skip:
        await DecisionActions.skip(context, ref, item, origin: _buttonCenter());
        if (mounted) Navigator.of(context).maybePop();
      case DecisionAutoAction.snooze:
        final done = await DecisionActions.snooze(context, ref, item);
        if (done && mounted) Navigator.of(context).maybePop();
    }
  }

  Offset? _buttonCenter() {
    final box = _skipKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _editPrice(WishItem item) async {
    final controller = TextEditingController(text: MoneyFormat.plain(item.priceCents));
    final cents = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Preis aktualisieren'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: '€'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(MoneyFormat.parseCents(controller.text)),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (cents != null && cents != item.priceCents) {
      await ref.read(wishesProvider.notifier).updatePrice(item.id, cents);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(
      wishesProvider.select((list) => list.where((w) => w.id == widget.wishId).firstOrNull),
    );
    if (item == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const EmptyState(
          icon: DgIcons.sparkle,
          title: 'Dieser Wunsch ist weg.',
          body: 'Vielleicht hast du ihn gerade gelöscht. Kein Drama.',
        ),
      );
    }
    final rate = ref.watch(hourlyRateProvider);
    final now = clock.now();
    final ripe = item.isRipe(now);
    final hours = WorkHours.hoursFor(item.priceCents, rate);
    final waited = item.waitingSince(now);
    final host = linkHost(item.url);
    final hasCheck = item.checkAnswers.isNotEmpty;
    final verdict = CheckQuestions.verdict(item.checkScore);
    final decided = !item.isWaiting;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const BackIconButton(),
                  Expanded(
                    child: Center(
                      child: decided
                          ? MetaChip(
                              text: item.status.label.toUpperCase(),
                              background: item.status == WishStatus.skipped ? DgColors.greenTint : DgColors.goldDust,
                              color: item.status == WishStatus.skipped ? DgColors.pineGreen : DgColors.espresso,
                              bordered: false,
                            )
                          : ripe
                          ? const MetaChip(
                              text: 'REIF ZUR ENTSCHEIDUNG',
                              background: DgColors.gold,
                              color: DgColors.espresso,
                              bordered: false,
                            )
                          : MetaChip(
                              text: 'REIFT NOCH · ${TimeFormat.until(item.remindAt?.difference(now) ?? Duration.zero).toUpperCase()}',
                            ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Mehr',
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (v) async {
                      switch (v) {
                        case 'price':
                          await _editPrice(item);
                        case 'check':
                          if (!context.mounted) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => CheckFlowScreen(wishId: item.id)),
                          );
                        case 'restore':
                          await ref.read(wishesProvider.notifier).restore(item.id);
                        case 'delete':
                          if (!context.mounted) return;
                          final deleted = await DecisionActions.confirmDelete(context, ref, item);
                          if (deleted && context.mounted) Navigator.of(context).maybePop();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'price', child: Text('Preis aktualisieren')),
                      PopupMenuItem(value: 'check', child: Text(hasCheck ? 'Check wiederholen' : '5-Fragen-Check')),
                      if (decided) const PopupMenuItem(value: 'restore', child: Text('Zurück auf die Merkliste')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Löschen (Fehleintrag)', style: TextStyle(color: DgColors.brick)),
                      ),
                    ],
                    child: const BackIconButton(icon: DgIcons.more, onPressed: null),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  Text(item.title, style: DgType.h1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      TypeChip(type: item.type),
                      if (item.category != null) MetaChip(text: item.category!.label),
                      if (item.trigger != null) MetaChip(text: 'Auslöser: ${item.trigger!.label}'),
                      if (host != null)
                        GestureDetector(
                          onTap: () => _openLink(item.url!),
                          child: MetaChip(text: 'Produkt öffnen · $host', icon: DgIcons.openLink, color: DgColors.copper),
                        ),
                    ],
                  ),
                  if (item.note != null) ...[
                    const SizedBox(height: 10),
                    Text(item.note!, style: DgType.body.copyWith(fontSize: 14, color: DgColors.cocoa)),
                  ],
                  const SizedBox(height: 18),
                  SurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(child: _Fact(value: MoneyFormat.euro(item.priceCents), label: 'Preis', color: DgColors.copper)),
                        Expanded(child: _Fact(value: hours == null ? '–' : WorkHours.format(hours).replaceFirst('≈ ', ''), label: 'Arbeit netto')),
                        Expanded(child: _Fact(value: TimeFormat.compact(waited), label: 'gewartet')),
                      ],
                    ),
                  ),
                  if (item.priceHistory.length > 1) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Preis beim Merken: ${MoneyFormat.euro(item.priceHistory.first.cents)} '
                      '${item.priceCents < item.priceHistory.first.cents ? '· jetzt ${MoneyFormat.euro(item.priceHistory.first.cents - item.priceCents)} günstiger' : item.priceCents > item.priceHistory.first.cents ? '· jetzt teurer' : ''}',
                      style: DgType.meta.copyWith(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (!decided)
                    _DesireCard(
                      item: item,
                      onChanged: (v) => ref.read(wishesProvider.notifier).setDesireAtDecision(item.id, v),
                    ),
                  if (!decided) const SizedBox(height: 14),
                  SurfaceCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => CheckFlowScreen(wishId: item.id)),
                    ),
                    child: Row(
                      children: [
                        const Icon(DgIcons.check, color: DgColors.copper),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('5-Fragen-Check', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                hasCheck
                                    ? '★ ${CheckQuestions.formatScore(item.checkScore)} / 5 · ${verdict.title}'
                                    : 'Noch nicht gemacht. 30 Sekunden.',
                                style: DgType.meta.copyWith(
                                  fontSize: 12,
                                  color: hasCheck && verdict == CheckVerdict.smart ? DgColors.pineGreen : DgColors.cocoa,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(DgIcons.chevron, color: DgColors.copper),
                      ],
                    ),
                  ),
                  if (decided) ...[
                    const SizedBox(height: 14),
                    SurfaceCard(
                      child: Text(
                        item.status == WishStatus.skipped
                            ? 'Verzichtet am ${DateFormat('d. MMMM yyyy', 'de_DE').format(item.decidedAt!)}. '
                                  '${MoneyFormat.euro(item.priceCents)} liegen im Tresor.'
                            : 'Gekauft am ${DateFormat('d. MMMM yyyy', 'de_DE').format(item.decidedAt!)}'
                                  '${item.decidedPriceCents != null ? ' für ${MoneyFormat.euro(item.decidedPriceCents!)}' : ''}.'
                                  '${item.worthItAnswer == null ? ' In 30 Tagen fragt Dagobert, ob es das wert war.' : item.worthItAnswer! ? ' Dein Urteil: Es war es wert.' : ' Dein Urteil: Eher nicht.'}',
                        style: DgType.body.copyWith(fontSize: 14),
                      ),
                    ),
                    if (item.status == WishStatus.bought && item.worthItAnswer == null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => ref.read(wishesProvider.notifier).answerWorthIt(item.id, false),
                              child: const Text('Eher nicht wert'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => ref.read(wishesProvider.notifier).answerWorthIt(item.id, true),
                              child: const Text('War es wert'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (!decided)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    FilledButton.icon(
                      key: _skipKey,
                      style: FilledButton.styleFrom(
                        backgroundColor: DgColors.savingsGreen,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await DecisionActions.skip(context, ref, item, origin: _buttonCenter());
                        nav.maybePop();
                      },
                      icon: const Icon(DgIcons.moneyBag, size: 22),
                      label: Text('Verzichten · ${MoneyFormat.euro(item.priceCents)} in den Tresor'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: DgColors.espresso),
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              final done = await DecisionActions.snooze(context, ref, item);
                              if (done) nav.maybePop();
                            },
                            icon: const Icon(DgIcons.clock, size: 18),
                            label: const Text('Weiter reifen'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(backgroundColor: DgColors.white),
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              await DecisionActions.buy(context, ref, item);
                              final after = ref.read(wishesProvider).where((w) => w.id == item.id).firstOrNull;
                              if (after != null && after.status == WishStatus.bought) nav.maybePop();
                            },
                            icon: const Icon(DgIcons.bought, size: 18),
                            label: const Text('Gekauft'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label, this.color = DgColors.espresso});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: DgType.bodyStrong.copyWith(fontSize: 21, fontWeight: FontWeight.w800, color: color, fontFeatures: DgType.tabular),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(label, style: DgType.meta.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DesireCard extends StatelessWidget {
  const _DesireCard({required this.item, required this.onChanged});
  final WishItem item;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final before = item.desireAtCreate;
    final today = item.desireAtDecision;
    String? insight;
    IconData? icon;
    if (before != null && today != null) {
      final waited = TimeFormat.since(item.waitingSince()).replaceFirst('seit ', 'vor ');
      if (today < before) {
        insight = '${waited[0].toUpperCase()}${waited.substring(1)}: $before von 5. Heute: $today von 5. Der Wunsch kühlt ab.';
        icon = DgIcons.trendDown;
      } else if (today > before) {
        insight = '${waited[0].toUpperCase()}${waited.substring(1)}: $before von 5. Heute: $today von 5. Der Wunsch ist gewachsen. Das spricht für ihn.';
        icon = DgIcons.trendUp;
      } else {
        insight = '${waited[0].toUpperCase()}${waited.substring(1)} wie heute: $today von 5. Stabil. Ein echtes Signal.';
        icon = Icons.horizontal_rule_rounded;
      }
    }
    return SurfaceCard(
      color: DgColors.white,
      shadow: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wie sehr willst du es heute?', style: DgType.bodyStrong),
          const SizedBox(height: 2),
          Text('Ehrlich, ohne nachzudenken.', style: DgType.meta),
          const SizedBox(height: 14),
          DesireSlider(value: today, onChanged: onChanged),
          if (insight != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: DgColors.goldDust, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: DgColors.espresso),
                  const SizedBox(width: 10),
                  Expanded(child: Text(insight, style: DgType.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
