import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_services.dart';
import '../../core/providers/dine_in_session_provider.dart';
import '../../core/theme/pages/home_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/dine_in_venue_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/vendor_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/neshan_map_view.dart';
import '../../widgets/placeholder_image.dart';
import 'panorama_table_picker_screen.dart';

class RestaurantVenueScreen extends StatefulWidget {
  const RestaurantVenueScreen({super.key, required this.vendor});

  final VendorModel vendor;

  @override
  State<RestaurantVenueScreen> createState() => _RestaurantVenueScreenState();
}

class _RestaurantVenueScreenState extends State<RestaurantVenueScreen> {
  late Future<DineInVenueModel> _venueFuture;

  @override
  void initState() {
    super.initState();
    _venueFuture =
        AppServices.instance.dineIn.getVenueDetail(widget.vendor.id);
  }

  String _heroImage(DineInVenueModel venue) =>
      venue.vendor.coverImageUrl ??
      venue.panorama?.imageUrl ??
      widget.vendor.coverImageUrl ??
      '';

  LatLng? get _mapCenter {
    final lat = widget.vendor.latitude;
    final lng = widget.vendor.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _enterRestaurant(DineInVenueModel venue) {
    context.read<DineInSessionProvider>().startVenue(
          vendorId: venue.vendor.id,
          vendorName: venue.vendor.businessName,
          panoramaUrl: venue.panorama?.imageUrl,
        );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PanoramaTablePickerScreen(venue: venue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: HomeTheme.screenBackground,
      body: FutureBuilder<DineInVenueModel>(
        future: _venueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorState(
              message: l10n.loadVenueError,
              locale: locale,
              onBack: () => Navigator.of(context).pop(),
            );
          }

          final venue = snapshot.data!;
          final vendor = venue.vendor;
          final heroUrl = _heroImage(venue);
          final availableTables =
              venue.tables.where((t) => t.isSelectable).length;

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    stretch: true,
                    backgroundColor: GetirStyleDeliveryUiColors.primary,
                    foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          PlaceholderImage(
                            networkUrl: heroUrl.isNotEmpty ? heroUrl : null,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.restaurant,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.72),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: HomeTheme.margin,
                            right: HomeTheme.margin,
                            bottom: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (vendor.rating > 0)
                                  _RatingChip(
                                    rating: vendor.rating,
                                    count: vendor.ratingCount,
                                    locale: locale,
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  vendor.businessName,
                                  style: GetirStyleDeliveryUiTypography.headlineLg(
                                    locale,
                                    color: Colors.white,
                                  ),
                                ),
                                if (vendor.city.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    vendor.city,
                                    style: GetirStyleDeliveryUiTypography.bodyMd(
                                      locale,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        HomeTheme.margin,
                        GetirStyleDeliveryUiSpacing.stackLg,
                        HomeTheme.margin,
                        120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.view_in_ar,
                                label: l10n.restaurant360Booking,
                              ),
                              _InfoChip(
                                icon: Icons.table_restaurant,
                                label: l10n.restaurantTablesAvailable(
                                  availableTables,
                                ),
                              ),
                            ],
                          ),
                          if (vendor.description.isNotEmpty) ...[
                            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                            Text(
                              l10n.restaurantAbout,
                              style: GetirStyleDeliveryUiTypography.headlineSm(
                                locale,
                                color: HomeTheme.serviceTitle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vendor.description,
                              style: GetirStyleDeliveryUiTypography.bodyMd(
                                locale,
                                color: HomeTheme.serviceSubtitle,
                              ),
                            ),
                          ],
                          if (vendor.address.isNotEmpty) ...[
                            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                            _SectionCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: GetirStyleDeliveryUiColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.restaurantAddress,
                                          style: GetirStyleDeliveryUiTypography.labelLg(
                                            locale,
                                            color: HomeTheme.serviceTitle,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          vendor.address,
                                          style: GetirStyleDeliveryUiTypography.bodyMd(
                                            locale,
                                            color: HomeTheme.serviceSubtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_mapCenter != null) ...[
                            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                              child: SizedBox(
                                height: 200,
                                child: NeshanMapView(
                                  center: _mapCenter!,
                                  zoom: 15,
                                  interactive: false,
                                  markers: [
                                    NeshanMapMarker(
                                      point: _mapCenter!,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: GetirStyleDeliveryUiColors.primary,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (venue.featuredItems.isNotEmpty) ...[
                            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                            Text(
                              l10n.restaurantFeaturedMenu,
                              style: GetirStyleDeliveryUiTypography.headlineSm(
                                locale,
                                color: HomeTheme.serviceTitle,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 168,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: venue.featuredItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) =>
                                    _MenuPreviewCard(
                                  item: venue.featuredItems[index],
                                  locale: locale,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: HomeTheme.margin,
                right: HomeTheme.margin,
                bottom: 24,
                child: SafeArea(
                  top: false,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: GetirStyleDeliveryUiColors.primary,
                      foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shadowColor: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                      ),
                    ),
                    onPressed: () => _enterRestaurant(venue),
                    icon: const Icon(Icons.view_in_ar),
                    label: Text(
                      l10n.enterRestaurant,
                      style: GetirStyleDeliveryUiTypography.labelLg(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.locale,
    required this.onBack,
  });

  final String message;
  final Locale locale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(HomeTheme.margin),
                child: Text(
                  message,
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
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.rating,
    required this.count,
    required this.locale,
  });

  final double rating;
  final int count;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.secondaryContainer.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: GetirStyleDeliveryUiColors.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GetirStyleDeliveryUiTypography.labelMd(
              locale,
              color: GetirStyleDeliveryUiColors.onSecondaryContainer,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: GetirStyleDeliveryUiTypography.bodySm(
                locale,
                color: GetirStyleDeliveryUiColors.onSecondaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HomeTheme.glassCardBackground,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        border: Border.all(color: HomeTheme.glassCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: GetirStyleDeliveryUiColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GetirStyleDeliveryUiColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeTheme.glassCardBackground,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: HomeTheme.glassCardBorder),
      ),
      child: child,
    );
  }
}

class _MenuPreviewCard extends StatelessWidget {
  const _MenuPreviewCard({required this.item, required this.locale});

  final ItemModel item;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: HomeTheme.glassCardBackground,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        border: Border.all(color: HomeTheme.glassCardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PlaceholderImage(
              networkUrl: item.imageUrl,
              fit: BoxFit.cover,
              fallbackIcon: Icons.restaurant_menu,
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
                  style: GetirStyleDeliveryUiTypography.labelMd(
                    locale,
                    color: HomeTheme.serviceTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatToman(item.price),
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.secondary,
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
