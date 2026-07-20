import 'package:flutter/material.dart';

import '../core/models/preset_avatar.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import 'profile_avatar.dart';

/// Horizontal row of selectable preset avatars.
class AvatarPickerRow extends StatelessWidget {
  const AvatarPickerRow({
    super.key,
    required this.selectedId,
    required this.onSelected,
    required this.locale,
    this.size = 52,
    this.label,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;
  final Locale locale;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            textAlign: TextAlign.center,
            style: GetirStyleDeliveryUiTypography.labelSm(
              locale,
              color: const Color(0xFF6B5B95),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: size + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: PresetAvatar.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final preset = PresetAvatar.all[index];
              final isSelected = preset.id == selectedId;
              return GestureDetector(
                onTap: () => onSelected(preset.id),
                child: AnimatedScale(
                  scale: isSelected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: ProfileAvatar(
                    preset: preset,
                    size: size,
                    selected: isSelected,
                    showBorder: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
