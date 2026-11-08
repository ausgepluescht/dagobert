import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'coin_burst_overlay.dart';
import 'dg_icons.dart';

enum ShellTab { home, wishlist, check, profile }

/// Bottom-Navigation mit erhöhtem Geldsack in der Mitte.
class MoneyBagNav extends StatelessWidget {
  const MoneyBagNav({
    super.key,
    required this.current,
    required this.onTab,
    required this.onVault,
    required this.coinController,
  });

  final ShellTab current;
  final ValueChanged<ShellTab> onTab;
  final VoidCallback onVault;
  final CoinBurstController coinController;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: DgColors.white,
        border: Border(top: BorderSide(color: DgColors.sand)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset, top: 8, left: 8, right: 8),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            _NavItem(
              icon: DgIcons.home,
              label: 'Start',
              selected: current == ShellTab.home,
              onTap: () => onTab(ShellTab.home),
            ),
            _NavItem(
              icon: DgIcons.list,
              label: 'Merkliste',
              selected: current == ShellTab.wishlist,
              onTap: () => onTab(ShellTab.wishlist),
            ),
            Expanded(
              child: _MoneyBagButton(
                controller: coinController,
                onTap: onVault,
              ),
            ),
            _NavItem(
              icon: DgIcons.check,
              label: 'Check',
              selected: current == ShellTab.check,
              onTap: () => onTab(ShellTab.check),
            ),
            _NavItem(
              icon: DgIcons.profile,
              label: 'Profil',
              selected: current == ShellTab.profile,
              onTap: () => onTab(ShellTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? DgColors.copper : DgColors.cocoa;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: DgType.label.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyBagButton extends StatefulWidget {
  const _MoneyBagButton({required this.controller, required this.onTap});

  final CoinBurstController controller;
  final VoidCallback onTap;

  @override
  State<_MoneyBagButton> createState() => _MoneyBagButtonState();
}

class _MoneyBagButtonState extends State<_MoneyBagButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  int _lastWiggle = 0;

  @override
  void initState() {
    super.initState();
    _lastWiggle = widget.controller.bagWiggle;
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _wiggle.dispose();
    super.dispose();
  }

  void _onController() {
    if (widget.controller.bagWiggle != _lastWiggle) {
      _lastWiggle = widget.controller.bagWiggle;
      if (!MediaQuery.of(context).disableAnimations) {
        _wiggle.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tresor öffnen',
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -22),
              child: AnimatedBuilder(
                animation: _wiggle,
                builder: (context, child) {
                  final t = _wiggle.value;
                  final angle = math.sin(t * math.pi * 4) * (1 - t) * 0.18;
                  final scale = 1 + math.sin(t * math.pi) * 0.12;
                  return Transform.rotate(
                    angle: angle,
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Container(
                  key: widget.controller.moneyBagKey,
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: DgColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: DgColors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66D9A425),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    DgIcons.moneyBag,
                    color: DgColors.espresso,
                    size: 28,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Text(
                'Tresor',
                style: DgType.label.copyWith(color: DgColors.cocoa),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
