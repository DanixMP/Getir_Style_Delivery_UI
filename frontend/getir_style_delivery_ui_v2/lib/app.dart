import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/localization/locale_provider.dart';
import 'core/theme/getir_style_delivery_ui_colors.dart';
import 'core/theme/getir_style_delivery_ui_theme.dart';
import 'features/splash/app_entry.dart';
import 'l10n/app_localizations.dart';

class GetirStyleDeliveryUiApp extends StatelessWidget {
  const GetirStyleDeliveryUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final locale = localeProvider.locale;

    return ShadTheme(
      data: GetirStyleDeliveryUiTheme.shad(locale),
      child: MaterialApp(
        title: 'GetirStyleDeliveryUi',
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: LocaleProvider.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: GetirStyleDeliveryUiTheme.material(locale),
        builder: (context, child) {
          return Directionality(
            textDirection: localeProvider.textDirection,
            child: DefaultTextStyle(
              style: GetirStyleDeliveryUiTheme.defaultTextStyle(locale),
              child: child ?? const _LaunchPlaceholder(),
            ),
          );
        },
        home: const AppEntry(),
      ),
    );
  }
}

/// Shown only while MaterialApp builds its first frame.
class _LaunchPlaceholder extends StatelessWidget {
  const _LaunchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: GetirStyleDeliveryUiColors.primary);
  }
}
