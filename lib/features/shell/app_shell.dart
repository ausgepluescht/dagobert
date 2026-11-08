import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/local_notification_service.dart';
import '../../services/notification_service.dart';
import '../../state/providers.dart';
import '../../widgets/coin_burst_overlay.dart';
import '../../widgets/money_bag_nav.dart';
import '../add_wish/add_wish_sheet.dart';
import '../check/check_flow_screen.dart';
import '../decision/decision_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../vault/vault_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'quick_actions_setup.dart';
import 'share_intake.dart';

final coinBurstProvider = Provider<CoinBurstController>(
  (ref) => CoinBurstController(),
);

final shellTabProvider = NotifierProvider<ShellTabNotifier, ShellTab>(
  ShellTabNotifier.new,
);

class ShellTabNotifier extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.home;

  void set(ShellTab tab) => state = tab;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<NotificationTap>? _tapSub;
  StreamSubscription<SharedText>? _shareSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final notifications = ref.read(notificationServiceProvider);
    await ref.read(wishesProvider.notifier).rescheduleAll();
    _tapSub = notifications.taps.listen(_handleTap);
    final initial = await notifications.initialPayload();
    if (initial != null) {
      final parts = initial.split('|');
      final tap = NotificationTap.parse(
        parts.first,
        parts.length > 1 ? parts[1] : null,
      );
      if (tap != null) _handleTap(tap);
    }
    final share = ShareIntake();
    _shareSub = share.stream.listen(_handleShare);
    final initialShare = await share.initial();
    if (initialShare != null) _handleShare(initialShare);
    await QuickActionsSetup.init((type) {
      if (type == QuickActionsSetup.addWish) {
        final ctx = _navKey.currentContext;
        if (ctx != null) showAddWishSheet(ctx);
      }
    });
  }

  @override
  void dispose() {
    _tapSub?.cancel();
    _shareSub?.cancel();
    super.dispose();
  }

  void _handleTap(NotificationTap tap) {
    final item = ref
        .read(wishesProvider)
        .where((w) => w.id == tap.wishId)
        .firstOrNull;
    if (item == null) return;
    final nav = _navKey.currentState;
    if (nav == null) return;
    nav.popUntil((r) => r.isFirst);
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => DecisionScreen(
          wishId: item.id,
          autoAction: tap.action == LocalNotificationService.actionSkip
              ? DecisionAutoAction.skip
              : tap.action == LocalNotificationService.actionSnooze
              ? DecisionAutoAction.snooze
              : null,
        ),
      ),
    );
  }

  void _handleShare(SharedText shared) {
    final ctx = _navKey.currentContext;
    if (ctx == null) return;
    showAddWishSheet(ctx, initialTitle: shared.title, initialUrl: shared.url);
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinBurstProvider);
    return CoinBurstOverlay(
      controller: coins,
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const _ShellHome(),
        ),
      ),
    );
  }
}

class _ShellHome extends ConsumerWidget {
  const _ShellHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellTabProvider);
    final coins = ref.watch(coinBurstProvider);
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: tab.index,
        children: const [
          HomeScreen(),
          WishlistScreen(),
          CheckFlowScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: (tab == ShellTab.home || tab == ShellTab.wishlist)
          ? FloatingActionButton(
              heroTag: 'add-wish',
              tooltip: 'Wunsch merken',
              onPressed: () => showAddWishSheet(context),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: MoneyBagNav(
        current: tab,
        onTab: (t) => ref.read(shellTabProvider.notifier).set(t),
        onVault: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const VaultScreen()),
        ),
        coinController: coins,
      ),
    );
  }
}
