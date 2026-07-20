import 'package:flutter/material.dart';

import '../../core/theme/pages/promotions_theme.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/getir_style_delivery_ui_app_bar.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: PromotionsTheme.screenBackground,
      appBar: GetirStyleDeliveryUiAppBar(
        backgroundColor: PromotionsTheme.appBarBackground,
        foregroundColor: PromotionsTheme.appBarForeground,
        titleColor: PromotionsTheme.appBarTitle,
      ),
      body: Column(
        children: [
          Container(
            color: PromotionsTheme.tabBarBackground,
            child: Row(
              children: [
                _TabButton(
                  label: l10n.promotions,
                  active: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                  locale: locale,
                ),
                _TabButton(
                  label: l10n.whatsNew,
                  active: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                  locale: locale,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(PromotionsTheme.margin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 48,
                      color: PromotionsTheme.cardSubtitle,
                    ),
                    const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
                    Text(
                      l10n.noPromotions,
                      textAlign: TextAlign.center,
                      style: GetirStyleDeliveryUiTypography.bodyMd(
                        locale,
                        color: PromotionsTheme.cardSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
    required this.locale,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active
                    ? PromotionsTheme.tabIndicator
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GetirStyleDeliveryUiTypography.labelLg(
              locale,
              color: active
                  ? PromotionsTheme.tabActive
                  : PromotionsTheme.tabInactive,
            ),
          ),
        ),
      ),
    );
  }
}
