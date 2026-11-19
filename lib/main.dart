import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/progress_store.dart';
import 'theme/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Palette.paper,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final store = await ProgressStore.load();
  runApp(FlipoApp(store: store));
}
