import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/pages/categories_theme.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/item_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<ItemModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = AppServices.instance.catalog.getItems(
      city: AppConfig.defaultCity,
      categorySlug: 'getir_style_delivery_ui-groceries',
      ordering: 'top_rated',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: CategoriesTheme.screenBackground,
      appBar: GetirStyleDeliveryUiAppBar(
        backgroundColor: CategoriesTheme.appBarBackground,
        foregroundColor: CategoriesTheme.appBarForeground,
        titleColor: CategoriesTheme.appBarTitle,
        centerTitle: true,
      ),
      body: FutureBuilder<List<ItemModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          final minPrice = items.isEmpty
              ? null
              : items.map((e) => e.price).reduce((a, b) => a < b ? a : b);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AddressBar(l10n: l10n, locale: locale),
                _MapSection(
                  l10n: l10n,
                  locale: locale,
                  minOrder: minPrice == null ? null : formatToman(minPrice),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CategoriesTheme.margin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                      _SectionHeader(l10n: l10n, locale: locale),
                      const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                      if (items.isEmpty)
                        Text(
                          l10n.serviceHomePlaceholder,
                          style: GetirStyleDeliveryUiTypography.bodyMd(
                            locale,
                            color: CategoriesTheme.categoryTitle,
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _CategoryTile(
                              label: item.name,
                              price: formatToman(item.price),
                              imageUrl: item.displayImageUrl,
                              locale: locale,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddressBar extends StatelessWidget {
  const _AddressBar({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CategoriesTheme.addressBarBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: CategoriesTheme.margin,
        vertical: GetirStyleDeliveryUiSpacing.stackSm,
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: CategoriesTheme.addressIcon, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppConfig.defaultCity,
              style: GetirStyleDeliveryUiTypography.bodyMd(
                locale,
                color: CategoriesTheme.addressText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.l10n,
    required this.locale,
    this.minOrder,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String? minOrder;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CategoriesTheme.screenBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CategoriesTheme.margin,
          GetirStyleDeliveryUiSpacing.stackMd,
          CategoriesTheme.margin,
          0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CategoriesTheme.cardRadius),
            border: Border.all(color: CategoriesTheme.mapBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CategoriesTheme.cardRadius),
            child: SizedBox(
              height: CategoriesTheme.mapHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceholderImage(
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.map_outlined,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Center(
                      child: _DeliveryInfoChip(
                        l10n: l10n,
                        locale: locale,
                        minOrder: minOrder ?? l10n.valuePlaceholder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryInfoChip extends StatelessWidget {
  const _DeliveryInfoChip({
    required this.l10n,
    required this.locale,
    required this.minOrder,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String minOrder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CategoriesTheme.mapOverlayBackground,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        border: Border.all(color: CategoriesTheme.mapBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DeliveryInfoCell(
              label: l10n.minimumOrder,
              value: minOrder,
              locale: locale,
              showDivider: true,
            ),
            _DeliveryInfoCell(
              label: l10n.deliveryLabel,
              value: l10n.deliveryMinutes(30),
              locale: locale,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryInfoCell extends StatelessWidget {
  const _DeliveryInfoCell({
    required this.label,
    required this.value,
    required this.locale,
    this.showDivider = false,
  });

  final String label;
  final String value;
  final Locale locale;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GetirStyleDeliveryUiTypography.labelSm(
                  locale,
                  color: CategoriesTheme.mapOverlayLabel,
                ),
              ),
              Text(
                value,
                style: GetirStyleDeliveryUiTypography.labelLg(
                  locale,
                  color: CategoriesTheme.categoryTitle,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: CategoriesTheme.mapBorder,
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.categoriesTitle,
      style: GetirStyleDeliveryUiTypography.headlineSm(
        locale,
        color: CategoriesTheme.categoryTitle,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.price,
    required this.locale,
    this.imageUrl,
  });

  final String label;
  final String price;
  final Locale locale;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CategoriesTheme.categoryTileBackground,
              borderRadius: BorderRadius.circular(CategoriesTheme.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: PlaceholderImage(
                networkUrl: imageUrl,
                fit: BoxFit.contain,
                fallbackIcon: Icons.shopping_basket_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GetirStyleDeliveryUiTypography.labelMd(
            locale,
            color: CategoriesTheme.categoryTitle,
          ),
        ),
        Text(
          price,
          style: GetirStyleDeliveryUiTypography.labelSm(
            locale,
            color: CategoriesTheme.sectionAction,
          ),
        ),
      ],
    );
  }
}
