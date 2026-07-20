import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persian_fonts/persian_fonts.dart';

import 'getir_style_delivery_ui_colors.dart';

/// Typography scale from DESIGN.md with locale-aware font families.
abstract final class GetirStyleDeliveryUiTypography {
  static String fontFamilyFor(Locale locale) {
    return switch (locale.languageCode) {
      'fa' => 'Vazir',
      'ar' => GoogleFonts.notoSansArabic().fontFamily ?? 'Noto Sans Arabic',
      _ => GoogleFonts.plusJakartaSans().fontFamily ?? 'Plus Jakarta Sans',
    };
  }

  static TextStyle _base(Locale locale, {
    required double size,
    required FontWeight weight,
    required double height,
    double? letterSpacing,
    Color? color,
  }) {
    if (locale.languageCode == 'fa') {
      return PersianFonts.Vazir.copyWith(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    if (locale.languageCode == 'ar') {
      return GoogleFonts.notoSansArabic(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height / size,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle headlineLg(Locale locale, {Color? color}) => _base(
        locale,
        size: 24,
        weight: FontWeight.w700,
        height: 32,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle headlineMd(Locale locale, {Color? color}) => _base(
        locale,
        size: 20,
        weight: FontWeight.w700,
        height: 28,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle headlineSm(Locale locale, {Color? color}) => _base(
        locale,
        size: 16,
        weight: FontWeight.w600,
        height: 24,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle bodyLg(Locale locale, {Color? color}) => _base(
        locale,
        size: 16,
        weight: FontWeight.w400,
        height: 24,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle bodyMd(Locale locale, {Color? color}) => _base(
        locale,
        size: 14,
        weight: FontWeight.w400,
        height: 20,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle bodySm(Locale locale, {Color? color}) => _base(
        locale,
        size: 12,
        weight: FontWeight.w400,
        height: 16,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle labelLg(Locale locale, {Color? color}) => _base(
        locale,
        size: 14,
        weight: FontWeight.w600,
        height: 20,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle labelMd(Locale locale, {Color? color}) => _base(
        locale,
        size: 12,
        weight: FontWeight.w600,
        height: 16,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );

  static TextStyle labelSm(Locale locale, {Color? color}) => _base(
        locale,
        size: 10,
        weight: FontWeight.w700,
        height: 12,
        letterSpacing: 0.5,
        color: color ?? GetirStyleDeliveryUiColors.onSurface,
      );
}
