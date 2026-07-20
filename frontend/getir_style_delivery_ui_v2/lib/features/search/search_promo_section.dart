import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/assets/app_assets.dart';
import '../../core/mapping/service_category_map.dart';
import '../../core/providers/service_provider.dart';
import '../../core/theme/pages/search_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/home_promo_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../catalog/item_detail_screen.dart';

/// Banners, discounts, and today's specials on the search tab.
class SearchPromoSection extends StatelessWidget {
  const SearchPromoSection({
    super.key,
    required this.promo,
    required this.l10n,
    required this.locale,
  });

  final HomePromoModel promo;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (promo.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (promo.banners.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SearchTheme.margin,
              GetirStyleDeliveryUiSpacing.stackMd,
              SearchTheme.margin,
              0,
            ),
            child: Text(
              l10n.promotions,
              style: GetirStyleDeliveryUiTypography.headlineSm(
                locale,
                color: SearchTheme.resultTitle,
              ),
            ),
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
          _BannerCarousel(
            banners: promo.banners,
            locale: locale,
          ),
        ],
        if (promo.discountedItems.isNotEmpty) ...[
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          _PromoRow(
            title: l10n.discounted,
            items: promo.discountedItems,
            locale: locale,
          ),
        ],
        if (promo.todaySpecials.isNotEmpty) ...[
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          _PromoRow(
            title: l10n.todaySpecials,
            items: promo.todaySpecials,
            locale: locale,
          ),
        ],
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
      ],
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({
    required this.banners,
    required this.locale,
  });

  final List<HomeBannerModel> banners;
  final Locale locale;

  void _onBannerTap(BuildContext context, HomeBannerModel banner) {
    final slug = banner.categorySlug;
    if (slug == null || slug.isEmpty) return;
    context.read<ServiceProvider>().select(serviceForCategorySlug(slug));
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: banners.length,
      options: CarouselOptions(
        height: 148,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        autoPlay: banners.length > 1,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      itemBuilder: (context, index, _) {
        final banner = banners[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            elevation: 2,
            shadowColor: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _onBannerTap(context, banner),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceholderImage(
                    networkUrl: banner.imageUrl,
                    assetPath: AppAssets.mapHero,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.local_offer_outlined,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          banner.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GetirStyleDeliveryUiTypography.labelLg(
                            locale,
                            color: GetirStyleDeliveryUiColors.onPrimary,
                          ).copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (banner.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            banner.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GetirStyleDeliveryUiTypography.bodySm(
                              locale,
                              color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.9),
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
        );
      },
    );
  }
}

class _PromoRow extends StatelessWidget {
  const _PromoRow({
    required this.title,
    required this.items,
    required this.locale,
  });

  final String title;
  final List<PromoItemModel> items;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SearchTheme.margin),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GetirStyleDeliveryUiTypography.labelLg(
                  locale,
                  color: SearchTheme.resultTitle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SearchTheme.margin),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _PromoCard(promo: items[index], locale: locale),
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo, required this.locale});

  final PromoItemModel promo;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final item = promo.item;
    final badge = promo.badgeText.isNotEmpty
        ? promo.badgeText
        : (promo.discountPercent != null ? '${promo.discountPercent}%' : '');

    return SizedBox(
      width: 156,
      child: Material(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openItemDetail(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlaceholderImage(
                      networkUrl: item.displayImageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.fastfood_outlined,
                    ),
                    if (badge.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: GetirStyleDeliveryUiColors.error,
                            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                          ),
                          child: Text(
                            badge,
                            style: GetirStyleDeliveryUiTypography.labelSm(
                              locale,
                              color: GetirStyleDeliveryUiColors.onError,
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
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: SearchTheme.resultTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatToman(promo.effectivePrice),
                          style: GetirStyleDeliveryUiTypography.labelMd(
                            locale,
                            color: GetirStyleDeliveryUiColors.primary,
                          ),
                        ),
                        if (promo.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            formatToman(promo.originalPrice),
                            style: GetirStyleDeliveryUiTypography.labelSm(
                              locale,
                              color: SearchTheme.resultSubtitle,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
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
