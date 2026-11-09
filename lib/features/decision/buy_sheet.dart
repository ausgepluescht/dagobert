import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/wish_item.dart';
import '../../services/money_format.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';

class BuyResult {
  const BuyResult({this.paidCents, this.experienceDate});
  final int? paidCents;
  final DateTime? experienceDate;
}

Future<BuyResult?> showBuySheet(BuildContext context, WishItem item) {
  return showModalBottomSheet<BuyResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BuySheet(item: item),
  );
}

class _BuySheet extends StatefulWidget {
  const _BuySheet({required this.item});
  final WishItem item;

  @override
  State<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends State<_BuySheet> {
  late final _price = TextEditingController(
    text: MoneyFormat.plain(widget.item.priceCents),
  );
  DateTime? _date;
  bool _isExperience = false;

  @override
  void initState() {
    super.initState();
    _isExperience = widget.item.category?.isExperience ?? false;
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = clock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: 'Wann ist es so weit?',
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.viewPaddingOf(context).bottom;
    final paid = MoneyFormat.parseCents(_price.text);
    final cheaper = paid != null && paid < widget.item.priceCents;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gekauft', style: DgType.h1),
          const SizedBox(height: 4),
          Text(
            'Bewusst entschieden ist nie falsch. Zwei kurze Fragen, dann bist du durch.',
            style: DgType.meta,
          ),
          const SizedBox(height: 18),
          Text('Was hast du bezahlt?', style: DgType.meta.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: DgType.bodyStrong.copyWith(fontSize: 20, fontFeatures: DgType.tabular),
            decoration: const InputDecoration(suffixText: '€'),
            onChanged: (_) => setState(() {}),
          ),
          if (cheaper) ...[
            const SizedBox(height: 6),
            Text(
              'Günstiger als gemerkt: ${MoneyFormat.euro(widget.item.priceCents - paid)} weniger. Warten hat sich gelohnt.',
              style: DgType.meta.copyWith(color: DgColors.pineGreen, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 18),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _isExperience,
            onChanged: (v) => setState(() {
              _isExperience = v;
              if (!v) _date = null;
            }),
            title: Text('Ist das ein Erlebnis mit Datum?', style: DgType.bodyStrong.copyWith(fontSize: 15)),
            subtitle: Text('Dann zeigt Dagobert dir die Vorfreude an.', style: DgType.meta.copyWith(fontSize: 12)),
          ),
          if (_isExperience)
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(DgIcons.calendar, size: 18),
              label: Text(
                _date == null
                    ? 'Datum wählen'
                    : DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(_date!),
              ),
            ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              BuyResult(paidCents: paid, experienceDate: _isExperience ? _date : null),
            ),
            child: const Text('Als gekauft eintragen'),
          ),
        ],
      ),
    );
  }
}
