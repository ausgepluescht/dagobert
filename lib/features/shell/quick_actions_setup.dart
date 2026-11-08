import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

/// Long-Press auf das App-Icon: "Wunsch merken".
class QuickActionsSetup {
  static const addWish = 'add_wish';

  static Future<void> init(void Function(String type) onAction) async {
    if (kIsWeb) return;
    try {
      const actions = QuickActions();
      await actions.initialize(onAction);
      await actions.setShortcutItems(const [
        ShortcutItem(
          type: addWish,
          localizedTitle: 'Wunsch merken',
          icon: 'ic_stat_dagobert',
        ),
      ]);
    } catch (_) {
      // Ohne Shortcut läuft die App genauso.
    }
  }
}
