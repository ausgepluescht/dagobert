import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/dg_icons.dart';
import '../profile/income_sheet.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(onboardingDone: true));
  }

  Future<void> _allowNotifications() async {
    final ok = await ref.read(notificationServiceProvider).requestPermission();
    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(notificationsEnabled: ok));
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == _page ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: i == _page ? DgColors.orange : DgColors.sand,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: const Text('Überspringen')),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _IdeaPage(onNext: _next),
                  _IncomePage(onNext: _next),
                  _NotificationsPage(onAllow: _allowNotifications, onLater: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaPage extends StatelessWidget {
  const _IdeaPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DgColors.warmWhite,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: DgColors.sand),
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset('assets/icon/icon_full.png'),
          ),
        ),
        const SizedBox(height: 28),
        const Text('Erst merken,\ndann entscheiden.', style: DgType.h1, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Text(
          'Die meisten von uns sind nicht schlecht im Geldverdienen. Wir sind schlecht im Ausgeben. '
          'Dagobert ist der kühle Kopf zwischen "will ich" und "gekauft".',
          style: DgType.body.copyWith(color: DgColors.cocoa),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        const _Bullet(icon: DgIcons.add, text: 'Wunsch merken statt sofort kaufen'),
        const _Bullet(icon: DgIcons.clock, text: 'Dagobert erinnert dich, wenn der Kopf kühl ist'),
        const _Bullet(icon: DgIcons.check, text: 'Fünf Fragen aus der Glücksforschung'),
        const _Bullet(icon: DgIcons.moneyBag, text: 'Jeder Verzicht landet sichtbar im Tresor'),
        const SizedBox(height: 28),
        FilledButton(onPressed: onNext, child: const Text('Los geht\'s')),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: DgColors.goldDust, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: DgColors.espresso),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: DgType.body.copyWith(fontSize: 15, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _IncomePage extends StatelessWidget {
  const _IncomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 32, 4, 24),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Was kostet dich ein Preis\nin Lebenszeit?', style: DgType.h1),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(DgIcons.lock, size: 16, color: DgColors.cocoa),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Optional. Bleibt auf deinem Handy, wird nirgends hochgeladen.',
                  style: DgType.meta,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        IncomeSheet(embedded: true, onSaved: onNext),
        Center(child: TextButton(onPressed: onNext, child: const Text('Später im Profil'))),
      ],
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({required this.onAllow, required this.onLater});
  final VoidCallback onAllow;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: DgColors.heroGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: DgShadow.orangeGlow,
            ),
            child: const Icon(DgIcons.bell, size: 48, color: DgColors.white),
          ),
        ),
        const SizedBox(height: 28),
        const Text('Dagobert meldet sich,\nwenn es Zeit ist.', style: DgType.h1, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Text(
          'Du merkst dir einen Wunsch und wählst, wann du erinnert werden willst: in 24 Stunden, 3 Tagen, einer Woche, zwei Wochen oder einem Monat. '
          'Dann fragt Dagobert einmal nach. Nicht öfter. Und nur tagsüber.',
          style: DgType.body.copyWith(color: DgColors.cocoa),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        FilledButton(onPressed: onAllow, child: const Text('Benachrichtigungen erlauben')),
        TextButton(onPressed: onLater, child: const Text('Vielleicht später')),
      ],
    );
  }
}
