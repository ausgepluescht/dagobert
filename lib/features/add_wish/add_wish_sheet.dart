import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wish_item.dart';
import '../../services/money_format.dart';
import '../../services/reminder_policy.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import '../check/check_flow_screen.dart';

Future<void> showAddWishSheet(
  BuildContext context, {
  String? initialTitle,
  String? initialUrl,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddWishSheet(initialTitle: initialTitle, initialUrl: initialUrl),
  );
}

class AddWishSheet extends ConsumerStatefulWidget {
  const AddWishSheet({super.key, this.initialTitle, this.initialUrl});

  final String? initialTitle;
  final String? initialUrl;

  @override
  ConsumerState<AddWishSheet> createState() => _AddWishSheetState();
}

class _AddWishSheetState extends ConsumerState<AddWishSheet> {
  late final _title = TextEditingController(text: widget.initialTitle ?? '');
  final _price = TextEditingController();
  late final _url = TextEditingController(text: widget.initialUrl ?? '');
  final _note = TextEditingController();
  final _priceFocus = FocusNode();

  WishType _type = WishType.want;
  int? _desire;
  ReminderOption? _reminder;
  bool _reminderTouched = false;
  WishCategory? _category;
  WishTrigger? _trigger;
  bool _showMore = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null && (widget.initialTitle?.isNotEmpty ?? false)) {
      _showMore = false;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _url.dispose();
    _note.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  int? get _cents => MoneyFormat.parseCents(_price.text);

  double? _hours(int? rate) {
    final c = _cents;
    if (c == null) return null;
    return WorkHours.hoursFor(c, rate);
  }

  ReminderOption _suggested(int? rate) =>
      ReminderPolicy.suggest(type: _type, workHours: _hours(rate));

  Future<void> _pasteLink() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() => _url.text = text);
  }

  Future<void> _save({required bool runCheck}) async {
    final cents = _cents;
    final title = _title.text.trim();
    if (title.isEmpty || cents == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name und Preis genügen, aber beides bitte.')),
      );
      return;
    }
    setState(() => _saving = true);
    final rate = ref.read(hourlyRateProvider);
    final item = await ref
        .read(wishesProvider.notifier)
        .add(
          title: title,
          priceCents: cents,
          type: _type,
          reminder: _reminder ?? _suggested(rate),
          category: _category,
          trigger: _trigger,
          note: _note.text,
          url: _url.text,
          desire: _desire,
        );
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pop();
    if (runCheck) {
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => CheckFlowScreen(wishId: item.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gemerkt. Dagobert meldet sich ${(_reminder ?? _suggested(rate)).sentence} wieder.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rate = ref.watch(hourlyRateProvider);
    final hoursPerDay = ref.watch(hoursPerDayProvider);
    final hours = _hours(rate);
    final suggested = _suggested(rate);
    final effectiveReminder = _reminderTouched ? (_reminder ?? suggested) : suggested;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + safeBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Wunsch merken', style: DgType.h1)),
                BackIconButton(
                  icon: DgIcons.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Label('Was möchtest du dir merken?'),
            TextField(
              controller: _title,
              autofocus: widget.initialTitle == null || widget.initialTitle!.isEmpty,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _priceFocus.requestFocus(),
              style: DgType.bodyStrong.copyWith(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'z. B. Kopfhörer, Wochenendtrip, Sofa',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            _Label('Preis'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    focusNode: _priceFocus,
                    autofocus: widget.initialTitle != null && widget.initialTitle!.isNotEmpty,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: DgType.bodyStrong.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFeatures: DgType.tabular,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      suffixText: '€',
                      suffixStyle: TextStyle(
                        fontFamily: DgType.family,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: DgColors.cocoa,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hours == null ? '–' : WorkHours.format(hours),
                      style: DgType.amount.copyWith(fontSize: 18),
                    ),
                    Text(
                      rate == null
                          ? 'Einkommen im Profil'
                          : hours != null && hours / hoursPerDay >= 1
                          ? WorkDays.formatDays(hours / hoursPerDay)
                          : 'Arbeit netto',
                      style: DgType.meta.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Label('Link zum Produkt (optional)'),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              autocorrect: false,
              style: DgType.body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'https://…',
                prefixIcon: const Icon(DgIcons.link, color: DgColors.copper, size: 20),
                suffixIcon: TextButton(
                  onPressed: _pasteLink,
                  child: const Text('Einfügen'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Label('Brauchst du es oder willst du es?'),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<WishType>(
                segments: const [
                  ButtonSegment(value: WishType.need, label: Text('Brauche ich')),
                  ButtonSegment(value: WishType.want, label: Text('Will ich')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (!states.contains(WidgetState.selected)) return DgColors.white;
                    return _type == WishType.need ? DgColors.blueTint : DgColors.goldDust;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (!states.contains(WidgetState.selected)) return DgColors.cocoa;
                    return _type == WishType.need ? DgColors.blueText : DgColors.espresso;
                  }),
                  minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
                ),
              ),
            ),
            if (_type == WishType.need) ...[
              const SizedBox(height: 8),
              Text(
                'Bei echtem Bedarf geht es nicht um ob, sondern um wie. Der Timer bleibt kurz.',
                style: DgType.meta.copyWith(fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            _Label('Wie sehr willst du es gerade?'),
            DesireSlider(value: _desire, onChanged: (v) => setState(() => _desire = v)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: _Label('Erinnerung in')),
                if (!_reminderTouched)
                  Text(
                    hours == null
                        ? 'Vorschlag: ${suggested.label}'
                        : 'Vorschlag bei ${WorkHours.format(hours)}: ${suggested.label}',
                    style: DgType.meta.copyWith(fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in ReminderOption.values)
                  ChoiceChip(
                    label: Text(o.label),
                    selected: effectiveReminder == o,
                    onSelected: (_) => setState(() {
                      _reminder = o;
                      _reminderTouched = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(),
            TextButton(
              onPressed: () => setState(() => _showMore = !_showMore),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                alignment: Alignment.centerLeft,
                minimumSize: const Size.fromHeight(40),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Mehr Details (Kategorie, Notiz, Auslöser)',
                        style: TextStyle(fontSize: 14)),
                  ),
                  Icon(_showMore ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                ],
              ),
            ),
            if (_showMore) ...[
              _Label('Kategorie'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in WishCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (sel) => setState(() => _category = sel ? c : null),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _Label('Was hat den Wunsch ausgelöst?'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in WishTrigger.values)
                    ChoiceChip(
                      label: Text(t.label),
                      selected: _trigger == t,
                      onSelected: (sel) => setState(() => _trigger = sel ? t : null),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _Label('Notiz'),
              TextField(
                controller: _note,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Warum gerade jetzt? Welche Variante?'),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => _save(runCheck: false),
                    child: const Text('Speichern'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _save(runCheck: true),
                    icon: const Text('Speichern & Check'),
                    label: const Icon(Icons.arrow_forward_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: DgType.meta.copyWith(fontWeight: FontWeight.w600)),
  );
}
