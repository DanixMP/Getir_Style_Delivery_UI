import 'package:flutter/material.dart';

import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';

/// Fixed centre pin for map-based address picking.
class AddressMapPickerPin extends StatelessWidget {
  const AddressMapPickerPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: GetirStyleDeliveryUiColors.secondaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            size: 24,
            color: GetirStyleDeliveryUiColors.onSecondaryContainer,
          ),
        ),
        Container(
          width: 4,
          height: 10,
          decoration: BoxDecoration(
            color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Bottom card on the map picker — preview + primary action.
class AddressMapPickerOverlay extends StatelessWidget {
  const AddressMapPickerOverlay({
    super.key,
    required this.locale,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    required this.actionLabel,
    required this.onAction,
    this.actionEnabled = true,
    this.actionLoading = false,
  });

  final Locale locale;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;
  final bool actionLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      elevation: 4,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.my_location, color: GetirStyleDeliveryUiColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GetirStyleDeliveryUiTypography.labelLg(
                          locale,
                          color: GetirStyleDeliveryUiColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GetirStyleDeliveryUiTypography.bodySm(
                          locale,
                          color: subtitleColor ?? GetirStyleDeliveryUiColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: GetirStyleDeliveryUiColors.primary,
                foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                ),
              ),
              onPressed: actionEnabled && !actionLoading ? onAction : null,
              child: actionLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: GetirStyleDeliveryUiColors.onPrimary,
                      ),
                    )
                  : Text(
                      actionLabel,
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
