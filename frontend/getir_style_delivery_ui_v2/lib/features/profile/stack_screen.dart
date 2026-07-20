import 'package:flutter/material.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/theme/pages/profile_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import 'stack_detail_screen.dart';
import 'tech_stack_data.dart';

class StackScreen extends StatefulWidget {
  const StackScreen({super.key});

  @override
  State<StackScreen> createState() => _StackScreenState();
}

class _StackScreenState extends State<StackScreen> {
  int _page = 0;

  void _openDetail(TechStackItem item) {
    openStackDetail(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final items = techStackItems(l10n);
    final current = items[_page.clamp(0, items.length - 1)];

    return Scaffold(
      backgroundColor: ProfileTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: ProfileTheme.appBarBackground,
        foregroundColor: ProfileTheme.appBarForeground,
        title: Text(
          l10n.stack,
          style: GetirStyleDeliveryUiTypography.headlineMd(
            locale,
            color: ProfileTheme.appBarForeground,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GetirStyleDeliveryUiSpacing.marginMobile,
                GetirStyleDeliveryUiSpacing.stackSm,
                GetirStyleDeliveryUiSpacing.marginMobile,
                0,
              ),
              child: Text(
                l10n.swipeTechStack,
                textAlign: TextAlign.center,
                style: GetirStyleDeliveryUiTypography.bodySm(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: VerticalCardPager(
                titles: items.map((e) => e.title.toUpperCase()).toList(),
                images: [
                  for (final item in items)
                    GestureDetector(
                      onTap: () => _openDetail(item),
                      child: _TechCardImage(item: item),
                    ),
                ],
                onPageChanged: (page) =>
                    setState(() => _page = (page ?? 0).round()),
                onSelectedItem: (index) {
                  setState(() => _page = index);
                  _openDetail(items[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GetirStyleDeliveryUiSpacing.marginMobile,
                GetirStyleDeliveryUiSpacing.stackSm,
                GetirStyleDeliveryUiSpacing.marginMobile,
                GetirStyleDeliveryUiSpacing.stackSm,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  current.summary,
                  key: ValueKey(current.id),
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.bodyMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GetirStyleDeliveryUiSpacing.marginMobile,
                0,
                GetirStyleDeliveryUiSpacing.marginMobile,
                GetirStyleDeliveryUiSpacing.stackLg,
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                  ),
                ),
                onPressed: () => _openDetail(current),
                icon: const Icon(Icons.info_outline),
                label: Text(l10n.stackViewDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechCardImage extends StatelessWidget {
  const _TechCardImage({required this.item});

  final TechStackItem item;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'stack-${item.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.colors,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  item.icon,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              Center(
                child: Icon(item.icon, size: 72, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openStack(BuildContext context) {
  context.pushGetirStyleDeliveryUi(
    const StackScreen(),
    transition: GetirStyleDeliveryUiTransition.sharedAxisHorizontal,
  );
}
