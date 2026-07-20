import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/pages/login_theme.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../l10n/app_localizations.dart';

/// Single merged phone field: country picker + number input.
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.country,
    required this.controller,
    required this.placeholder,
    required this.onCountryChanged,
  });

  final Country country;
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<Country> onCountryChanged;

  void _openCountryPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['IR'],
      countryListTheme: CountryListThemeData(
        backgroundColor: LoginTheme.inputBackground,
        textStyle: GetirStyleDeliveryUiTypography.bodyMd(
          const Locale('en'),
          color: LoginTheme.inputForeground,
        ),
        searchTextStyle: GetirStyleDeliveryUiTypography.bodyMd(
          const Locale('en'),
          color: LoginTheme.inputForeground,
        ),
        inputDecoration: InputDecoration(
          hintText: l10n.searchCountry,
          hintStyle: GetirStyleDeliveryUiTypography.bodyMd(
            const Locale('en'),
            color: LoginTheme.inputPlaceholder,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
          ),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LoginTheme.cardRadius),
        ),
        bottomSheetHeight: 500,
        flagSize: 24,
      ),
      onSelect: onCountryChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: LoginTheme.inputBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
        border: Border.all(
          color: LoginTheme.cardForeground.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openCountryPicker(context),
              borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${country.phoneCode}',
                      style: GetirStyleDeliveryUiTypography.labelLg(
                        const Locale('en'),
                        color: LoginTheme.inputForeground,
                      ),
                    ),
                    Icon(
                      Icons.expand_more,
                      size: 18,
                      color: LoginTheme.inputForeground.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: LoginTheme.inputPlaceholder.withValues(alpha: 0.35),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              maxLength: 15,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GetirStyleDeliveryUiTypography.bodyLg(
                const Locale('en'),
                color: LoginTheme.inputForeground,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: placeholder,
                hintStyle: GetirStyleDeliveryUiTypography.bodyLg(
                  const Locale('en'),
                  color: LoginTheme.inputPlaceholder.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
