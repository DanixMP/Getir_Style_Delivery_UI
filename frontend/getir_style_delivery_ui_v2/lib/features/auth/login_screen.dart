import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/config/app_config.dart';
import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/pages/login_theme.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/getir_style_delivery_ui_logo_mark.dart';
import '../../widgets/ltr_input_scope.dart';
import '../../widgets/phone_input_field.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  Country _selectedCountry = Country.parse('IR');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _isPhoneValid {
    if (_selectedCountry.countryCode == 'IR') {
      return _phoneDigits.length == 10;
    }
    return _phoneDigits.length >= 7 && _phoneDigits.length <= 15;
  }

  Future<void> _continue() async {
    if (!_isPhoneValid || _submitting) return;
    setState(() => _submitting = true);
    final phone = normalizeIranPhone(
      '+${_selectedCountry.phoneCode}',
      _phoneDigits,
    );
    final debugCode = await context.read<AuthProvider>().requestOtp(phone);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (debugCode == null && context.read<AuthProvider>().error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().error ?? '')),
      );
      return;
    }
    if (debugCode != null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.devOtpSnackbar(debugCode)),
          duration: const Duration(seconds: 30),
        ),
      );
    }
    final display = '+${_selectedCountry.phoneCode} $_phoneDigits';
    context.pushGetirStyleDeliveryUi(
      OtpScreen(
        phone: phone,
        displayPhone: display,
        debugCode: debugCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: LoginTheme.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: LoginTheme.padding),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const GetirStyleDeliveryUiLogoMark(
                size: 0.85,
                onDarkBackground: false,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(LoginTheme.cardPadding),
                decoration: BoxDecoration(
                  color: LoginTheme.cardBackground.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LoginTheme.cardRadius),
                  border: Border.all(
                    color: LoginTheme.cardForeground.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(l10n.welcomeBack, style: GetirStyleDeliveryUiTypography.headlineMd(locale)),
                    const SizedBox(height: 4),
                    Text(l10n.enterPhone, style: GetirStyleDeliveryUiTypography.bodySm(locale)),
                    const SizedBox(height: 24),
                    LtrInputScope(
                      child: PhoneInputField(
                        country: _selectedCountry,
                        controller: _phoneController,
                        placeholder: l10n.phonePlaceholder,
                        onCountryChanged: (c) =>
                            setState(() => _selectedCountry = c),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShadButton(
                      width: double.infinity,
                      onPressed: _isPhoneValid && !_submitting ? _continue : null,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.continueButton),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'API: ${AppConfig.apiBaseUrl}',
                      textAlign: TextAlign.center,
                      style: GetirStyleDeliveryUiTypography.labelSm(
                        locale,
                        color: LoginTheme.cardForeground.withValues(alpha: 0.5),
                      ),
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
