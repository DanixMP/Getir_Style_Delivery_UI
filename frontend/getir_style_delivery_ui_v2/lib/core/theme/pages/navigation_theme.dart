import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';

/// Bottom navigation — purple bar with bright yellow accents.
abstract final class NavigationTheme {
  static const Color barBackground = GetirStyleDeliveryUiColors.primary;
  static const Color barBorder = GetirStyleDeliveryUiColors.primaryContainer;

  static const Color activeIcon = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color activeLabel = GetirStyleDeliveryUiColors.secondaryContainer;

  static const Color inactiveIcon = GetirStyleDeliveryUiColors.onPrimary;
  static const Color inactiveLabel = GetirStyleDeliveryUiColors.onPrimary;

  static const Color centerFabBackground = GetirStyleDeliveryUiColors.primary;
  static const Color centerFabIcon = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color centerFabBorder = GetirStyleDeliveryUiColors.surface;

  static const double barHeight = 72;
  static const double centerFabSize = 56;
  static const double centerFabLift = 22;
  static const double topRadius = GetirStyleDeliveryUiRadius.xl;
  static const double inactiveOpacity = 0.55;
}
