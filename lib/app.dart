import 'package:flutter/material.dart';

import 'data/progress_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class FlipoApp extends StatelessWidget {
  const FlipoApp({super.key, required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      store: store,
      child: MaterialApp(
        title: 'Flipo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }
}
