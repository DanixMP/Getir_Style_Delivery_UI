import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

const _fa = Locale('fa');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phone.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شماره موبایل معتبر وارد کنید.')),
      );
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final code = await auth.requestOtp(phone);
    if (!mounted) return;
    setState(() => _busy = false);
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OtpScreen(phone: phone, debugCode: code),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delivery_dining, size: 72, color: GetirStyleDeliveryUiColors.onPrimary),
              const SizedBox(height: 12),
              Text(
                'GETIR_STYLE_DELIVERY_UI پیک',
                style: GetirStyleDeliveryUiTypography.headlineLg(_fa, color: GetirStyleDeliveryUiColors.onPrimary)
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                'ورود پیک‌ها',
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  _fa,
                  color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.surface,
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'شماره موبایل',
                      style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: '09xxxxxxxxx',
                        prefixIcon: const Icon(Icons.phone, color: GetirStyleDeliveryUiColors.primary),
                        filled: true,
                        fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: GetirStyleDeliveryUiColors.primary,
                        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                        ),
                      ),
                      onPressed: _busy ? null : _requestOtp,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: GetirStyleDeliveryUiColors.onPrimary),
                            )
                          : Text('ارسال کد', style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('ثبت‌نام پیک جدید'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
