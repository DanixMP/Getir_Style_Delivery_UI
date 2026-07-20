import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Wallet screen theming scope.
abstract final class WalletTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarTitle = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color balanceCardBackground = GetirStyleDeliveryUiColors.primary;
  static const Color balanceCardForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color glassCardBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color actionIcon = GetirStyleDeliveryUiColors.primary;
  static const Color actionTitle = GetirStyleDeliveryUiColors.onSurface;
  static const Color transactionPositive = GetirStyleDeliveryUiColors.success;
  static const Color transactionNegative = GetirStyleDeliveryUiColors.error;
  static const Color avatarBorder = GetirStyleDeliveryUiColors.onPrimaryContainer;
  static const Color avatarBackground = GetirStyleDeliveryUiColors.secondaryContainer;

  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double balanceCardRadius = GetirStyleDeliveryUiRadius.xxl;
  static const double cardRadius = GetirStyleDeliveryUiRadius.xl;
}
