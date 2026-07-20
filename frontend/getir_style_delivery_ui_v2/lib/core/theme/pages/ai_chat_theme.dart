import 'package:flutter/material.dart';

import '../getir_style_delivery_ui_colors.dart';
import '../getir_style_delivery_ui_radius.dart';
import '../getir_style_delivery_ui_spacing.dart';

/// AI Chat screen theming scope.
abstract final class AiChatTheme {
  static const Color appBarBackground = GetirStyleDeliveryUiColors.primary;
  static const Color appBarForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color screenBackground = GetirStyleDeliveryUiColors.background;
  static const Color aiBubbleBackground = GetirStyleDeliveryUiColors.surfaceContainerLow;
  static const Color aiBubbleForeground = GetirStyleDeliveryUiColors.onSurface;
  static const Color userBubbleBackground = GetirStyleDeliveryUiColors.primaryContainer;
  static const Color userBubbleForeground = GetirStyleDeliveryUiColors.onPrimaryContainer;
  static const Color inputBackground = GetirStyleDeliveryUiColors.surfaceContainerLowest;
  static const Color inputBorder = GetirStyleDeliveryUiColors.outlineVariant;
  static const Color sendButtonBackground = GetirStyleDeliveryUiColors.primary;
  static const Color sendButtonForeground = GetirStyleDeliveryUiColors.onPrimary;
  static const Color suggestionChipBackground = GetirStyleDeliveryUiColors.primaryFixed;
  static const Color suggestionChipForeground = GetirStyleDeliveryUiColors.onPrimaryFixed;
  static const Color avatarBackground = GetirStyleDeliveryUiColors.secondaryContainer;
  static const Color avatarForeground = GetirStyleDeliveryUiColors.onSecondaryContainer;

  static const double margin = GetirStyleDeliveryUiSpacing.marginMobile;
  static const double bubbleRadius = 20;
  static const double inputRadius = GetirStyleDeliveryUiRadius.xl;
}
