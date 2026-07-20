import 'package:flutter/material.dart';

import '../../core/theme/pages/profile_theme.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/profile_menu_body.dart';

/// Full-screen profile (e.g. deep links). Primary access is via [ProfileDrawer].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: ProfileTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: ProfileTheme.appBarBackground,
        foregroundColor: ProfileTheme.appBarForeground,
        centerTitle: true,
        elevation: 0,
        title: Text(
          l10n.profile,
          style: GetirStyleDeliveryUiTypography.headlineMd(
            locale,
            color: ProfileTheme.appBarForeground,
          ),
        ),
      ),
      body: const ProfileMenuBody(),
    );
  }
}
