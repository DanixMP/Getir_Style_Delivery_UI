import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/pages/login_theme.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ltr_input_scope.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.displayPhone,
    this.debugCode,
  });

  /// Normalized API phone (e.g. 09123456789).
  final String phone;
  final String displayPhone;
  final String? debugCode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  bool _submitting = false;

  Future<void> _verify() async {
    if (_otp.length != 6 || _submitting) return;
    setState(() => _submitting = true);
    final ok = await context.read<AuthProvider>().verifyOtp(widget.phone, _otp);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().error ?? '')),
      );
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final code = await context.read<AuthProvider>().requestOtp(widget.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          code != null
              ? l10n.devOtpSnackbar(code)
              : context.read<AuthProvider>().error ?? l10n.genericError,
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: LoginTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: LoginTheme.taglineColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LoginTheme.padding),
          child: Column(
            children: [
              // Copy grouped in a rounded panel that matches the app's card
              // style while keeping the purple palette.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(LoginTheme.cardPadding),
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.primaryContainer,
                  borderRadius: BorderRadius.circular(LoginTheme.cardRadius),
                  border: Border.all(
                    color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.enterOtp,
                      textAlign: TextAlign.center,
                      style: GetirStyleDeliveryUiTypography.headlineMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      // U+2066 (LRI) .. U+2069 (PDI) isolates the phone so the
                      // +98 and digits render left-to-right in the RTL sentence.
                      l10n.otpSent('\u{2066}${widget.displayPhone}\u{2069}'),
                      textAlign: TextAlign.center,
                      style: GetirStyleDeliveryUiTypography.bodyMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    if (widget.debugCode != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: GetirStyleDeliveryUiColors.primary,
                          borderRadius:
                              BorderRadius.circular(LoginTheme.inputRadius),
                          border: Border.all(
                            color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.devOtpLabel,
                              style: GetirStyleDeliveryUiTypography.labelSm(
                                locale,
                                color:
                                    GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.debugCode!,
                              textDirection: TextDirection.ltr,
                              style: GetirStyleDeliveryUiTypography.headlineMd(
                                locale,
                                color: GetirStyleDeliveryUiColors.secondaryContainer,
                              ).copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      l10n.betaOtpHint,
                      textAlign: TextAlign.center,
                      style: GetirStyleDeliveryUiTypography.labelSm(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              LtrInputScope(
                child: MaterialPinField(
                  length: 6,
                  keyboardType: TextInputType.number,
                  theme: MaterialPinTheme(
                    shape: MaterialPinShape.filled,
                    cellSize: const Size(48, 56),
                    spacing: 8,
                    borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
                    fillColor: LoginTheme.otpInactiveFill,
                    focusedFillColor: LoginTheme.otpActiveFill,
                    borderColor: LoginTheme.otpBorder,
                    focusedBorderColor: LoginTheme.continueButtonBackground,
                    textStyle: GetirStyleDeliveryUiTypography.headlineSm(locale),
                  ),
                  onChanged: (v) => _otp = v,
                  onCompleted: (_) => _verify(),
                ),
              ),
              const SizedBox(height: 24),
              ShadButton(
                width: double.infinity,
                height: 56,
                onPressed: _otp.length == 6 && !_submitting ? _verify : null,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.verify),
              ),
              TextButton(
                onPressed: _resend,
                child: Text(l10n.resendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
