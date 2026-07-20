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

    return Scaffold(
      appBar: AppBar(
        title: Text('تنظیمات', style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
        children: [
          ProfileHeaderCard(user: user),
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
                title: 'GETIR_STYLE_DELIVERY_UI پیک',
                subtitle: 'نسخه ۱.۰.۰',
              ),
            ],
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          const LogoutButton(),
        ],
      ),
    );
  }
}
