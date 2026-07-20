import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';

const _fa = Locale('fa');

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

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _city = TextEditingController(text: user?.city ?? '');
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
    final ok = await context.read<AuthProvider>().updateProfile(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          city: _city.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? 'پروفایل به‌روزرسانی شد' : 'به‌روزرسانی ناموفق بود'),
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isVendor = user?.role == 'vendor';

    return Scaffold(
      appBar: AppBar(
        title: Text('ویرایش پروفایل', style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'نام و نام خانوادگی',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: user?.phone ?? ''),
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'شماره موبایل',
              helperText: 'شماره موبایل قابل تغییر نیست',
              filled: true,
              fillColor: GetirStyleDeliveryUiColors.surfaceContainer,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'ایمیل (اختیاری)',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _city,
            decoration: InputDecoration(
              labelText: 'شهر',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
            ),
          ),
          if (isVendor && user!.vendorBusinessName.isNotEmpty) ...[
            const SizedBox(height: 14),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: user.vendorBusinessName),
              decoration: InputDecoration(
                labelText: 'نام فروشگاه',
                helperText: 'از پنل مدیریت قابل تغییر است',
                filled: true,
                fillColor: GetirStyleDeliveryUiColors.surfaceContainer,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('ذخیره', style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
          ),
          const SizedBox(height: 8),
          Text(
            'اطلاعات حساب از سرور GETIR_STYLE_DELIVERY_UI همگام‌سازی می‌شود.',
            textAlign: TextAlign.center,
            style: GetirStyleDeliveryUiTypography.bodySm(_fa, color: onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
