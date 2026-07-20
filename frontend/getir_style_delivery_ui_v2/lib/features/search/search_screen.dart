import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/pages/search_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/home_promo_model.dart';
import '../../data/models/item_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/profile_menu_button.dart';
import '../cart/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../catalog/item_detail_screen.dart';
import 'search_promo_section.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _VendorGroup {
  _VendorGroup(this.name);
  final String name;
  final List<ItemModel> items = [];
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<ItemModel> _results = [];
  HomePromoModel _promo = const HomePromoModel();
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final catalog = AppServices.instance.catalog;
      final results = await Future.wait([
        catalog.getItems(city: AppConfig.defaultCity, ordering: 'top_rated'),
        catalog.getHomePromo(city: AppConfig.defaultCity),
      ]);
      if (!mounted) return;
      setState(() {
        _results = results[0] as List<ItemModel>;
        _promo = results[1] as HomePromoModel;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search(String query) async {
    setState(() {
      _query = query.trim();
      _loading = true;
    });
    try {
      final items = _query.isEmpty
          ? await AppServices.instance.catalog.getItems(
              city: AppConfig.defaultCity,
              ordering: 'top_rated',
            )
          : await AppServices.instance.catalog.getItems(
              city: AppConfig.defaultCity,
              search: _query,
            );
      if (!mounted) return;
      setState(() {
        _results = items;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_VendorGroup> _groupByVendor(List<ItemModel> items) {
    final groups = <String, _VendorGroup>{};
    for (final it in items) {
      final key =
          (it.vendorId?.isNotEmpty ?? false) ? it.vendorId! : it.vendorName;
      groups.putIfAbsent(key, () => _VendorGroup(it.vendorName)).items.add(it);
    }
    return groups.values.toList();
  }

  bool get _showPromos => _query.isEmpty && !_promo.isEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: SearchTheme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchHeader(
              l10n: l10n,
              locale: locale,
              cartCount: cartCount,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SearchTheme.margin,
                GetirStyleDeliveryUiSpacing.stackSm,
                SearchTheme.margin,
                GetirStyleDeliveryUiSpacing.stackMd,
              ),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _SearchField(
                controller: _controller,
                focusNode: _focusNode,
                locale: locale,
                hint: l10n.searchHint,
                onSubmitted: _search,
                onChanged: (value) {
                  if (value.isEmpty) _search('');
                },
                onClear: () {
                  _controller.clear();
                  _search('');
                },
              ),
            ),
            ),
            if (_query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SearchTheme.margin,
                  GetirStyleDeliveryUiSpacing.stackMd,
                  SearchTheme.margin,
                  GetirStyleDeliveryUiSpacing.stackSm,
                ),
                child: Text(
                  l10n.searchResultsFor(_query),
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: SearchTheme.resultTitle,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SearchTheme.margin,
                  GetirStyleDeliveryUiSpacing.stackMd,
                  SearchTheme.margin,
                  GetirStyleDeliveryUiSpacing.stackSm,
                ),
                child: Text(
                  l10n.browseAllProducts,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: SearchTheme.resultTitle,
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadInitial,
                      color: GetirStyleDeliveryUiColors.primary,
                      child: _buildScrollBody(l10n, locale),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollBody(AppLocalizations l10n, Locale locale) {
    if (!_loading && _results.isEmpty && !_showPromos) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 120,
            child: Center(
              child: Text(
                l10n.serviceHomePlaceholder,
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  locale,
                  color: SearchTheme.resultSubtitle,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final groups = _groupByVendor(_results);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (_showPromos)
          SearchPromoSection(
            promo: _promo,
            l10n: l10n,
            locale: locale,
          ),
        if (_results.isEmpty && _showPromos)
          Padding(
            padding: const EdgeInsets.all(SearchTheme.margin),
            child: Text(
              l10n.serviceHomePlaceholder,
              textAlign: TextAlign.center,
              style: GetirStyleDeliveryUiTypography.bodyMd(
                locale,
                color: SearchTheme.resultSubtitle,
              ),
            ),
          )
        else
          for (final group in groups) _MarketSection(group: group, locale: locale),
      ],
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.l10n,
    required this.locale,
    required this.cartCount,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
      decoration: const BoxDecoration(
        color: GetirStyleDeliveryUiColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(GetirStyleDeliveryUiRadius.xxl),
        ),
      ),
      child: Row(
        children: [
          const ProfileMenuButton(color: GetirStyleDeliveryUiColors.onPrimary),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.navSearch,
                  style: GetirStyleDeliveryUiTypography.headlineSm(
                    locale,
                    color: GetirStyleDeliveryUiColors.secondaryContainer,
                  ).copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  l10n.searchPageSubtitle,
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.pushGetirStyleDeliveryUi(
              const CartScreen(),
              transition: GetirStyleDeliveryUiTransition.sharedAxisVertical,
            ),
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: GetirStyleDeliveryUiColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.locale,
    required this.hint,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Locale locale;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.12),
      color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: GetirStyleDeliveryUiTypography.bodyMd(locale),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GetirStyleDeliveryUiTypography.bodyMd(
            locale,
            color: SearchTheme.searchHint,
          ),
          prefixIcon: const Icon(Icons.search, color: GetirStyleDeliveryUiColors.primary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _MarketSection extends StatelessWidget {
  const _MarketSection({required this.group, required this.locale});

  final _VendorGroup group;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SearchTheme.margin,
            GetirStyleDeliveryUiSpacing.stackMd,
            SearchTheme.margin,
            10,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.primaryFixed,
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 18,
                  color: GetirStyleDeliveryUiColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: SearchTheme.resultTitle,
                  ),
                ),
              ),
              Text(
                '${group.items.length}',
                style: GetirStyleDeliveryUiTypography.labelSm(
                  locale,
                  color: SearchTheme.resultSubtitle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SearchTheme.margin),
            itemCount: group.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _ProductCard(item: group.items[index], locale: locale),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item, required this.locale});

  final ItemModel item;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
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
                height: 118,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlaceholderImage(
                      networkUrl: item.displayImageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.fastfood_outlined,
                    ),
                    if (item.rating > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius:
                                BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: GetirStyleDeliveryUiColors.secondaryContainer,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: GetirStyleDeliveryUiTypography.labelSm(
                                  locale,
                                  color: Colors.white,
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
                        color: SearchTheme.resultTitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatToman(item.price),
                      style: GetirStyleDeliveryUiTypography.labelLg(
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
