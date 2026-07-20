import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// Login / OTP screen theming scope.
abstract final class LoginTheme {
  static const Color screenBackground = GetirStyleDeliveryUiColors.primary;
  static const Color logoColor = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color taglineColor = GetirStyleDeliveryUiColors.onPrimary;
  static const Color cardBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color cardForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color cardSubtitle = GetirStyleDeliveryUiColors.onPrimary;
  static const Color inputBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color inputForeground = GetirStyleDeliveryUiColors.onSurface;
  static const Color inputPlaceholder = GetirStyleDeliveryUiColors.outline;
  static const Color countrySelectorBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color continueButtonBackground = GetirStyleDeliveryUiColors.primary;
  static const Color continueButtonForeground = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color continueButtonHoverBackground = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color continueButtonHoverForeground = GetirStyleDeliveryUiColors.primary;
  static const Color dividerColor = GetirStyleDeliveryUiColors.onPrimary;
  static const Color socialButtonBackground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color socialButtonBorder = GetirStyleDeliveryUiColors.onPrimary;
  static const Color footerLink = GetirStyleDeliveryUiColors.onPrimary;
  static const Color footerLegal = GetirStyleDeliveryUiColors.onPrimary;
  static const Color decorativeSecondary = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color decorativeTertiary = GetirStyleDeliveryUiColors.tertiaryContainer;
  static const Color otpActiveFill = GetirStyleDeliveryUiColors.primaryContainer;
  static const Color otpInactiveFill = GetirStyleDeliveryUiColors.surfaceContainerLow;
  static const Color otpBorder = GetirStyleDeliveryUiColors.outlineVariant;

  static const double cardRadius = GetirStyleDeliveryUiRadius.xxl;
  static const double inputRadius = GetirStyleDeliveryUiRadius.xl;
  static const double buttonRadius = GetirStyleDeliveryUiRadius.xl;
  static const double padding = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double cardPadding = GetirStyleDeliveryUiSpacing.stackLg;
}
