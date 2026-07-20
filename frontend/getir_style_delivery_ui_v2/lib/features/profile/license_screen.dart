import 'package:flutter/material.dart';

import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/theme/pages/profile_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: ProfileTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: ProfileTheme.appBarBackground,
        foregroundColor: ProfileTheme.appBarForeground,
        title: Text(
          l10n.license,
          style: GetirStyleDeliveryUiTypography.headlineMd(
            locale,
            color: ProfileTheme.appBarForeground,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GetirStyleDeliveryUiSpacing.marginMobile,
          GetirStyleDeliveryUiSpacing.stackLg,
          GetirStyleDeliveryUiSpacing.marginMobile,
          GetirStyleDeliveryUiSpacing.stackLg +
              GetirStyleDeliveryUiSpacing.marginMobile,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
              borderRadius:
                  BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
              border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      color: GetirStyleDeliveryUiColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.licenseTitle,
                        style: GetirStyleDeliveryUiTypography.headlineSm(
                          locale,
                          color: GetirStyleDeliveryUiColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                Text(
                  l10n.licenseBody,
                  style: GetirStyleDeliveryUiTypography.bodyMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                  ).copyWith(height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void openLicense(BuildContext context) {
  context.pushGetirStyleDeliveryUi(
    const LicenseScreen(),
    transition: GetirStyleDeliveryUiTransition.sharedAxisHorizontal,
  );
}
