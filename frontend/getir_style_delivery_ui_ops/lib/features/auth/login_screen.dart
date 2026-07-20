import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import 'otp_screen.dart';

const _fa = Locale('fa');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  String get _normalizedPhone {
    final d = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (d.length == 10 && !d.startsWith('0')) return '0$d';
    return d;
  }

  Future<void> _passwordLogin() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await context.read<AuthProvider>().login(_normalizedPhone, _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) _snack(context.read<AuthProvider>().error ?? 'ورود ناموفق');
  }

  Future<void> _otpLogin() async {
    if (_busy) return;
    setState(() => _busy = true);
    final code = await context.read<AuthProvider>().requestOtp(_normalizedPhone);
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OtpScreen(phone: _normalizedPhone, debugCode: code),
    ));
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('GetirStyleDeliveryUi Ops',
                    style: GetirStyleDeliveryUiTypography.headlineLg(_fa, color: GetirStyleDeliveryUiColors.onPrimary)
                        .copyWith(fontWeight: FontWeight.w900, fontSize: 40)),
                const SizedBox(height: 4),
                Text('کنسول اپراتور و فروشنده',
                    style: GetirStyleDeliveryUiTypography.bodyMd(
                        _fa, color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85))),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.surface,
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
                  ),
                  child: Column(
                    children: [
                      _Field(controller: _phone, label: 'شماره موبایل', ltr: true,
                          keyboard: TextInputType.phone),
                      const SizedBox(height: 12),
                      _Field(controller: _password, label: 'رمز عبور', obscure: true),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: GetirStyleDeliveryUiColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl)),
                          ),
                          onPressed: _busy ? null : _passwordLogin,
                          child: _busy
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text('ورود',
                                  style: GetirStyleDeliveryUiTypography.labelLg(
                                      _fa, color: GetirStyleDeliveryUiColors.onPrimary)),
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _otpLogin,
                        child: const Text('ورود با کد یکبارمصرف'),
                      ),
                    ],
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.ltr = false,
    this.keyboard,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final bool ltr;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textDirection: ltr ? TextDirection.ltr : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
