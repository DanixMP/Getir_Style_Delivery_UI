import 'package:flutter/material.dart';

import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text(
          l10n.support,
          style: GetirStyleDeliveryUiTypography.headlineMd(locale, color: GetirStyleDeliveryUiColors.onPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
        children: [
          // Hero.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GetirStyleDeliveryUiColors.primaryFixed,
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic,
                      size: 44, color: GetirStyleDeliveryUiColors.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.supportHeroTitle,
                  style: GetirStyleDeliveryUiTypography.headlineSm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.supportHeroSubtitle,
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          _SectionLabel(text: l10n.contactMethods, locale: locale),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
          _ContactTile(
            icon: Icons.phone,
            title: l10n.phoneContact,
            value: '۰۲۱-۹۱۰۰۰۰۰۰',
            locale: locale,
          ),
          _ContactTile(
            icon: Icons.email_outlined,
            title: l10n.emailContact,
            value: 'support@getir_style_delivery_ui.app',
            locale: locale,
          ),
          _ContactTile(
            icon: Icons.chat_bubble_outline,
            title: l10n.onlineChat,
            value: l10n.onlineChatValue,
            locale: locale,
          ),
          _ContactTile(
            icon: Icons.access_time,
            title: l10n.businessHours,
            value: l10n.businessHoursValue,
            locale: locale,
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          _SectionLabel(text: l10n.faqTitle, locale: locale),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
          _FaqTile(
            question: l10n.faqTrackOrderQ,
            answer: l10n.faqTrackOrderA,
            locale: locale,
          ),
          _FaqTile(
            question: l10n.faqPaymentQ,
            answer: l10n.faqPaymentA,
            locale: locale,
          ),
          _FaqTile(
            question: l10n.faqAddressQ,
            answer: l10n.faqAddressA,
            locale: locale,
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
    return Text(
      text,
      style: GetirStyleDeliveryUiTypography.labelMd(locale, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.locale,
  });

  final IconData icon;
  final String title;
  final String value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: GetirStyleDeliveryUiColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GetirStyleDeliveryUiTypography.labelMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
                Text(
                  value,
                  textDirection: TextDirection.ltr,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
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

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.locale,
  });

  final String question;
  final String answer;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: GetirStyleDeliveryUiColors.primary,
          collapsedIconColor: GetirStyleDeliveryUiColors.primary,
          title: Text(
            question,
            style: GetirStyleDeliveryUiTypography.labelLg(locale, color: GetirStyleDeliveryUiColors.onSurface),
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                answer,
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
