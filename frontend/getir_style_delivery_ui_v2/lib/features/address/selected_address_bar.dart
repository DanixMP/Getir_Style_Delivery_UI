import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/address_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import 'address_manager_sheet.dart';

/// Thin strip shown directly under the top bar that surfaces the currently
/// selected delivery address. Renders nothing when no address is selected.
class SelectedAddressBar extends StatelessWidget {
  const SelectedAddressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final selected = context.watch<AddressProvider>().selected;
    if (selected == null) return const SizedBox.shrink();

    return Material(
      color: GetirStyleDeliveryUiColors.primaryContainer,
      child: InkWell(
        onTap: () => showAddressManager(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.location_on,
                  size: 18, color: GetirStyleDeliveryUiColors.onPrimary),
              const SizedBox(width: 8),
              Text(
                '${selected.title}: ',
                style: GetirStyleDeliveryUiTypography.labelMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  selected.details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.change,
                style: GetirStyleDeliveryUiTypography.labelSm(
                  locale,
                  color: GetirStyleDeliveryUiColors.secondaryContainer,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: GetirStyleDeliveryUiColors.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
