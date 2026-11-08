import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/money_format.dart';
import '../../services/work_hours.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';

Future<void> showIncomeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const IncomeSheet(),
  );
}

/// Netto pro Monat + Stunden pro Woche. Auch im Onboarding eingebettet.
class IncomeSheet extends ConsumerStatefulWidget {
  const IncomeSheet({super.key, this.embedded = false, this.onSaved});

  final bool embedded;
  final VoidCallback? onSaved;

  @override
  ConsumerState<IncomeSheet> createState() => _IncomeSheetState();
}

class _IncomeSheetState extends ConsumerState<IncomeSheet> {
  late final TextEditingController _net;
  late final TextEditingController _hours;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _net = TextEditingController(text: s.netMonthlyCents == null ? '' : MoneyFormat.plain(s.netMonthlyCents!));
    _hours = TextEditingController(
      text: s.hoursPerWeek == null
          ? ''
          : (s.hoursPerWeek == s.hoursPerWeek!.roundToDouble()
                ? s.hoursPerWeek!.toInt().toString()
                : s.hoursPerWeek.toString().replaceAll('.', ',')),
    );
  }

  @override
  void dispose() {
    _net.dispose();
    _hours.dispose();
    super.dispose();
  }

  int? get _netCents => MoneyFormat.parseCents(_net.text);
  double? get _hoursValue => double.tryParse(_hours.text.replaceAll(',', '.'));

  Future<void> _save() async {
    await ref.read(settingsProvider.notifier).update(
      (s) => s.copyWith(netMonthlyCents: _netCents, hoursPerWeek: _hoursValue),
    );
    if (!mounted) return;
    if (widget.embedded) {
      widget.onSaved?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rate = WorkHours.hourlyRateCents(netMonthlyCents: _netCents, hoursPerWeek: _hoursValue);
    final bottom = widget.embedded ? 0.0 : MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, (widget.embedded ? 0 : 20) + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.embedded) ...[
            const Text('Dein Einkommen', style: DgType.h1),
            const SizedBox(height: 4),
            Text('Bleibt auf deinem Handy. Dagobert rechnet damit Preise in Lebenszeit um.', style: DgType.meta),
            const SizedBox(height: 18),
          ],
          Text('Netto pro Monat', style: DgType.meta.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _net,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: DgType.bodyStrong.copyWith(fontSize: 22, fontWeight: FontWeight.w800, fontFeatures: DgType.tabular),
            decoration: const InputDecoration(hintText: '2.800', suffixText: '€'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Text('Arbeitsstunden pro Woche', style: DgType.meta.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _hours,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: DgType.bodyStrong.copyWith(fontSize: 22, fontWeight: FontWeight.w800, fontFeatures: DgType.tabular),
            decoration: const InputDecoration(hintText: '40', suffixText: 'Std'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: DgColors.goldDust, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(DgIcons.euro, size: 18, color: DgColors.espresso),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rate == null
                        ? 'Beide Felder ausfüllen, dann erscheint dein Netto-Stundenlohn.'
                        : 'Netto-Stundenlohn: ${MoneyFormat.euro(rate, forceCents: true)}. Ein Kaffee für 4 € kostet dich ${WorkHours.minutesFor(400, rate)} Minuten.',
                    style: DgType.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: _save, child: Text(widget.embedded ? 'Weiter' : 'Speichern')),
        ],
      ),
    );
  }
}
