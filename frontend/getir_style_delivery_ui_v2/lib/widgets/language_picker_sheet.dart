import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/locale_provider.dart';
import '../core/theme/pages/profile_theme.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../l10n/app_localizations.dart';

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final provider = context.watch<LocaleProvider>();

    final options = [
      ('fa', l10n.langPersian),
      ('en', l10n.langEnglish),
      ('ar', l10n.langArabic),
      ('tr', l10n.langTurkish),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: ProfileTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.selectLanguage,
            style: GetirStyleDeliveryUiTypography.headlineSm(
              locale,
              color: ProfileTheme.menuTitle,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final isSelected = provider.locale.languageCode == option.$1;
            return ListTile(
              leading: Icon(
                Icons.language,
                color: isSelected
                    ? ProfileTheme.menuIcon
                    : ProfileTheme.menuSubtitle,
              ),
              title: Text(
                option.$2,
                style: GetirStyleDeliveryUiTypography.labelLg(
                  Locale(option.$1),
                  color: ProfileTheme.menuTitle,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: ProfileTheme.menuIcon)
                  : null,
              onTap: () async {
                await provider.setLocale(Locale(option.$1));
                if (context.mounted) Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
