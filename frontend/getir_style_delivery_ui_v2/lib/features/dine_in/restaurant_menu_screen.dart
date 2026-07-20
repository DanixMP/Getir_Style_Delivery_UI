import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/pages/home_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/item_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';
import '../catalog/item_detail_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  final String vendorId;
  final String vendorName;

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  late Future<List<ItemModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _load();
  }

  Future<List<ItemModel>> _load() {
    return AppServices.instance.catalog.getItems(
      city: AppConfig.defaultCity,
      vendorId: widget.vendorId,
      ordering: 'top_rated',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: HomeTheme.screenBackground,
      appBar: GetirStyleDeliveryUiAppBar(
        backgroundColor: HomeTheme.appBarBackground,
        foregroundColor: HomeTheme.appBarForeground,
        titleColor: HomeTheme.appBarTitle,
        title: widget.vendorName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(HomeTheme.margin),
                child: Text(
                  l10n.serviceHomePlaceholder,
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.bodyMd(
                    locale,
                    color: HomeTheme.serviceSubtitle,
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              HomeTheme.margin,
              GetirStyleDeliveryUiSpacing.stackMd,
              HomeTheme.margin,
              120,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _MenuItemCard(item: items[index], locale: locale),
          );
        },
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.locale});

  final ItemModel item;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeTheme.glassCardBackground.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openItemDetail(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceholderImage(
                    networkUrl: item.displayImageUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.fastfood_outlined,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: GetirStyleDeliveryUiColors.primary,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => openItemDetail(context, item),
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.add,
                            color: GetirStyleDeliveryUiColors.onPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GetirStyleDeliveryUiTypography.labelLg(
                      locale,
                      color: HomeTheme.serviceTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatToman(item.price),
                    style: GetirStyleDeliveryUiTypography.labelMd(
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
    );
  }
}
