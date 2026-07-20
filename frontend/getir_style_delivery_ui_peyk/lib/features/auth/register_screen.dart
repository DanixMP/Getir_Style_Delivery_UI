import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';

const _fa = Locale('fa');

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String _vehicle = 'motor';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().length < 10 ||
        _password.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('همه فیلدها را کامل کنید (رمز حداقل ۶ کاراکتر).')),
      );
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.registerPeyk(
      phone: _phone.text.trim(),
      password: _password.text.trim(),
      fullName: _name.text.trim(),
      vehicleType: _vehicle,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ثبت‌نام انجام شد. اکنون با کد ورود وارد شوید.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'خطا')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text('ثبت‌نام پیک',
            style: GetirStyleDeliveryUiTypography.headlineMd(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'نام و نام خانوادگی', Icons.person_outline),
          const SizedBox(height: 12),
          _field(_phone, 'شماره موبایل (09...)', Icons.phone, ltr: true),
          const SizedBox(height: 12),
          _field(_password, 'رمز عبور', Icons.lock_outline, obscure: true),
          const SizedBox(height: 16),
          Text('نوع وسیله', style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              _vehicleChip('motor', 'موتور', Icons.two_wheeler),
              const SizedBox(width: 10),
              _vehicleChip('car', 'خودرو', Icons.directions_car),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
              ),
            ),
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: GetirStyleDeliveryUiColors.onPrimary))
                : Text('ثبت‌نام', style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool obscure = false, bool ltr = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      textDirection: ltr ? TextDirection.ltr : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: GetirStyleDeliveryUiColors.primary),
        filled: true,
        fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _vehicleChip(String value, String label, IconData icon) {
    final selected = _vehicle == value;
    return Expanded(
      child: Material(
        color: selected ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _vehicle = value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: selected ? GetirStyleDeliveryUiColors.onPrimary : GetirStyleDeliveryUiColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    _fa,
                    color: selected ? GetirStyleDeliveryUiColors.onPrimary : GetirStyleDeliveryUiColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
