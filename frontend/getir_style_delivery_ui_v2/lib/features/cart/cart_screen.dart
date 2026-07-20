import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/placeholder_image.dart';
import 'cart_checkout_footer.dart';
import 'cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text(
          l10n.cartTitle,
          style: GetirStyleDeliveryUiTypography.headlineMd(locale, color: GetirStyleDeliveryUiColors.onPrimary),
        ),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: l10n.clearCart,
              icon: const Icon(Icons.delete_outline),
              onPressed: cart.clear,
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(locale: locale)
          : Column(
              children: [
                if (cart.vendorName.isNotEmpty)
                  _VendorHeader(name: cart.vendorName, locale: locale),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      GetirStyleDeliveryUiSpacing.marginMobile,
                      0,
                      GetirStyleDeliveryUiSpacing.marginMobile,
                      GetirStyleDeliveryUiSpacing.marginMobile,
                    ),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final line = cart.lines[index];
                      return _CartLineTile(line: line, locale: locale);
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : CartCheckoutFooter(
              cart: cart,
              locale: locale,
              showEditButton: false,
            ),
    );
  }
}

class _VendorHeader extends StatelessWidget {
  const _VendorHeader({required this.name, required this.locale});

  final String name;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        GetirStyleDeliveryUiSpacing.marginMobile,
        GetirStyleDeliveryUiSpacing.marginMobile,
        GetirStyleDeliveryUiSpacing.marginMobile,
        GetirStyleDeliveryUiSpacing.stackSm,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront,
                size: 18, color: GetirStyleDeliveryUiColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GetirStyleDeliveryUiTypography.labelLg(
                locale,
                color: GetirStyleDeliveryUiColors.onPrimaryFixed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: GetirStyleDeliveryUiColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 56, color: GetirStyleDeliveryUiColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cartEmpty,
            style: GetirStyleDeliveryUiTypography.bodyMd(
              locale,
              color: GetirStyleDeliveryUiColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.locale});

  final CartLine line;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          PlaceholderImage(
            networkUrl: line.item.displayImageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
            fallbackIcon: Icons.fastfood_outlined,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatToman(line.lineTotal),
                  style: GetirStyleDeliveryUiTypography.labelMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QtyStepper(
            quantity: line.quantity,
            onMinus: () => cart.decrement(line.item.id),
            onPlus: () => cart.increment(line.item.id),
            locale: locale,
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    required this.locale,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: quantity > 1 ? Icons.remove : Icons.delete_outline,
            onTap: onMinus,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: GetirStyleDeliveryUiTypography.labelLg(
                locale,
                color: GetirStyleDeliveryUiColors.onSurface,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: GetirStyleDeliveryUiColors.primary),
        ),
      ),
    );
  }
}
