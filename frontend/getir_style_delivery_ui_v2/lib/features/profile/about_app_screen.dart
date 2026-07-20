import 'package:flutter/material.dart';

import '../../core/config/app_info.dart';
import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/theme/pages/profile_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/getir_style_delivery_ui_logo_mark.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
          l10n.aboutApp,
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
          GetirStyleDeliveryUiSpacing.stackLg + GetirStyleDeliveryUiSpacing.marginMobile,
        ),
        children: [
          _HeroCard(locale: locale, subtitle: l10n.aboutAppHeroSubtitle),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
          _InfoCard(
            locale: locale,
            title: l10n.version,
            children: [
              _BetaBadge(locale: locale, label: l10n.betaPhase),
              const SizedBox(height: 12),
              Text(
                AppInfo.fullVersionLabel,
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.appTagline,
                style: GetirStyleDeliveryUiTypography.bodySm(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
          _InfoCard(
            locale: locale,
            title: l10n.aboutDeveloper,
            children: [
              _DeveloperTile(locale: locale, role: l10n.developerRole),
            ],
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          Text(
            l10n.aboutCopyright(DateTime.now().year, AppInfo.name),
            textAlign: TextAlign.center,
            style: GetirStyleDeliveryUiTypography.bodySm(
              locale,
              color: GetirStyleDeliveryUiColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.locale, required this.subtitle});

  final Locale locale;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GetirStyleDeliveryUiColors.primary, GetirStyleDeliveryUiColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const GetirStyleDeliveryUiLogoMark(showTagline: false),
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GetirStyleDeliveryUiTypography.bodySm(
              locale,
              color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge({required this.locale, required this.label});

  final Locale locale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.secondaryContainer,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.science_outlined,
            size: 16,
            color: GetirStyleDeliveryUiColors.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            '$label · v${AppInfo.version}',
            style: GetirStyleDeliveryUiTypography.labelMd(
              locale,
              color: GetirStyleDeliveryUiColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.locale,
    required this.title,
    required this.children,
  });

  final Locale locale;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileTheme.cardBackground,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GetirStyleDeliveryUiTypography.labelLg(
              locale,
              color: GetirStyleDeliveryUiColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  const _DeveloperTile({required this.locale, required this.role});

  final Locale locale;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GetirStyleDeliveryUiColors.primaryFixed, GetirStyleDeliveryUiColors.tertiaryFixed],
            ),
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
          ),
          child: const Icon(Icons.code_rounded, color: GetirStyleDeliveryUiColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppInfo.developerName,
                style: GetirStyleDeliveryUiTypography.labelLg(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: GetirStyleDeliveryUiTypography.bodySm(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppInfo.projectName,
                style: GetirStyleDeliveryUiTypography.labelSm(
                  locale,
                  color: GetirStyleDeliveryUiColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void openAboutApp(BuildContext context) {
  context.pushGetirStyleDeliveryUi(const AboutAppScreen());
}
