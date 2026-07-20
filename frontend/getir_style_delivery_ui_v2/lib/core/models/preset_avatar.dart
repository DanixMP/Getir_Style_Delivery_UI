import 'package:flutter/material.dart';

import '../theme/getir_style_delivery_ui_colors.dart';

/// Built-in profile avatars — gradient circle + icon (no image assets).
class PresetAvatar {
  const PresetAvatar({
    required this.id,
    required this.icon,
    required this.gradient,
    this.iconColor = GetirStyleDeliveryUiColors.onPrimary,
  });

  final String id;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;

  static const String defaultId = 'purple';

  static const List<PresetAvatar> all = [
    PresetAvatar(
      id: 'purple',
      icon: Icons.person,
      gradient: [Color(0xFF5D3EBD), Color(0xFF4520A5)],
    ),
    PresetAvatar(
      id: 'lavender',
      icon: Icons.face_retouching_natural,
      gradient: [Color(0xFFB8A9FF), Color(0xFF7B61D8)],
      iconColor: GetirStyleDeliveryUiColors.onPrimaryFixed,
    ),
    PresetAvatar(
      id: 'sunset',
      icon: Icons.wb_sunny_outlined,
      gradient: [Color(0xFFFFB347), Color(0xFFFF6B6B)],
    ),
    PresetAvatar(
      id: 'mint',
      icon: Icons.eco_outlined,
      gradient: [Color(0xFF6BCB9A), Color(0xFF2D9F6F)],
    ),
    PresetAvatar(
      id: 'ocean',
      icon: Icons.waves_outlined,
      gradient: [Color(0xFF64B5F6), Color(0xFF1976D2)],
    ),
    PresetAvatar(
      id: 'rose',
      icon: Icons.favorite_border,
      gradient: [Color(0xFFF48FB1), Color(0xFFE91E63)],
    ),
    PresetAvatar(
      id: 'delivery',
      icon: Icons.delivery_dining,
      gradient: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      iconColor: Color(0xFF4A2800),
    ),
    PresetAvatar(
      id: 'chef',
      icon: Icons.restaurant,
      gradient: [Color(0xFFCE93D8), Color(0xFF8E24AA)],
    ),
  ];

  static PresetAvatar byId(String? id) {
    if (id == null || id.isEmpty) return all.first;
    return all.firstWhere((a) => a.id == id, orElse: () => all.first);
  }
}
