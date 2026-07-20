import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Search screen theming scope.
abstract final class SearchTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color searchFieldBackground = GetirStyleDeliveryUiColors.surfaceContainerLow;
  static const Color searchFieldForeground = GetirStyleDeliveryUiColors.onSurface;
  static const Color searchHint = GetirStyleDeliveryUiColors.outline;
  static const Color chipBackground = GetirStyleDeliveryUiColors.primaryFixed;
  static const Color chipForeground = GetirStyleDeliveryUiColors.onPrimaryFixed;
  static const Color resultTitle = GetirStyleDeliveryUiColors.onSurface;
  static const Color resultSubtitle = GetirStyleDeliveryUiColors.onSurfaceVariant;

  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double searchRadius = GetirStyleDeliveryUiRadius.full;
}
