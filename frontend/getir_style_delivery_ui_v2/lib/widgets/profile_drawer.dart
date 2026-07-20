import 'package:flutter/material.dart';

import '../core/theme/pages/profile_theme.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../l10n/app_localizations.dart';
import 'profile_menu_body.dart';

/// Side panel with account, settings, and profile actions.
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final width = MediaQuery.sizeOf(context).width * 0.88;

    return Drawer(
      width: width.clamp(280.0, 420.0),
      backgroundColor: ProfileTheme.screenBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: GetirStyleDeliveryUiColors.primary,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: GetirStyleDeliveryUiColors.onPrimary,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          l10n.profile,
                          style: GetirStyleDeliveryUiTypography.labelLg(
                            locale,
                            color: GetirStyleDeliveryUiColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ProfileMenuBody(
              onBeforeNavigate: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
