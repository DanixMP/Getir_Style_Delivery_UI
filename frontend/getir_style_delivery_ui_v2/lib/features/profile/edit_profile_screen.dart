import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/preset_avatar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_avatar_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/avatar_picker_row.dart';
import '../../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _city;
  bool _saving = false;
  late String _selectedAvatarId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final avatars = context.read<ProfileAvatarProvider>();
    final user = auth.user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    _selectedAvatarId = avatars.avatarIdFor(user?.id);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final avatars = context.read<ProfileAvatarProvider>();
    final userId = auth.user?.id;

    final ok = await auth.updateProfile(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      city: _city.text.trim(),
    );
    if (ok && userId != null) {
      await avatars.setAvatar(userId, _selectedAvatarId);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? l10n.profileUpdated : l10n.profileUpdateFailed),
    ));
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final user = context.watch<AuthProvider>().user;
    final preset = PresetAvatar.byId(_selectedAvatarId);

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text(
          l10n.editProfile,
          style: GetirStyleDeliveryUiTypography.headlineMd(locale, color: GetirStyleDeliveryUiColors.onPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
            decoration: BoxDecoration(
              color: GetirStyleDeliveryUiColors.primaryFixed,
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
            ),
            child: Column(
              children: [
                ProfileAvatar(
                  preset: preset,
                  size: 96,
                  showBorder: true,
                  selected: true,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.phone ?? '',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.bodyMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
                const SizedBox(height: 20),
                AvatarPickerRow(
                  selectedId: _selectedAvatarId,
                  onSelected: (id) => setState(() => _selectedAvatarId = id),
                  locale: locale,
                  label: l10n.selectAvatar,
                ),
              ],
            ),
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
          _FieldLabel(text: l10n.fullName, locale: locale),
          const SizedBox(height: 8),
          _Field(controller: _name, icon: Icons.person_outline, hint: l10n.yourName),
          const SizedBox(height: 16),
          _FieldLabel(text: l10n.email, locale: locale),
          const SizedBox(height: 8),
          _Field(
            controller: _email,
            icon: Icons.email_outlined,
            hint: 'example@mail.com',
            ltr: true,
          ),
          const SizedBox(height: 16),
          _FieldLabel(text: l10n.city, locale: locale),
          const SizedBox(height: 8),
          _Field(controller: _city, icon: Icons.location_city_outlined, hint: l10n.city),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
              ),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: GetirStyleDeliveryUiColors.onPrimary),
                  )
                : Text(
                    l10n.saveChanges,
                    style: GetirStyleDeliveryUiTypography.labelLg(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.locale});

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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.icon,
    required this.hint,
    this.ltr = false,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: ltr ? TextDirection.ltr : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: GetirStyleDeliveryUiColors.primary),
        filled: true,
        fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
          borderSide: const BorderSide(color: GetirStyleDeliveryUiColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
