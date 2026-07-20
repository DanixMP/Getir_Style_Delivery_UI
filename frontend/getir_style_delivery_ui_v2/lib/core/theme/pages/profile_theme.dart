import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Profile screen theming scope.
abstract final class ProfileTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarTitle = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color cardBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color cardHover = GetirStyleDeliveryUiColors.surfaceContainerLow;
  static const Color avatarBackground = GetirStyleDeliveryUiColors.primaryFixed;
  static const Color avatarIcon = GetirStyleDeliveryUiColors.primary;
  static const Color menuIcon = GetirStyleDeliveryUiColors.primary;
  static const Color menuTitle = GetirStyleDeliveryUiColors.onSurface;
  static const Color menuSubtitle = GetirStyleDeliveryUiColors.outline;
  static const Color chevron = GetirStyleDeliveryUiColors.outline;
  static const Color divider = GetirStyleDeliveryUiColors.outlineVariant;
  static const Color sectionLabel = GetirStyleDeliveryUiColors.outline;
  static const Color versionText = GetirStyleDeliveryUiColors.onSurfaceVariant;
  static const Color signOutBackground = GetirStyleDeliveryUiColors.surfaceContainerHigh;
  static const Color signOutForeground = GetirStyleDeliveryUiColors.error;
  static const Color decorationPrimary = GetirStyleDeliveryUiColors.primary;
  static const Color decorationSecondary = GetirStyleDeliveryUiColors.secondaryContainer;

  static const double cardRadius = GetirStyleDeliveryUiRadius.xl;
  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double cardShadowOpacity = 0.05;
}
