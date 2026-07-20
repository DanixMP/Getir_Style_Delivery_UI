import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../features/settings/edit_profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/settings_widgets.dart';

const _fa = Locale('fa');

/// Side menu for quick access to account and app settings from the Peyk home screen.
class PeykSettingsDrawer extends StatelessWidget {
  const PeykSettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = context.watch<ThemeProvider>();

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            ProfileHeaderCard(user: user),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline, color: GetirStyleDeliveryUiColors.primary),
              title: Text('ویرایش پروفایل', style: GetirStyleDeliveryUiTypography.labelLg(_fa)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                theme.isDark ? Icons.dark_mode : Icons.light_mode,
                color: GetirStyleDeliveryUiColors.primary,
              ),
              title: Text('تم تاریک', style: GetirStyleDeliveryUiTypography.labelLg(_fa)),
              trailing: Switch(
                value: theme.isDark,
                activeTrackColor: GetirStyleDeliveryUiColors.primary,
                onChanged: (v) => context.read<ThemeProvider>().setDark(v),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: GetirStyleDeliveryUiColors.primary),
              title: Text('همه تنظیمات', style: GetirStyleDeliveryUiTypography.labelLg(_fa)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: GetirStyleDeliveryUiColors.primary),
              title: Text('درباره GETIR_STYLE_DELIVERY_UI پیک', style: GetirStyleDeliveryUiTypography.labelLg(_fa)),
              subtitle: Text('نسخه ۱.۰.۰', style: GetirStyleDeliveryUiTypography.bodySm(_fa)),
            ),
            const SizedBox(height: 16),
            Material(
              color: GetirStyleDeliveryUiColors.errorContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.logout, color: GetirStyleDeliveryUiColors.error),
                title: Text('خروج', style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
