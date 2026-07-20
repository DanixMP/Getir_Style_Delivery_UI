import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Home screen theming scope.
abstract final class HomeTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarTitle = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color addressChipBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color heroTitle = GetirStyleDeliveryUiColors.onSurface;
  static const Color heroSubtitle = GetirStyleDeliveryUiColors.onSurfaceVariant;
  static const Color glassCardBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color glassCardBorder = GetirStyleDeliveryUiColors.surfaceContainer;
  static const Color serviceTitle = GetirStyleDeliveryUiColors.primary;
  static const Color serviceBrandTitle = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color serviceSubtitle = GetirStyleDeliveryUiColors.onSurfaceVariant;
  static const Color serviceHint = GetirStyleDeliveryUiColors.outline;
  static const Color promoBackground = GetirStyleDeliveryUiColors.primaryContainer;
  static const Color promoForeground = GetirStyleDeliveryUiColors.onPrimaryContainer;
  static const Color promoButtonBackground = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color promoButtonForeground = GetirStyleDeliveryUiColors.onSecondaryContainer;
  static const Color promoGlow = GetirStyleDeliveryUiColors.secondaryContainer;

  static const double heroHeight = 280;
  static const double serviceCardLargeHeight = 180;
  static const double serviceCardSmallHeight = 82;
  static const double serviceCardMediumHeight = 120;
  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double cardRadius = GetirStyleDeliveryUiRadius.xl;
  static const double promoRadius = GetirStyleDeliveryUiRadius.xl;
}
