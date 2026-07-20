import 'package:flutter/material.dart';

import '../../core/theme/pages/profile_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import 'tech_stack_data.dart';

class StackDetailScreen extends StatelessWidget {
  const StackDetailScreen({super.key, required this.item});

  final TechStackItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: ProfileTheme.screenBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: item.colors.first,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                item.title,
                style: GetirStyleDeliveryUiTypography.labelLg(locale, color: Colors.white),
              ),
              background: Hero(
                tag: 'stack-${item.id}',
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
                        right: -24,
                        bottom: -24,
                        child: Icon(
                          item.icon,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Center(
                        child: Icon(item.icon, size: 72, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              GetirStyleDeliveryUiSpacing.marginMobile,
              GetirStyleDeliveryUiSpacing.stackLg,
              GetirStyleDeliveryUiSpacing.marginMobile,
              GetirStyleDeliveryUiSpacing.stackLg,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  item.summary,
                  style: GetirStyleDeliveryUiTypography.headlineSm(
                    locale,
                    color: ProfileTheme.menuTitle,
                  ),
                ),
                const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                Text(
                  item.detail,
                  style: GetirStyleDeliveryUiTypography.bodyMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                _SectionLabel(text: l10n.stackPackagesLabel, locale: locale),
                const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final pkg in item.packages)
                      Chip(
                        label: Text(
                          pkg,
                          style: GetirStyleDeliveryUiTypography.labelSm(
                            locale,
                            color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                          ),
                        ),
                        backgroundColor: GetirStyleDeliveryUiColors.primaryFixed,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                  ],
                ),
                const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                _SectionLabel(text: l10n.stackUsedInLabel, locale: locale),
                const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
                ...item.usedIn.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: GetirStyleDeliveryUiColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            line,
                            style: GetirStyleDeliveryUiTypography.bodyMd(
                              locale,
                              color: GetirStyleDeliveryUiColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: GetirStyleDeliveryUiColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GetirStyleDeliveryUiTypography.labelLg(
            locale,
            color: GetirStyleDeliveryUiColors.onSurface,
          ),
        ),
      ],
    );
  }
}

void openStackDetail(BuildContext context, TechStackItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StackDetailScreen(item: item),
    ),
  );
}
