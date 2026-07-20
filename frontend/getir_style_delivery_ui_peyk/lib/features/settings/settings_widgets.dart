import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../data/models/user_model.dart';
import 'edit_profile_screen.dart';

const _fa = Locale('fa');

/// Shared settings tiles and section chrome for Peyk settings UI.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: GetirStyleDeliveryUiSpacing.stackSm),
          child: Row(
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
              Text(title, style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: onSurface)),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
          side: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.primaryFixed,
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                  ),
                  child: Icon(icon, size: 22, color: GetirStyleDeliveryUiColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: onSurface)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GetirStyleDeliveryUiTypography.bodySm(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
                if (onTap != null)
                  const Icon(Icons.chevron_left, color: GetirStyleDeliveryUiColors.outline, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.user, this.roleLabel = 'پیک'});

  final UserModel? user;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'کاربر';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GetirStyleDeliveryUiColors.primaryFixed, Color(0xFFF3EEFF)],
        ),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: GetirStyleDeliveryUiColors.primary,
            child: Text(
              name.isNotEmpty ? name[0] : 'پ',
              style: GetirStyleDeliveryUiTypography.headlineMd(_fa, color: GetirStyleDeliveryUiColors.onPrimary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixed),
          ),
          if (user?.phone.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              user!.phone,
              textDirection: TextDirection.ltr,
              style: GetirStyleDeliveryUiTypography.bodySm(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
            ),
            child: Text(roleLabel, style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.primary)),
          ),
        ],
      ),
    );
  }
}

class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return SettingsTile(
      icon: theme.isDark ? Icons.dark_mode : Icons.light_mode,
      title: 'تم تاریک',
      subtitle: theme.isDark ? 'فعال' : 'غیرفعال',
      trailing: Switch(
        value: theme.isDark,
        activeTrackColor: GetirStyleDeliveryUiColors.primary,
        onChanged: (v) => context.read<ThemeProvider>().setDark(v),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('خروج از حساب', style: GetirStyleDeliveryUiTypography.headlineSm(_fa)),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید خارج شوید؟',
          style: GetirStyleDeliveryUiTypography.bodyMd(_fa),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GetirStyleDeliveryUiColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GetirStyleDeliveryUiColors.errorContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _confirm(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, size: 20, color: GetirStyleDeliveryUiColors.error),
              const SizedBox(width: 8),
              Text('خروج از حساب', style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigates to [EditProfileScreen].
void openEditProfile(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
  );
}
