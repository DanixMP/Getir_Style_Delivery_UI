import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Categories screen theming scope.
abstract final class CategoriesTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarTitle = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color addressBarBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color addressIcon = GetirStyleDeliveryUiColors.primary;
  static const Color addressText = GetirStyleDeliveryUiColors.onSurface;
  static const Color addAddress = GetirStyleDeliveryUiColors.primary;
  static const Color categoryTileBackground = GetirStyleDeliveryUiColors.surfaceContainerHigh;
  static const Color categoryTitle = GetirStyleDeliveryUiColors.onSurface;
  static const Color mapBorder = GetirStyleDeliveryUiColors.outlineVariant;
  static const Color mapOverlayBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color mapOverlayLabel = GetirStyleDeliveryUiColors.outline;
  static const Color sectionAction = GetirStyleDeliveryUiColors.primary;
  static const Color navActiveGlow = GetirStyleDeliveryUiColors.secondaryContainer;

  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double cardRadius = GetirStyleDeliveryUiRadius.xl;
  static const double mapHeight = 160;
}
