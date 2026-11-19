import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/figure.dart';

/// Merkt sich, welche Figuren geübt wurden und wie gut es lief.
class ProgressStore extends ChangeNotifier {
  ProgressStore(this._prefs);

  static Future<ProgressStore> load() async => ProgressStore(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static String _doneKey(String id) => 'done.$id';
  static String _scoreKey(String id) => 'score.$id';
  static String _attemptsKey(String id) => 'attempts.$id';

  bool isDone(String figureId) => _prefs.getBool(_doneKey(figureId)) ?? false;
  int? bestScore(String figureId) => _prefs.getInt(_scoreKey(figureId));
  int attempts(String figureId) => _prefs.getInt(_attemptsKey(figureId)) ?? 0;

  int doneCount(Lesson lesson) => lesson.figures.where((f) => isDone(f.id)).length;

  bool isLessonDone(Lesson lesson) => doneCount(lesson) == lesson.figures.length;

  Future<void> recordAttempt(String figureId, int score) async {
    await _prefs.setInt(_attemptsKey(figureId), attempts(figureId) + 1);
    final best = bestScore(figureId);
    if (best == null || score > best) {
      await _prefs.setInt(_scoreKey(figureId), score);
    }
    if (score >= 50) {
      await _prefs.setBool(_doneKey(figureId), true);
    }
    notifyListeners();
  }

  Future<void> markDone(String figureId) async {
    await _prefs.setBool(_doneKey(figureId), true);
    notifyListeners();
  }

  Future<void> reset() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('done.') || k.startsWith('score.') || k.startsWith('attempts.'));
    for (final k in keys.toList()) {
      await _prefs.remove(k);
    }
    notifyListeners();
  }
}

/// Stellt den Fortschritt im Widget-Baum bereit.
class ProgressScope extends InheritedNotifier<ProgressStore> {
  const ProgressScope({super.key, required ProgressStore store, required super.child}) : super(notifier: store);

  static ProgressStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope fehlt im Widget-Baum');
    return scope!.notifier!;
  }
}
