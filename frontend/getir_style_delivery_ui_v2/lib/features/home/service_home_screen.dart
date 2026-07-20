import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/mapping/service_category_map.dart';
import '../../core/models/getir_style_delivery_ui_service.dart';
import '../../core/providers/app_services.dart';
import '../../core/providers/service_provider.dart';
import '../../core/theme/pages/home_theme.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/item_model.dart';
import '../../data/models/vendor_model.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/profile_menu_button.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';
import '../address/selected_address_bar.dart';
import '../catalog/item_detail_screen.dart';
import '../dine_in/dine_in_screen.dart';
import '../dine_in/restaurant_venue_screen.dart';

class ServiceHomeScreen extends StatefulWidget {
  const ServiceHomeScreen({super.key, required this.service});

  final GetirStyleDeliveryUiService service;

  @override
  State<ServiceHomeScreen> createState() => _ServiceHomeScreenState();
}

class _ServiceHomeScreenState extends State<ServiceHomeScreen> {
  late Future<({List<VendorModel> vendors, List<ItemModel> items})> _dataFuture;

  bool get _isRestaurantService =>
      widget.service.id == GetirStyleDeliveryUiServiceId.restaurant;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  Future<({List<VendorModel> vendors, List<ItemModel> items})> _load() async {
    final catalog = AppServices.instance.catalog;
    final slug = categorySlugForService(widget.service.id);
    if (_isRestaurantService) {
      final vendors = await catalog.getVendors(
        city: AppConfig.defaultCity,
        categorySlug: slug,
        supportsDineIn: true,
      );
      return (vendors: vendors, items: <ItemModel>[]);
    }
    final vendors = await catalog.getVendors(
      city: AppConfig.defaultCity,
      categorySlug: slug,
    );
    final items = await catalog.getItems(
      city: AppConfig.defaultCity,
      categorySlug: slug,
      ordering: 'top_rated',
    );
    return (vendors: vendors, items: items);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final slug = categorySlugForService(widget.service.id);

    return Scaffold(
      backgroundColor: HomeTheme.screenBackground,
      appBar: GetirStyleDeliveryUiAppBar(
        backgroundColor: HomeTheme.appBarBackground,
        foregroundColor: HomeTheme.appBarForeground,
        titleColor: HomeTheme.appBarTitle,
        title: widget.service.displayTitle(l10n, locale),
        showAddressChip: true,
        leading: IconButton(
          icon: const Icon(Icons.apps),
          tooltip: l10n.switchService,
          onPressed: () => context.read<ServiceProvider>().clear(),
        ),
        trailing: const ProfileMenuButton(color: HomeTheme.appBarForeground),
      ),
      body: Column(
        children: [
          const SelectedAddressBar(),
          Expanded(
            child: slug == null
          ? _StaticServiceBody(service: widget.service, l10n: l10n, locale: locale)
          : FutureBuilder(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                final data = snapshot.data!;
                if (_isRestaurantService) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Hero(service: widget.service, l10n: l10n, locale: locale),
                        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                        if (data.vendors.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(HomeTheme.margin),
                            child: Text(
                              l10n.dineInEmpty,
                              style: GetirStyleDeliveryUiTypography.bodyMd(
                                locale,
                                color: HomeTheme.serviceSubtitle,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: HomeTheme.margin,
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < data.vendors.length; i++) ...[
                                  if (i > 0)
                                    const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                                  RestaurantCard(
                                    vendor: data.vendors[i],
                                    locale: locale,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => RestaurantVenueScreen(
                                          vendor: data.vendors[i],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }
                final groups = _groupByMarket(data.vendors, data.items);
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Hero(service: widget.service, l10n: l10n, locale: locale),
                      const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                      if (groups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(HomeTheme.margin),
                          child: Text(
                            l10n.serviceHomePlaceholder,
                            style: GetirStyleDeliveryUiTypography.bodyMd(
                              locale,
                              color: HomeTheme.serviceSubtitle,
                            ),
                          ),
                        )
                      else
                        ...groups.map(
                          (g) => _MarketSection(group: g, locale: locale),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticServiceBody extends StatelessWidget {
  const _StaticServiceBody({
    required this.service,
    required this.l10n,
    required this.locale,
  });

  final GetirStyleDeliveryUiService service;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          _Hero(service: service, l10n: l10n, locale: locale),
          Padding(
            padding: const EdgeInsets.all(HomeTheme.margin),
            child: Text(
              service.hint(l10n) ?? l10n.serviceHomePlaceholder,
              style: GetirStyleDeliveryUiTypography.bodyLg(
                locale,
                color: HomeTheme.serviceSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.service,
    required this.l10n,
    required this.locale,
  });

  final GetirStyleDeliveryUiService service;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PlaceholderImage(
            assetPath: service.imagePath,
            fit: BoxFit.cover,
            fallbackIcon: Icons.storefront_outlined,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  HomeTheme.screenBackground.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            left: HomeTheme.margin,
            right: HomeTheme.margin,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.displayTitle(l10n, locale),
                  style: GetirStyleDeliveryUiTypography.headlineLg(
                    locale,
                    color: HomeTheme.serviceBrandTitle,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                if (service.subtitle(l10n) != null)
                  Text(
                    service.subtitle(l10n)!,
                    style: GetirStyleDeliveryUiTypography.bodyMd(
                      locale,
                      color: HomeTheme.heroSubtitle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One market and the items it offers, used to lay foods out per-vendor.
class _MarketGroup {
  _MarketGroup({
    required this.name,
    required this.items,
    this.rating = 0,
    this.logoUrl,
  });

  final String name;
  final List<ItemModel> items;
  final double rating;
  final String? logoUrl;
}

/// Groups items by their vendor, preferring the rich VendorModel metadata
/// (name, rating, logo) and falling back to the item's vendor name.
List<_MarketGroup> _groupByMarket(
  List<VendorModel> vendors,
  List<ItemModel> items,
) {
  final byVendorId = <String, List<ItemModel>>{};
  final byName = <String, List<ItemModel>>{};
  for (final it in items) {
    if (it.vendorId != null && it.vendorId!.isNotEmpty) {
      byVendorId.putIfAbsent(it.vendorId!, () => []).add(it);
    } else {
      byName.putIfAbsent(it.vendorName, () => []).add(it);
    }
  }

  final groups = <_MarketGroup>[];
  final used = <String>{};
  for (final v in vendors) {
    final its = byVendorId[v.id];
    if (its != null && its.isNotEmpty) {
      groups.add(_MarketGroup(
        name: v.businessName,
        items: its,
        rating: v.rating,
        logoUrl: v.logoUrl,
      ));
      used.add(v.id);
    }
  }
  byVendorId.forEach((id, its) {
    if (!used.contains(id) && its.isNotEmpty) {
      groups.add(_MarketGroup(name: its.first.vendorName, items: its));
    }
  });
  byName.forEach((name, its) {
    groups.add(_MarketGroup(name: name, items: its));
  });
  return groups;
}

class _MarketSection extends StatelessWidget {
  const _MarketSection({required this.group, required this.locale});

  final _MarketGroup group;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            HomeTheme.margin,
            0,
            HomeTheme.margin,
            GetirStyleDeliveryUiSpacing.stackSm,
          ),
          child: Row(
            children: [
              PlaceholderImage(
                networkUrl: group.logoUrl,
                width: 36,
                height: 36,
                fallbackIcon: Icons.storefront,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.headlineSm(
                    locale,
                    color: HomeTheme.serviceTitle,
                  ),
                ),
              ),
              if (group.rating > 0) ...[
                const Icon(Icons.star, size: 16, color: GetirStyleDeliveryUiColors.secondary),
                const SizedBox(width: 2),
                Text(
                  group.rating.toStringAsFixed(1),
                  style: GetirStyleDeliveryUiTypography.labelMd(
                    locale,
                    color: HomeTheme.serviceSubtitle,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 224,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: HomeTheme.margin),
            itemCount: group.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _FoodCard(item: group.items[index], locale: locale),
          ),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
      ],
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.item, required this.locale});

  final ItemModel item;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      child: Material(
        color: HomeTheme.glassCardBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openItemDetail(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlaceholderImage(
                      networkUrl:
                          item.displayImageUrl,
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
                            child: Icon(Icons.add,
                                color: GetirStyleDeliveryUiColors.onPrimary, size: 22),
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
                      maxLines: 1,
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
      ),
    );
  }
}
