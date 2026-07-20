import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/theme/pages/navigation_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

/// Bottom clearance when content sits inside [MainShell] with `extendBody: true`.
double shellBottomInset(BuildContext context, {double extra = 8}) {
  return NavigationTheme.barHeight +
      MediaQuery.paddingOf(context).bottom +
      extra;
}

/// Sticky cart total + checkout actions.
class CartCheckoutFooter extends StatelessWidget {
  const CartCheckoutFooter({
    super.key,
    required this.cart,
    required this.locale,
    this.embeddedInShell = false,
    this.showEditButton = true,
  });

  final CartProvider cart;
  final Locale locale;

  /// Adds padding for the curved bottom nav when used inside a tab screen.
  final bool embeddedInShell;

  /// Shows a secondary action to open the full cart editor.
  final bool showEditButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPad = embeddedInShell ? shellBottomInset(context) : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        GetirStyleDeliveryUiSpacing.marginMobile,
        12,
        GetirStyleDeliveryUiSpacing.marginMobile,
        GetirStyleDeliveryUiSpacing.marginMobile + bottomPad,
      ),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GetirStyleDeliveryUiRadius.xxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: GetirStyleDeliveryUiColors.primaryFixed,
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.cartTotal(cart.itemCount),
                    style: GetirStyleDeliveryUiTypography.bodyMd(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                    ),
                  ),
                  Text(
                    formatToman(cart.subtotal),
                    style: GetirStyleDeliveryUiTypography.headlineSm(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                  ),
                ),
                onPressed: () => context.pushGetirStyleDeliveryUi(const CheckoutScreen()),
                child: Text(
                  l10n.placeOrder,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimary,
                  ),
                ),
              ),
            ),
            if (showEditButton) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GetirStyleDeliveryUiColors.primary,
                    side: const BorderSide(color: GetirStyleDeliveryUiColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                    ),
                  ),
                  onPressed: () => context.pushGetirStyleDeliveryUi(const CartScreen()),
                  child: Text(
                    l10n.editCart,
                    style: GetirStyleDeliveryUiTypography.labelMd(
                      locale,
                      color: GetirStyleDeliveryUiColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
