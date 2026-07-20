import 'package:flutter/material.dart';

import 'getir_style_delivery_ui_colors.dart';
import 'getir_style_delivery_ui_typography.dart';

const kFa = Locale('fa');

abstract final class GetirStyleDeliveryUiAppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1C1D) : GetirStyleDeliveryUiColors.background;
    final surface = isDark ? GetirStyleDeliveryUiColors.inverseSurface : GetirStyleDeliveryUiColors.surface;
    final onSurface = isDark ? GetirStyleDeliveryUiColors.inverseOnSurface : GetirStyleDeliveryUiColors.onSurface;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GetirStyleDeliveryUiColors.primary,
        brightness: brightness,
        primary: GetirStyleDeliveryUiColors.primary,
        onPrimary: GetirStyleDeliveryUiColors.onPrimary,
        secondary: GetirStyleDeliveryUiColors.secondaryContainer,
        surface: surface,
        onSurface: onSurface,
        error: GetirStyleDeliveryUiColors.error,
      ),
      scaffoldBackgroundColor: bg,
      fontFamily: GetirStyleDeliveryUiTypography.fontFamilyFor(kFa),
      appBarTheme: AppBarTheme(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        titleTextStyle: GetirStyleDeliveryUiTypography.headlineMd(kFa, color: GetirStyleDeliveryUiColors.onPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? GetirStyleDeliveryUiColors.inverseSurface : GetirStyleDeliveryUiColors.surfaceContainerLowest,
        indicatorColor: GetirStyleDeliveryUiColors.primaryFixed,
      ),
      cardColor: isDark ? const Color(0xFF2F3132) : GetirStyleDeliveryUiColors.surfaceContainerLowest,
      dividerColor: isDark ? GetirStyleDeliveryUiColors.outline.withValues(alpha: 0.4) : GetirStyleDeliveryUiColors.outlineVariant,
    );
  }
}
