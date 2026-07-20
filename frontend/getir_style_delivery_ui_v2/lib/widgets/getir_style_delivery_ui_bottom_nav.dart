import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../core/theme/pages/navigation_theme.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';

/// Curved bottom bar with animated floating active tab.
///
/// [CurvedNavigationBar] animates on tap internally. If the parent also passes
/// an updated [currentIndex] after async work (e.g. tab fade), the package
/// runs a second animation — the "icon bounce". We keep a local bar index and
/// only sync from the parent when navigation changes externally.
class GetirStyleDeliveryUiBottomNav extends StatefulWidget {
  const GetirStyleDeliveryUiBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GetirStyleDeliveryUiNavItem> items;

  @override
  State<GetirStyleDeliveryUiBottomNav> createState() => _GetirStyleDeliveryUiBottomNavState();
}

class _GetirStyleDeliveryUiBottomNavState extends State<GetirStyleDeliveryUiBottomNav> {
  final _navKey = GlobalKey<CurvedNavigationBarState>();
  late final int _fixedIndex;
  late int _barIndex;

  @override
  void initState() {
    super.initState();
    _fixedIndex = widget.currentIndex;
    _barIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(GetirStyleDeliveryUiBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.currentIndex;
    if (external != oldWidget.currentIndex && external != _barIndex) {
      _barIndex = external;
      _navKey.currentState?.setPage(_barIndex);
    }
  }

  void _onBarTap(int index) {
    // Track locally without setState — the bar already animated on tap.
    _barIndex = index;
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: CurvedNavigationBar(
        key: _navKey,
        index: _fixedIndex,
        height: NavigationTheme.barHeight,
        backgroundColor: Colors.transparent,
        color: NavigationTheme.barBackground,
        buttonBackgroundColor: GetirStyleDeliveryUiColors.primaryContainer,
        animationDuration: const Duration(milliseconds: 600),
        animationCurve: Curves.easeInOut,
        onTap: _onBarTap,
        items: [
          for (final item in widget.items)
            Icon(
              item.icon,
              size: 28,
              color: NavigationTheme.activeIcon,
            ),
        ],
      ),
    );
  }
}

class GetirStyleDeliveryUiNavItem {
  const GetirStyleDeliveryUiNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
