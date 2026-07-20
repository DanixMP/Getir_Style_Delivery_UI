import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_info.dart';
import '../core/models/preset_avatar.dart';
import '../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/profile_avatar_provider.dart';
import '../core/theme/pages/profile_theme.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../core/theme/getir_style_delivery_ui_spacing.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../core/utils/dev_access.dart';
import '../features/address/address_manager_sheet.dart';
import '../features/debug/debug_screen.dart';
import '../features/profile/about_app_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/license_screen.dart';
import '../features/profile/orders_screen.dart';
import '../features/profile/stack_screen.dart';
import '../features/profile/support_screen.dart';
import '../l10n/app_localizations.dart';
import 'language_picker_sheet.dart';
import 'profile_ai_banner.dart';
import 'profile_avatar.dart';

/// Profile account menu — used in the side drawer and full profile screen.
class ProfileMenuBody extends StatefulWidget {
  const ProfileMenuBody({
    super.key,
    this.onBeforeNavigate,
    this.showCloseButton = false,
    this.onClose,
  });

  /// Called before pushing a sub-screen (e.g. to close the drawer).
  final VoidCallback? onBeforeNavigate;

  final bool showCloseButton;
  final VoidCallback? onClose;

  @override
  State<ProfileMenuBody> createState() => _ProfileMenuBodyState();
}

class _ProfileMenuBodyState extends State<ProfileMenuBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 880),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _navigate(Widget screen, {GetirStyleDeliveryUiTransition transition = GetirStyleDeliveryUiTransition.sharedAxisHorizontal}) {
    widget.onBeforeNavigate?.call();
    context.pushGetirStyleDeliveryUi(screen, transition: transition);
  }

  String _langLabel(AppLocalizations l10n, Locale locale) =>
      switch (locale.languageCode) {
        'fa' => l10n.langPersian,
        'ar' => l10n.langArabic,
        'tr' => l10n.langTurkish,
        _ => l10n.langEnglish,
      };

  Interval _interval(int index, {double span = 0.34}) {
    final start = index * 0.07;
    return Interval(start, (start + span).clamp(0.0, 1.0), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final user = context.watch<AuthProvider>().user;
    final devTools = showDevTools(user);
    final avatar =
        context.watch<ProfileAvatarProvider>().avatarFor(user?.id);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView(
      cacheExtent: 480,
      padding: EdgeInsets.fromLTRB(
        GetirStyleDeliveryUiSpacing.marginMobile,
        widget.showCloseButton ? 8 : GetirStyleDeliveryUiSpacing.stackMd,
        GetirStyleDeliveryUiSpacing.marginMobile,
        bottomInset + GetirStyleDeliveryUiSpacing.stackLg,
      ),
      children: [
        if (widget.showCloseButton)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              icon: const Icon(Icons.close),
              color: ProfileTheme.menuTitle,
              onPressed: widget.onClose,
            ),
          ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(0),
          child: _ProfileHeader(
            name: user?.fullName.isNotEmpty == true ? user!.fullName : l10n.login,
            phone: user?.phone ?? '',
            locale: locale,
            avatar: avatar,
            onEdit: () => _navigate(const EditProfileScreen()),
          ),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(1),
          child: ProfileAiBanner(locale: locale),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(2),
          child: _SectionTitle(text: l10n.accountSection, locale: locale),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(3),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.person_outline_rounded,
            title: l10n.editProfile,
            subtitle: l10n.editProfileSubtitle,
            onTap: () => _navigate(const EditProfileScreen()),
          ),
        ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(4),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.receipt_long_outlined,
            title: l10n.myOrders,
            subtitle: l10n.myOrdersSubtitle,
            onTap: () {
              widget.onBeforeNavigate?.call();
              context.pushGetirStyleDeliveryUi(const OrdersScreen());
            },
          ),
        ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(5),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.location_on_outlined,
            title: l10n.myAddresses,
            subtitle: l10n.addressManageSubtitle,
            onTap: () {
              widget.onBeforeNavigate?.call();
              showAddressManager(context);
            },
          ),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(6),
          child: _SectionTitle(text: l10n.settingsSection, locale: locale),
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(7),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.language_rounded,
            title: l10n.language,
            trailing: _LangChip(label: _langLabel(l10n, locale), locale: locale),
            onTap: () {
              widget.onBeforeNavigate?.call();
              showModalBottomSheet(
                context: context,
                builder: (_) => const LanguagePickerSheet(),
              );
            },
          ),
        ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(8),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.help_outline_rounded,
            title: l10n.support,
            subtitle: l10n.supportSubtitle,
            onTap: () {
              widget.onBeforeNavigate?.call();
              context.pushGetirStyleDeliveryUi(const SupportScreen());
            },
          ),
        ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(9),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.layers_outlined,
            title: l10n.stack,
            subtitle: l10n.stackSubtitle,
            onTap: () {
              widget.onBeforeNavigate?.call();
              openStack(context);
            },
          ),
        ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(10),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.gavel_rounded,
            title: l10n.license,
            subtitle: l10n.licenseSubtitle,
            onTap: () {
              widget.onBeforeNavigate?.call();
              openLicense(context);
            },
          ),
        ),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(11),
          child: _ProfileTile(
            locale: locale,
            icon: Icons.info_outline_rounded,
            title: l10n.aboutApp,
            subtitle: '${l10n.betaPhase} · v${AppInfo.version}',
            trailing: _BetaChip(locale: locale, label: l10n.betaPhase),
            onTap: () {
              widget.onBeforeNavigate?.call();
              openAboutApp(context);
            },
          ),
        ),
        if (devTools)
          _AnimatedSection(
            animation: _entrance,
            interval: _interval(12),
            child: _ProfileTile(
              locale: locale,
              icon: Icons.bug_report_outlined,
              title: l10n.devDebugTitle,
              subtitle: l10n.devDebugSubtitle,
              onTap: () => _navigate(const DebugScreen()),
            ),
          ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
        _AnimatedSection(
          animation: _entrance,
          interval: _interval(13, span: 0.4),
          child: _SignOutButton(
            locale: locale,
            label: l10n.signOut,
            onPressed: () {
              widget.onBeforeNavigate?.call();
              context.read<AuthProvider>().logout();
            },
          ),
        ),
      ],
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.animation,
    required this.interval,
    required this.child,
  });

  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = interval.transform(animation.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.locale,
    required this.avatar,
    required this.onEdit,
  });

  final String name;
  final String phone;
  final Locale locale;
  final PresetAvatar avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GetirStyleDeliveryUiColors.primaryFixed, Color(0xFFF3EEFF)],
        ),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              ProfileAvatar(preset: avatar, size: 92, showBorder: true),
              const SizedBox(height: 16),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GetirStyleDeliveryUiTypography.headlineSm(
                  locale,
                  color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                ),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.surfaceContainerLowest
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                  ),
                  child: Text(
                    phone,
                    textDirection: TextDirection.ltr,
                    style: GetirStyleDeliveryUiTypography.bodySm(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Material(
              color: GetirStyleDeliveryUiColors.primary,
              elevation: 2,
              shadowColor: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.4),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.edit_rounded,
                      color: GetirStyleDeliveryUiColors.onPrimary, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          text,
          style: GetirStyleDeliveryUiTypography.labelLg(
            locale,
            color: GetirStyleDeliveryUiColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.locale,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final Locale locale;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: ProfileTheme.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
          side: const BorderSide(color: GetirStyleDeliveryUiColors.outlineVariant, width: 0.5),
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
                      Text(
                        title,
                        style: GetirStyleDeliveryUiTypography.labelLg(
                          locale,
                          color: ProfileTheme.menuTitle,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GetirStyleDeliveryUiTypography.bodySm(
                            locale,
                            color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 6),
                ],
                const Icon(Icons.chevron_left,
                    color: ProfileTheme.chevron, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.locale});

  final String label;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      ),
      child: Text(
        label,
        style: GetirStyleDeliveryUiTypography.labelSm(
          locale,
          color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
        ),
      ),
    );
  }
}

class _BetaChip extends StatelessWidget {
  const _BetaChip({required this.locale, required this.label});

  final Locale locale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.secondaryContainer,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      ),
      child: Text(
        label,
        style: GetirStyleDeliveryUiTypography.labelSm(
          locale,
          color: GetirStyleDeliveryUiColors.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({
    required this.locale,
    required this.label,
    required this.onPressed,
  });

  final Locale locale;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GetirStyleDeliveryUiColors.errorContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded,
                  size: 20, color: GetirStyleDeliveryUiColors.error),
              const SizedBox(width: 8),
              Text(
                label,
                style: GetirStyleDeliveryUiTypography.labelLg(
                  locale,
                  color: GetirStyleDeliveryUiColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
