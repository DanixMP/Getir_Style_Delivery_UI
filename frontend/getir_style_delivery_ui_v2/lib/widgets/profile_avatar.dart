import 'package:flutter/material.dart';

import '../core/models/preset_avatar.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';

/// Circular preset avatar — shared across profile screens.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.preset,
    this.size = 72,
    this.showBorder = false,
    this.selected = false,
  });

  final PresetAvatar preset;
  final double size;
  final bool showBorder;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.48;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: preset.gradient,
        ),
        border: showBorder || selected
            ? Border.all(
                color: selected ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.surfaceContainerLowest,
                width: selected ? 3 : 2,
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(preset.icon, size: iconSize, color: preset.iconColor),
    );
  }
}
