import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../core/theme/pages/navigation_theme.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../features/ai_chat/ai_chat_screen.dart';
import '../features/cart/cart_provider.dart';
import '../features/cart/cart_screen.dart';
import 'ai_assistant_pill.dart';

/// Compact cart icon (left) + GETIR_STYLE_DELIVERY_UI AI (right) above the curved bottom nav.
class FloatingHomeActions extends StatefulWidget {
  const FloatingHomeActions({
    super.key,
    this.showAi = true,
    this.showCart = true,
  });

  /// Hidden on the tracking tab where the map needs the space.
  final bool showAi;

  /// Hidden on the tracking tab where the cart is shown inline.
  final bool showCart;

  @override
  State<FloatingHomeActions> createState() => _FloatingHomeActionsState();
}

class _FloatingHomeActionsState extends State<FloatingHomeActions>
    with TickerProviderStateMixin {
  static const _edgeInset = 8.0;

  late final AnimationController _entrance;
  late final AnimationController _float;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _entranceFade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final cart = context.watch<CartProvider>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navClearance = NavigationTheme.barHeight + bottomInset;
    final bottom = navClearance + 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.showCart && !cart.isEmpty)
          Positioned(
            left: _edgeInset,
            bottom: bottom,
            child: _buildAnimated(
              phase: 0,
              child: _FloatingCartIcon(
                key: ValueKey(cart.itemCount),
                cart: cart,
                locale: locale,
              ),
            ),
          ),
        if (widget.showAi) _buildAiLayer(locale: locale, bottom: bottom),
      ],
    );
  }

  Widget _buildAiLayer({required Locale locale, required double bottom}) {
    return Positioned(
      right: _edgeInset,
      bottom: bottom,
      child: _buildAnimated(
        phase: math.pi,
        child: AiAssistantMergeShell(
          locale: locale,
          progress: 0,
          child: AiAssistantPill(
            locale: locale,
            onTap: () => context.pushGetirStyleDeliveryUi(const AiChatScreen()),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimated({required double phase, required Widget child}) {
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: AnimatedBuilder(
          animation: _float,
          builder: (context, child) {
            final t = _float.value;
            final wave = math.sin(t * math.pi * 2 + phase);
            return Transform.translate(
              offset: Offset(0, wave * 3),
              child: Transform.scale(
                scale: 1 + wave * 0.015,
                child: child,
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }
}

class _FloatingCartIcon extends StatefulWidget {
  const _FloatingCartIcon({
    super.key,
    required this.cart,
    required this.locale,
  });

  final CartProvider cart;
  final Locale locale;

  @override
  State<_FloatingCartIcon> createState() => _FloatingCartIconState();
}

class _FloatingCartIconState extends State<_FloatingCartIcon>
    with SingleTickerProviderStateMixin {
  static const _size = 48.0;

  late final AnimationController _pop;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));
    _pop.forward();
  }

  @override
  void didUpdateWidget(covariant _FloatingCartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cart.itemCount != widget.cart.itemCount) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _popScale,
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        color: GetirStyleDeliveryUiColors.secondaryContainer,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushGetirStyleDeliveryUi(
            const CartScreen(),
            transition: GetirStyleDeliveryUiTransition.sharedAxisVertical,
          ),
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: GetirStyleDeliveryUiColors.primary,
                    size: 24,
                  ),
                ),
                if (widget.cart.itemCount > 0)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: _CartBadge(
                      count: widget.cart.itemCount,
                      locale: widget.locale,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count, required this.locale});

  final int count;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(count),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: GetirStyleDeliveryUiColors.primary,
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
          border: Border.all(
            color: GetirStyleDeliveryUiColors.secondaryContainer,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 9 ? '9+' : '$count',
          style: GetirStyleDeliveryUiTypography.labelSm(
            locale,
            color: GetirStyleDeliveryUiColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
