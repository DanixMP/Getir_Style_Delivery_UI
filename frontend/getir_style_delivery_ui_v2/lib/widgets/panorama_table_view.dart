import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../data/models/dining_table_model.dart';
import '../l10n/app_localizations.dart';

/// 1×1 transparent PNG for [Panorama] placeholder/error states.
final _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// Full-screen equirectangular 360° viewer with tappable table hotspots.
class PanoramaTableView extends StatelessWidget {
  const PanoramaTableView({
    super.key,
    required this.imageUrl,
    required this.tables,
    required this.selectedTable,
    required this.onTableSelected,
    required this.onConfirm,
    this.initialYaw = 0,
    this.confirmLabel,
    this.loading = false,
  });

  final String imageUrl;
  final List<DiningTableModel> tables;
  final DiningTableModel? selectedTable;
  final ValueChanged<DiningTableModel> onTableSelected;
  final VoidCallback onConfirm;
  final double initialYaw;
  final String? confirmLabel;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Panorama(
          longitude: initialYaw,
          hotspots: [
            for (final table in tables)
              Hotspot(
                latitude: table.hotspotPitch,
                longitude: table.hotspotYaw,
                width: 48,
                height: 48,
                widget: _TableHotspot(
                  table: table,
                  selected: selectedTable?.id == table.id,
                  onTap: () => onTableSelected(table),
                ),
              ),
          ],
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.memory(
                    _kTransparentImage,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.memory(
                  _kTransparentImage,
                  fit: BoxFit.cover,
                ),
        ),
        if (imageUrl.isEmpty)
          const ColoredBox(
            color: GetirStyleDeliveryUiColors.surfaceContainerHigh,
            child: Center(
              child: Icon(
                Icons.panorama_outlined,
                size: 48,
                color: GetirStyleDeliveryUiColors.onSurfaceVariant,
              ),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (selectedTable != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: GetirStyleDeliveryUiColors.surfaceContainerLowest
                          .withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.table_restaurant,
                          color: GetirStyleDeliveryUiColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedTable!.label,
                            style: GetirStyleDeliveryUiTypography.labelLg(
                              locale,
                              color: GetirStyleDeliveryUiColors.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          l10n.dineInSeats(selectedTable!.capacity),
                          style: GetirStyleDeliveryUiTypography.bodySm(
                            locale,
                            color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: GetirStyleDeliveryUiColors.primary,
                    foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                    ),
                  ),
                  onPressed:
                      selectedTable != null && !loading ? onConfirm : null,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GetirStyleDeliveryUiColors.onPrimary,
                          ),
                        )
                      : Text(
                          confirmLabel ?? l10n.confirmTable,
                          style: GetirStyleDeliveryUiTypography.labelLg(
                            locale,
                            color: GetirStyleDeliveryUiColors.onPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHotspot extends StatelessWidget {
  const _TableHotspot({
    required this.table,
    required this.selected,
    required this.onTap,
  });

  final DiningTableModel table;
  final bool selected;
  final VoidCallback onTap;

  Color get _color => switch (table.status) {
        DiningTableStatus.available => GetirStyleDeliveryUiColors.secondary,
        DiningTableStatus.reserved => const Color(0xFFE6A23C),
        DiningTableStatus.occupied => GetirStyleDeliveryUiColors.outline,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = table.isSelectable;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: enabled ? 0.92 : 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? GetirStyleDeliveryUiColors.onPrimary : Colors.white,
            width: selected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              table.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
