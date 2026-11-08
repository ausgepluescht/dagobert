import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

class DagobertApp extends ConsumerWidget {
  const DagobertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(
      settingsProvider.select((s) => s.onboardingDone),
    );
    return MaterialApp(
      title: 'Dagobert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('de', 'DE'),
      supportedLocales: const [Locale('de', 'DE'), Locale('de')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: onboardingDone ? const AppShell() : const OnboardingScreen(),
    );
  }
}
