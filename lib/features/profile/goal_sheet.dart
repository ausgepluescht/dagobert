import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/money_format.dart';
import '../../state/providers.dart';
import '../../theme/typography.dart';

Future<void> showGoalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _GoalSheet(),
  );
}

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet();

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _title = TextEditingController(text: s.savingsGoalTitle ?? '');
    _amount = TextEditingController(
      text: s.savingsGoalCents == null ? '' : MoneyFormat.plain(s.savingsGoalCents!),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cents = MoneyFormat.parseCents(_amount.text);
    final title = _title.text.trim();
    await ref.read(settingsProvider.notifier).update(
      (s) => s.copyWith(
        savingsGoalTitle: title.isEmpty ? null : title,
        savingsGoalCents: cents,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    await ref.read(settingsProvider.notifier).update(
      (s) => s.copyWith(savingsGoalTitle: null, savingsGoalCents: null),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.viewPaddingOf(context).bottom;
    final hasGoal = ref.watch(settingsProvider).hasGoal;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wofür sparst du?', style: DgType.h1),
          const SizedBox(height: 4),
          Text(
            'Am besten ein Erlebnis. Geschichten gewinnen, Dinge verlieren.',
            style: DgType.meta,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'z. B. Island-Reise, Konzertwochenende'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: DgType.bodyStrong.copyWith(fontSize: 20, fontFeatures: DgType.tabular),
            decoration: const InputDecoration(hintText: '2.000', suffixText: '€'),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: _save, child: const Text('Sparziel speichern')),
          if (hasGoal)
            TextButton(onPressed: _clear, child: const Text('Sparziel entfernen')),
        ],
      ),
    );
  }
}
