import 'package:flipo/app.dart';
import 'package:flipo/data/lessons.dart';
import 'package:flipo/data/progress_store.dart';
import 'package:flipo/screens/practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Startseite zeigt alle Lektionen, Lektion öffnet Übung', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final store = await ProgressStore.load();
    await tester.pumpWidget(FlipoApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Flipo'), findsOneWidget);
    expect(find.text(allLessons.first.title), findsOneWidget);

    await tester.tap(find.text(allLessons.first.title));
    await tester.pumpAndSettle();
    expect(find.text('Lektion starten'), findsOneWidget);

    await tester.tap(find.text('Lektion starten'));
    await tester.pumpAndSettle();
    expect(find.byType(PracticeScreen), findsOneWidget);
    expect(find.textContaining('Schritt 1 von'), findsOneWidget);

    // Einen Strich ziehen und den Schritt wechseln.
    final canvas = find.byType(CustomPaint).first;
    final center = tester.getCenter(canvas);
    await tester.dragFrom(center - const Offset(80, 0), const Offset(160, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Nächster Schritt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Schritt 2 von'), findsOneWidget);
  });

  testWidgets('Fertig speichert den Versuch', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final store = await ProgressStore.load();
    final figure = findFigure('basics.line')!;
    await tester.pumpWidget(
      ProgressScope(
        store: store,
        child: MaterialApp(home: PracticeScreen(figure: figure, lesson: allLessons.first)),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < figure.steps.length - 1; i++) {
      await tester.tap(find.byTooltip('Nächster Schritt'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();

    expect(store.attempts(figure.id), 1);
    expect(find.text('Noch einmal'), findsOneWidget);
  });
}
