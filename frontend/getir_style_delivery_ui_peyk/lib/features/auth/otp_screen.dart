import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';

const _fa = Locale('fa');

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, this.debugCode});

  final String phone;
  final String? debugCode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.text.trim().length != 6 || _busy) return;
    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(widget.phone, _code.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'خطا')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.primaryContainer,
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
                ),
                child: Column(
                  children: [
                    Text(
                      'کد تأیید را وارد کنید',
                      style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimary)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'کد به \u{2066}${widget.phone}\u{2069} ارسال شد',
                      style: GetirStyleDeliveryUiTypography.bodyMd(
                        _fa,
                        color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    if (widget.debugCode != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: GetirStyleDeliveryUiColors.primary,
                          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                        ),
                        child: Text(
                          'کد تست: ${widget.debugCode}',
                          textDirection: TextDirection.ltr,
                          style: GetirStyleDeliveryUiTypography.headlineSm(
                            _fa,
                            color: GetirStyleDeliveryUiColors.secondaryContainer,
                          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.surface,
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                ),
                child: TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  maxLength: 6,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GetirStyleDeliveryUiTypography.headlineMd(_fa, color: GetirStyleDeliveryUiColors.onSurface)
                      .copyWith(fontWeight: FontWeight.w900, letterSpacing: 14),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    hintText: '------',
                  ),
                  onChanged: (v) {
                    if (v.length == 6) _verify();
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: GetirStyleDeliveryUiColors.secondaryContainer,
                    foregroundColor: GetirStyleDeliveryUiColors.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                    ),
                  ),
                  onPressed: _busy ? null : _verify,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('تأیید',
                          style: GetirStyleDeliveryUiTypography.labelLg(_fa,
                              color: GetirStyleDeliveryUiColors.onSecondaryContainer)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
