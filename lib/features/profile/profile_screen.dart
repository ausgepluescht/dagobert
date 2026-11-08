import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/backup.dart';
import '../../services/money_format.dart';
import '../../state/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';
import '../../widgets/dg_widgets.dart';
import 'goal_sheet.dart';
import 'income_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final json = Backup.encode(
      wishes: ref.read(wishesProvider),
      settings: ref.read(settingsProvider),
    );
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(clock.now());
    try {
      if (kIsWeb) {
        await SharePlus.instance.share(ShareParams(text: json, subject: 'Dagobert-Sicherung $stamp'));
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/dagobert-$stamp.json');
        await file.writeAsString(json);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path, mimeType: 'application/json')], subject: 'Dagobert-Sicherung $stamp'),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export fehlgeschlagen: $e')));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final file = await FilePicker.pickFile(type: FileType.any, dialogTitle: 'Dagobert-Sicherung wählen');
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final data = Backup.decode(utf8.decode(bytes));
      if (!context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Sicherung einspielen?'),
          content: Text(
            '${data.wishes.length} Einträge werden übernommen. Gleiche Einträge werden überschrieben, andere bleiben erhalten.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Abbrechen')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Einspielen')),
          ],
        ),
      );
      if (ok != true) return;
      await ref.read(wishesProvider.notifier).importAll(data.wishes);
      if (data.settings != null) {
        final s = data.settings!;
        await ref.read(settingsProvider.notifier).update(
          (cur) => s.copyWith(onboardingDone: true, notificationsEnabled: cur.notificationsEnabled),
        );
      }
      messenger.showSnackBar(SnackBar(content: Text('${data.wishes.length} Einträge eingespielt.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import fehlgeschlagen: $e')));
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Alles zurücksetzen?'),
        content: const Text('Merkliste, Tresor und Einstellungen werden gelöscht. Das lässt sich nicht rückgängig machen. Vorher exportieren?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Abbrechen')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: DgColors.brick),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(wishesProvider.notifier).deleteAll();
    await ref.read(settingsProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final rate = ref.watch(hourlyRateProvider);
    final notifications = ref.read(notificationServiceProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          const Text('Profil', style: DgType.h1),
          const SizedBox(height: 4),
          Text('Alles bleibt auf deinem Handy. Kein Konto, kein Server.', style: DgType.meta),
          const SizedBox(height: 20),
          _Section('Dein Einkommen'),
          SurfaceCard(
            onTap: () => showIncomeSheet(context),
            child: Row(
              children: [
                const Icon(DgIcons.work, color: DgColors.copper),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.hasIncome
                            ? '${MoneyFormat.euro(settings.netMonthlyCents!)} netto · ${_fmtHours(settings.hoursPerWeek!)} Std/Woche'
                            : 'Netto-Einkommen eintragen',
                        style: DgType.bodyStrong.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rate == null
                            ? 'Dann zeigt Dagobert jeden Preis in Arbeitsstunden.'
                            : 'Netto-Stundenlohn: ${MoneyFormat.euro(rate, forceCents: true)}',
                        style: DgType.meta.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(DgIcons.chevron, color: DgColors.copper),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            onTap: () => showGoalSheet(context),
            child: Row(
              children: [
                const Icon(DgIcons.goal, color: DgColors.copper),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.hasGoal ? 'Sparziel: ${settings.savingsGoalTitle}' : 'Sparziel setzen',
                        style: DgType.bodyStrong.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.hasGoal ? MoneyFormat.euro(settings.savingsGoalCents!) : 'Wofür sparst du? Am besten ein Erlebnis.',
                        style: DgType.meta.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(DgIcons.chevron, color: DgColors.copper),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Section('Erinnerungen'),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.notificationsEnabled,
                  onChanged: (v) async {
                    if (v) {
                      final ok = await notifications.requestPermission();
                      if (!ok) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Android hat die Berechtigung abgelehnt. In den Systemeinstellungen lässt sie sich erlauben.')),
                          );
                        }
                        return;
                      }
                    }
                    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(notificationsEnabled: v));
                    if (v) {
                      await ref.read(wishesProvider.notifier).rescheduleAll();
                    } else {
                      await notifications.cancelAll();
                    }
                  },
                  title: Text('Benachrichtigungen', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                  subtitle: Text('Dagobert meldet sich, wenn ein Wunsch reif ist.', style: DgType.meta.copyWith(fontSize: 12)),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(DgIcons.clock),
                  title: Text('Zeitfenster', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                  subtitle: Text(
                    '${settings.reminderWindowStart.format(context)} bis ${settings.reminderWindowEnd.format(context)} Uhr',
                    style: DgType.meta.copyWith(fontSize: 12),
                  ),
                  trailing: const Icon(DgIcons.chevron, color: DgColors.copper),
                  onTap: () => _editWindow(context, ref),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(DgIcons.bell),
                  title: Text('Testbenachrichtigung', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                  subtitle: Text('Prüft, ob alles ankommt.', style: DgType.meta.copyWith(fontSize: 12)),
                  onTap: () async {
                    final ok = await notifications.requestPermission();
                    if (ok) await notifications.showTest();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Section('Daten'),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(DgIcons.upload),
                  title: Text('Sicherung exportieren', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                  subtitle: Text('JSON-Datei teilen oder speichern.', style: DgType.meta.copyWith(fontSize: 12)),
                  onTap: () => _export(context, ref),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(DgIcons.download),
                  title: Text('Sicherung einspielen', style: DgType.bodyStrong.copyWith(fontSize: 15)),
                  subtitle: Text('Aus einer Dagobert-JSON-Datei.', style: DgType.meta.copyWith(fontSize: 12)),
                  onTap: () => _import(context, ref),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(DgIcons.trash, color: DgColors.brick),
                  title: Text('Alles zurücksetzen', style: DgType.bodyStrong.copyWith(fontSize: 15, color: DgColors.brick)),
                  onTap: () => _reset(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Section('Über'),
          SurfaceCard(
            child: Text(
              'Dagobert basiert auf "Happy Money" von Elizabeth Dunn und Michael Norton: Nicht wie viel du ausgibst entscheidet über dein Glück, sondern wie. '
              'Die fünf Fragen helfen, Geld in Zeit, Erlebnisse, Nähe, Treats und Vorfreude zu verwandeln.',
              style: DgType.body.copyWith(fontSize: 13, color: DgColors.cocoa),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editWindow(BuildContext context, WidgetRef ref) async {
    final s = ref.read(settingsProvider);
    final start = await showTimePicker(
      context: context,
      initialTime: s.reminderWindowStart,
      helpText: 'Frühestens erinnern ab',
    );
    if (start == null || !context.mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: s.reminderWindowEnd,
      helpText: 'Spätestens erinnern bis',
    );
    if (end == null) return;
    await ref.read(settingsProvider.notifier).update(
      (cur) => cur.copyWith(reminderWindowStart: start, reminderWindowEnd: end),
    );
    await ref.read(wishesProvider.notifier).rescheduleAll();
  }

  static String _fmtHours(double h) =>
      h == h.roundToDouble() ? h.toInt().toString() : h.toString().replaceAll('.', ',');
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title.toUpperCase(),
      style: DgType.label.copyWith(color: DgColors.copper, fontSize: 12, letterSpacing: 0.6),
    ),
  );
}
