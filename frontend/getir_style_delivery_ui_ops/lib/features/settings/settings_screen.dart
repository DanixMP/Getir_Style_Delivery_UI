import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import 'settings_widgets.dart';

const _fa = Locale('fa');

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isVendor = user?.role == 'vendor';
    final extra = isVendor && user!.vendorCity.isNotEmpty ? 'شهر: ${user.vendorCity}' : null;

    return ListView(
      padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
      children: [
        ProfileHeaderCard(
          user: user,
          roleLabel: roleLabelFa(user?.role),
          extraLine: extra,
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        SettingsSection(
          title: 'حساب کاربری',
          children: [
            SettingsTile(
              icon: Icons.person_outline,
              title: 'ویرایش پروفایل',
              subtitle: 'نام، ایمیل و شهر',
              onTap: () => openEditProfile(context),
            ),
            if (isVendor && user!.vendorBusinessName.isNotEmpty)
              SettingsTile(
                icon: Icons.storefront_outlined,
                title: 'نام فروشگاه',
                subtitle: user.vendorBusinessName,
              ),
          ],
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        SettingsSection(
          title: 'ظاهر',
          children: const [ThemeToggleTile()],
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        SettingsSection(
          title: 'درباره',
          children: [
            SettingsTile(
              icon: Icons.info_outline,
              title: 'GETIR_STYLE_DELIVERY_UI Ops',
              subtitle: 'نسخه ۱.۰.۰',
            ),
          ],
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        const LogoutButton(),
      ],
    );
  }
}

/// App bar title for the settings tab inside dashboards.
class SettingsTabScaffold extends StatelessWidget {
  const SettingsTabScaffold({super.key, required this.appBarTitle});

  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(appBarTitle, style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
      ),
      body: const SettingsScreen(),
    );
  }
}
