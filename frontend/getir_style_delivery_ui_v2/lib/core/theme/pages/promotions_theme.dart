import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Promotions / Offers screen theming scope.
abstract final class PromotionsTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarTitle = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color tabBarBackground = GetirStyleDeliveryUiColors.surface;
  static const Color tabActive = GetirStyleDeliveryUiColors.primary;
  static const Color tabInactive = GetirStyleDeliveryUiColors.outline;
  static const Color tabIndicator = GetirStyleDeliveryUiColors.primary;
  static const Color cardBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color cardTitle = GetirStyleDeliveryUiColors.onSurface;
  static const Color cardSubtitle = GetirStyleDeliveryUiColors.onSurfaceVariant;
  static const Color badgeBackground = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color badgeForeground = GetirStyleDeliveryUiColors.onSecondaryContainer;

  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double cardRadius = GetirStyleDeliveryUiRadius.xl;
}
