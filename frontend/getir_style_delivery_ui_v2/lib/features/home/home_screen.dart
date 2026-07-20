import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/assets/app_assets.dart';
import '../../core/assets/catalog_images.dart';
import '../../core/config/app_config.dart';
import '../../core/mapping/service_category_map.dart';
import '../../core/models/getir_style_delivery_ui_service.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/app_services.dart';
import '../../core/providers/service_provider.dart';
import '../../core/theme/pages/home_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/category_model.dart';
import '../../data/models/item_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';
import '../address/selected_address_bar.dart';
import '../catalog/item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<
      ({
        List<CategoryModel> categories,
        List<ItemModel> items,
      })> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadForCity(AppConfig.defaultCity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final city =
          context.read<AddressProvider>().selected?.city ?? AppConfig.defaultCity;
      _refresh(city: city);
    });
  }

  void _refresh({String? city}) {
    final resolved =
        city ?? context.read<AddressProvider>().selected?.city ?? AppConfig.defaultCity;
    setState(() => _dataFuture = _loadForCity(resolved));
  }

  Future<
      ({
        List<CategoryModel> categories,
        List<ItemModel> items,
      })> _loadForCity(String city) async {
    final catalog = AppServices.instance.catalog;
    final results = await Future.wait([
      catalog.getCategories(),
      catalog.getItems(
        city: city,
        ordering: 'top_rated',
      ),
    ]);
    return (
      categories: results[0] as List<CategoryModel>,
      items: results[1] as List<ItemModel>,
    );
  }

  void _openCategory(CategoryModel category) {
    if (category.isComingSoon) return;
    context
        .read<ServiceProvider>()
        .select(serviceForCategorySlug(category.slug));
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
        showAddressChip: true,
      ),
      body: Column(
        children: [
          const SelectedAddressBar(),
          Expanded(
            child: FutureBuilder<
                ({
                  List<CategoryModel> categories,
                  List<ItemModel> items,
                })>(
              future: _dataFuture,
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _dataFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroSection(l10n: l10n, locale: locale),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: HomeTheme.margin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                        Text(
                          l10n.categoriesTitle,
                          style: GetirStyleDeliveryUiTypography.headlineSm(
                            locale,
                            color: HomeTheme.serviceTitle,
                          ),
                        ),
                        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                        _CategoryGrid(
                          categories: data.categories,
                          locale: locale,
                          onTap: _openCategory,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: HomeTheme.margin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                        Text(
                          l10n.popularCategories,
                          style: GetirStyleDeliveryUiTypography.headlineSm(
                            locale,
                            color: HomeTheme.serviceTitle,
                          ),
                        ),
                        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                        _ItemsRow(items: data.items, locale: locale),
                      ],
                    ),
                  ),
                ],
              ),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.l10n,
    required this.locale,
  });

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeTheme.heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PlaceholderImage(
            assetPath: AppAssets.mapHero,
            fit: BoxFit.cover,
            fallbackIcon: Icons.map_outlined,
            borderRadius: BorderRadius.zero,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HomeTheme.screenBackground.withValues(alpha: 0.1),
                  HomeTheme.screenBackground.withValues(alpha: 0.5),
                  HomeTheme.screenBackground.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          Positioned(
            left: HomeTheme.margin,
            right: HomeTheme.margin,
            bottom: 16,
            child: Column(
              children: [
                Text(
                  l10n.heroTitle,
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.headlineMd(
                    locale,
                    color: HomeTheme.heroTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.heroSubtitle,
                  textAlign: TextAlign.center,
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

class _GetirCategoryGrid extends StatelessWidget {
  const _GetirCategoryGrid({
    required this.categories,
    required this.locale,
    required this.onTap,
  });

  final List<CategoryModel> categories;
  final Locale locale;
  final void Function(CategoryModel) onTap;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    var index = 0;
    var block = 0;

    while (index < categories.length) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: _gap));

      if (block.isEven && index + 2 < categories.length) {
        rows.add(_LargeWithStackRow(
          categories: categories,
          start: index,
          locale: locale,
          onTap: onTap,
          largeOnLeft: block % 4 == 0,
        ));
        index += 3;
      } else if (index + 1 < categories.length) {
        rows.add(_MediumPairRow(
          categories: categories,
          start: index,
          locale: locale,
          onTap: onTap,
        ));
        index += 2;
      } else {
        rows.add(_CategoryCard(
          category: categories[index],
          locale: locale,
          onTap: () => onTap(categories[index]),
          height: HomeTheme.serviceCardMediumHeight,
        ));
        index += 1;
      }
      block++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// One tall tile + two stacked small tiles (Getir-style row).
class _LargeWithStackRow extends StatelessWidget {
  const _LargeWithStackRow({
    required this.categories,
    required this.start,
    required this.locale,
    required this.onTap,
    required this.largeOnLeft,
  });

  final List<CategoryModel> categories;
  final int start;
  final Locale locale;
  final void Function(CategoryModel) onTap;
  final bool largeOnLeft;

  @override
  Widget build(BuildContext context) {
    final smallH =
        (HomeTheme.serviceCardLargeHeight - _GetirCategoryGrid._gap) / 2;
    final large = _CategoryCard(
      category: categories[start],
      locale: locale,
      onTap: () => onTap(categories[start]),
      height: HomeTheme.serviceCardLargeHeight,
    );
    final stack = Column(
      children: [
        _CategoryCard(
          category: categories[start + 1],
          locale: locale,
          onTap: () => onTap(categories[start + 1]),
          height: smallH,
        ),
        const SizedBox(height: _GetirCategoryGrid._gap),
        _CategoryCard(
          category: categories[start + 2],
          locale: locale,
          onTap: () => onTap(categories[start + 2]),
          height: smallH,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final largeW = w * 0.58;
        final stackW = w - largeW - _GetirCategoryGrid._gap;
        final largeBox = SizedBox(width: largeW, child: large);
        final stackBox = SizedBox(width: stackW, child: stack);
        return SizedBox(
          height: HomeTheme.serviceCardLargeHeight,
          child: Row(
            children: largeOnLeft
                ? [largeBox, const SizedBox(width: _GetirCategoryGrid._gap), stackBox]
                : [stackBox, const SizedBox(width: _GetirCategoryGrid._gap), largeBox],
          ),
        );
      },
    );
  }
}

class _MediumPairRow extends StatelessWidget {
  const _MediumPairRow({
    required this.categories,
    required this.start,
    required this.locale,
    required this.onTap,
  });

  final List<CategoryModel> categories;
  final int start;
  final Locale locale;
  final void Function(CategoryModel) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CategoryCard(
            category: categories[start],
            locale: locale,
            onTap: () => onTap(categories[start]),
            height: HomeTheme.serviceCardMediumHeight,
          ),
        ),
        const SizedBox(width: _GetirCategoryGrid._gap),
        Expanded(
          child: _CategoryCard(
            category: categories[start + 1],
            locale: locale,
            onTap: () => onTap(categories[start + 1]),
            height: HomeTheme.serviceCardMediumHeight,
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.locale,
    required this.onTap,
  });

  final List<CategoryModel> categories;
  final Locale locale;
  final void Function(CategoryModel) onTap;

  @override
  Widget build(BuildContext context) {
    return _GetirCategoryGrid(
      categories: categories,
      locale: locale,
      onTap: onTap,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.locale,
    required this.onTap,
    required this.height,
  });

  final CategoryModel category;
  final Locale locale;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = getirStyleDeliveryUiServiceById(serviceForCategorySlug(category.slug));
    final label = service?.displayTitle(l10n, locale) ??
        (locale.languageCode == 'fa' || locale.languageCode == 'ar'
            ? category.name
            : category.name.toUpperCase());

    return SizedBox(
      height: height,
      child: Material(
        color: HomeTheme.glassCardBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: category.isComingSoon ? null : onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PlaceholderImage(
                networkUrl: CatalogImages.forCategory(category.slug),
                fit: BoxFit.cover,
                fallbackIcon: CatalogImages.iconForCategory(category.slug),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.isComingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.sm),
                        ),
                        child: Text(
                          AppLocalizations.of(context).comingSoon,
                          style: GetirStyleDeliveryUiTypography.labelSm(
                            locale,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GetirStyleDeliveryUiTypography.headlineSm(
                        locale,
                        color: HomeTheme.serviceBrandTitle,
                      ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.3),
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

class _ItemsRow extends StatelessWidget {
  const _ItemsRow({required this.items, required this.locale});

  final List<ItemModel> items;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        '—',
        style: GetirStyleDeliveryUiTypography.bodyMd(locale),
      );
    }
    final slides = items.take(20).toList();
    return CarouselSlider.builder(
      itemCount: slides.length,
      options: CarouselOptions(
        height: 240,
        viewportFraction: 0.62,
        enlargeCenterPage: true,
        enlargeFactor: 0.22,
        enableInfiniteScroll: slides.length > 2,
        padEnds: false,
      ),
      itemBuilder: (context, index, _) =>
          _ItemCard(item: slides[index], locale: locale),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.locale});

  final ItemModel item;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
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
                            padding: EdgeInsets.all(6),
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
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: HomeTheme.serviceTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatToman(item.price),
                      style: GetirStyleDeliveryUiTypography.labelSm(
                        locale,
                        color: HomeTheme.serviceSubtitle,
                      ),
                    ),
                    Text(
                      item.vendorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GetirStyleDeliveryUiTypography.bodySm(
                        locale,
                        color: HomeTheme.serviceHint,
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
