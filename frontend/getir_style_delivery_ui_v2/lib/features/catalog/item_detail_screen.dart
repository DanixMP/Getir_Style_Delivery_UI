import 'package:flutter/material.dart';

import '../../core/providers/app_services.dart';
import '../../core/theme/pages/home_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../data/models/item_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';
import '../cart/cart_actions.dart';
import '../cart/cart_provider.dart';

/// Opens the product detail page for [item].
Future<void> openItemDetail(BuildContext context, ItemModel item) {
  return context.pushGetirStyleDeliveryUi(
    ItemDetailScreen(item: item),
    transition: GetirStyleDeliveryUiTransition.sharedAxisVertical,
  );
}

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final ItemModel item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _qty = 1;
  bool _added = false;
  Future<List<ItemModel>>? _suggestionsFuture;

  Future<List<ItemModel>> _loadSuggestions() async {
    final vendorId = widget.item.vendorId;
    if (vendorId == null) return [];
    try {
      final items =
          await AppServices.instance.catalog.getItems(vendorId: vendorId);
      return items.where((i) => i.id != widget.item.id).take(8).toList();
    } catch (_) {
      return [];
    }
  }

  void _add() {
    final result =
        addItemToCart(context, widget.item, quantity: _qty, showSnack: true);
    if (result != AddToCartResult.vendorMismatch) {
      setState(() {
        _added = true;
        _suggestionsFuture ??= _loadSuggestions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final item = widget.item;

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: GetirStyleDeliveryUiAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: HomeTheme.appBarBackground,
        foregroundColor: HomeTheme.appBarForeground,
        titleColor: HomeTheme.appBarTitle,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceholderImage(
                    networkUrl: item.displayImageUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                    fallbackIcon: Icons.fastfood_outlined,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            // Pulled up so the content sheet overlaps the image; the photo
            // sits behind it and slides away as you scroll.
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: const BoxDecoration(
                  color: GetirStyleDeliveryUiColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(GetirStyleDeliveryUiRadius.xxl),
                  ),
                ),
                padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SoftBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GetirStyleDeliveryUiTypography.headlineMd(
                              locale,
                              color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.storefront,
                                  size: 16,
                                  color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.vendorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GetirStyleDeliveryUiTypography.bodyMd(
                                    locale,
                                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                                  ),
                                ),
                              ),
                              if (item.rating > 0) ...[
                                const Icon(Icons.star,
                                    size: 16, color: GetirStyleDeliveryUiColors.secondary),
                                const SizedBox(width: 2),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: GetirStyleDeliveryUiTypography.labelMd(
                                    locale,
                                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            formatToman(item.price),
                            style: GetirStyleDeliveryUiTypography.headlineSm(
                              locale,
                              color: GetirStyleDeliveryUiColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _SoftBox(
                        child: Text(
                          item.description,
                          style: GetirStyleDeliveryUiTypography.bodyMd(
                            locale,
                            color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                          ),
                        ),
                      ),
                    ],
                    if (_added) ...[
                      const SizedBox(height: 12),
                      _SoftBox(
                        child: _SuggestionsSection(
                          future: _suggestionsFuture!,
                          l10n: l10n,
                          locale: locale,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        l10n: l10n,
        locale: locale,
        qty: _qty,
        unitPrice: item.price,
        added: _added,
        onDec: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
        onInc: () => setState(() => _qty += 1),
        onAdd: _add,
      ),
    );
  }
}

/// Soft purple rounded panel used to group the detail content.
class _SoftBox extends StatelessWidget {
  const _SoftBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: child,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.l10n,
    required this.locale,
    required this.qty,
    required this.unitPrice,
    required this.added,
    required this.onDec,
    required this.onInc,
    required this.onAdd,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final int qty;
  final int unitPrice;
  final bool added;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: GetirStyleDeliveryUiColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onDec,
                    icon: const Icon(Icons.remove),
                    color: GetirStyleDeliveryUiColors.primary,
                  ),
                  Text(
                    '$qty',
                    style: GetirStyleDeliveryUiTypography.labelLg(
                      locale,
                      color: GetirStyleDeliveryUiColors.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: onInc,
                    icon: const Icon(Icons.add),
                    color: GetirStyleDeliveryUiColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: onAdd,
                child: Text(
                  '${added ? l10n.addMore : l10n.addToCart} · ${formatToman(unitPrice * qty)}',
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Post-add upsell: "add these too" — same-vendor add-ons (drinks, sides…).
class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection({
    required this.future,
    required this.l10n,
    required this.locale,
  });

  final Future<List<ItemModel>> future;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemModel>>(
      future: future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.upsellTitle,
              style: GetirStyleDeliveryUiTypography.headlineSm(
                locale,
                color: GetirStyleDeliveryUiColors.onPrimaryFixed,
              ),
            ),
            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) =>
                    _SuggestionCard(item: items[index], locale: locale),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.item, required this.locale});

  final ItemModel item;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Material(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openItemDetail(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlaceholderImage(
                      networkUrl:
                          item.displayImageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.local_drink_outlined,
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Material(
                        color: GetirStyleDeliveryUiColors.primary,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => addItemToCart(context, item),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.add,
                                color: GetirStyleDeliveryUiColors.onPrimary, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatToman(item.price),
                      style: GetirStyleDeliveryUiTypography.labelSm(
                        locale,
                        color: GetirStyleDeliveryUiColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
