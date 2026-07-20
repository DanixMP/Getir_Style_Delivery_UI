import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/pages/home_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../data/models/vendor_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';
import 'restaurant_venue_screen.dart';

class DineInScreen extends StatefulWidget {
  const DineInScreen({super.key});

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  late Future<List<VendorModel>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _load();
  }

  Future<List<VendorModel>> _load() {
    return AppServices.instance.dineIn.getDineInRestaurants(
      city: AppConfig.defaultCity,
    );
  }

  Future<void> _refresh() async {
    setState(() => _restaurantsFuture = _load());
    await _restaurantsFuture;
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
        title: l10n.dineInTitle,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: GetirStyleDeliveryUiColors.primary,
        child: FutureBuilder<List<VendorModel>>(
          future: _restaurantsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(HomeTheme.margin),
                        child: Text(
                          l10n.dineInLoadError,
                          textAlign: TextAlign.center,
                          style: GetirStyleDeliveryUiTypography.bodyMd(
                            locale,
                            color: HomeTheme.serviceSubtitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final restaurants = snapshot.data ?? [];
            if (restaurants.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(HomeTheme.margin),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 56,
                              color: HomeTheme.serviceSubtitle
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.dineInEmpty,
                              textAlign: TextAlign.center,
                              style: GetirStyleDeliveryUiTypography.bodyLg(
                                locale,
                                color: HomeTheme.serviceSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                HomeTheme.margin,
                GetirStyleDeliveryUiSpacing.stackMd,
                HomeTheme.margin,
                120,
              ),
              itemCount: restaurants.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
              itemBuilder: (context, index) {
                final vendor = restaurants[index];
                return RestaurantCard(
                  vendor: vendor,
                  locale: locale,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RestaurantVenueScreen(vendor: vendor),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.vendor,
    required this.locale,
    required this.onTap,
  });

  final VendorModel vendor;
  final Locale locale;
  final VoidCallback onTap;

  String? get _coverUrl =>
      vendor.coverImageUrl?.isNotEmpty == true ? vendor.coverImageUrl : null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeTheme.glassCardBackground.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceholderImage(
                    networkUrl: _coverUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.restaurant,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Text(
                      vendor.businessName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GetirStyleDeliveryUiTypography.headlineSm(
                        locale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (vendor.rating > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GetirStyleDeliveryUiColors.secondaryContainer
                              .withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: GetirStyleDeliveryUiColors.onSecondaryContainer,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              vendor.rating.toStringAsFixed(1),
                              style: GetirStyleDeliveryUiTypography.labelSm(
                                locale,
                                color: GetirStyleDeliveryUiColors.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vendor.description.isNotEmpty)
                          Text(
                            vendor.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GetirStyleDeliveryUiTypography.bodySm(
                              locale,
                              color: HomeTheme.serviceSubtitle,
                            ),
                          ),
                        if (vendor.city.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: HomeTheme.serviceSubtitle
                                    .withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor.city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GetirStyleDeliveryUiTypography.bodySm(
                                    locale,
                                    color: HomeTheme.serviceSubtitle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                    ),
                    child: const Icon(
                      Icons.view_in_ar_outlined,
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
