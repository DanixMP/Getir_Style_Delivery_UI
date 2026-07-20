import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'getir_style_delivery_ui_colors.dart';
import 'getir_style_delivery_ui_typography.dart';

/// Central Material + Shad theme builders so every widget uses the same font.
abstract final class GetirStyleDeliveryUiTheme {
  static ThemeData material(Locale locale) {
    final textTheme = _materialTextTheme(locale);
    final body = GetirStyleDeliveryUiTypography.bodyMd(locale);
    final label = GetirStyleDeliveryUiTypography.labelMd(locale);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GetirStyleDeliveryUiColors.primary,
        primary: GetirStyleDeliveryUiColors.primary,
        secondary: GetirStyleDeliveryUiColors.secondaryContainer,
        surface: GetirStyleDeliveryUiColors.surface,
        error: GetirStyleDeliveryUiColors.error,
      ),
      scaffoldBackgroundColor: GetirStyleDeliveryUiColors.background,
      fontFamily: GetirStyleDeliveryUiTypography.fontFamilyFor(locale),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle: GetirStyleDeliveryUiTypography.headlineMd(
          locale,
          color: GetirStyleDeliveryUiColors.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: body.copyWith(color: GetirStyleDeliveryUiColors.onSurfaceVariant),
        labelStyle: label,
        floatingLabelStyle: label.copyWith(color: GetirStyleDeliveryUiColors.primary),
      ),
      chipTheme: ChipThemeData(
        labelStyle: label,
        secondaryLabelStyle: label,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: GetirStyleDeliveryUiTypography.labelLg(locale),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GetirStyleDeliveryUiTypography.labelMd(locale),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GetirStyleDeliveryUiTypography.labelMd(locale),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: body.copyWith(color: GetirStyleDeliveryUiColors.onPrimary),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: GetirStyleDeliveryUiTypography.headlineSm(locale),
        contentTextStyle: body,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ShadThemeData shad(Locale locale) {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadZincColorScheme.light(
        primary: GetirStyleDeliveryUiColors.primary,
        secondary: GetirStyleDeliveryUiColors.secondaryContainer,
      ),
      textTheme: _shadTextTheme(locale),
    );
  }

  /// Default text style for widgets that do not pick up [ThemeData.textTheme].
  static TextStyle defaultTextStyle(Locale locale) =>
      GetirStyleDeliveryUiTypography.bodyMd(locale);

  static TextTheme _materialTextTheme(Locale locale) {
    final onSurface = GetirStyleDeliveryUiColors.onSurface;
    return switch (locale.languageCode) {
      'fa' => PersianFonts.vazirTextTheme.apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
      'ar' => GoogleFonts.notoSansArabicTextTheme().apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
      _ => GoogleFonts.plusJakartaSansTextTheme().apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
    };
  }

  static ShadTextTheme _shadTextTheme(Locale locale) {
    return switch (locale.languageCode) {
      'fa' => _shadFamily('Vazir', package: 'persian_fonts'),
      'ar' => ShadTextTheme.fromGoogleFont(GoogleFonts.notoSansArabic),
      _ => ShadTextTheme.fromGoogleFont(GoogleFonts.plusJakartaSans),
    };
  }

  static ShadTextTheme _shadFamily(String family, {String? package}) {
    final base = ShadDefaultThemeVariant.defaultTextTheme;
    TextStyle apply(TextStyle style) =>
        style.copyWith(fontFamily: family, package: package);

    return ShadTextTheme.custom(
      h1Large: apply(base.h1Large),
      h1: apply(base.h1),
      h2: apply(base.h2),
      h3: apply(base.h3),
      h4: apply(base.h4),
      p: apply(base.p),
      blockquote: apply(base.blockquote),
      table: apply(base.table),
      list: apply(base.list),
      lead: apply(base.lead),
      large: apply(base.large),
      small: apply(base.small),
      muted: apply(base.muted),
      family: family,
    );
  }
}
