import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/providers/address_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../l10n/app_localizations.dart';
import 'address_map_picker_screen.dart';

/// Opens the address manager as a modal bottom sheet.
Future<void> showAddressManager(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: GetirStyleDeliveryUiColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(GetirStyleDeliveryUiRadius.xxl)),
    ),
    builder: (_) => const _AddressManager(),
  );
}

/// Map pick → form → save.
Future<void> startAddAddressFlow(BuildContext context) {
  return context.pushGetirStyleDeliveryUi(
    const AddressMapPickerScreen(),
    transition: GetirStyleDeliveryUiTransition.sharedAxisVertical,
  );
}

class _AddressManager extends StatelessWidget {
  const _AddressManager();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.myAddresses,
                style: GetirStyleDeliveryUiTypography.headlineSm(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.noAddress,
                    textAlign: TextAlign.center,
                    style: GetirStyleDeliveryUiTypography.bodyMd(
                      locale,
                      color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ...addresses.map(
                (a) => _AddressTile(
                  selected: addressProvider.selected?.id == a.id,
                  title: a.title,
                  details: a.details,
                  city: a.city,
                  locale: locale,
                  onSelect: () {
                    addressProvider.select(a.id);
                    Navigator.of(context).pop();
                  },
                  onDelete: () => addressProvider.remove(a.id),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => startAddAddressFlow(context),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(l10n.addAddress),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.selected,
    required this.title,
    required this.details,
    required this.city,
    required this.locale,
    required this.onSelect,
    required this.onDelete,
  });

  final bool selected;
  final String title;
  final String details;
  final String city;
  final Locale locale;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        border: Border.all(
          color: selected ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onSelect,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.location_on_outlined,
          color: selected ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.outline,
        ),
        title: Text(
          title,
          style: GetirStyleDeliveryUiTypography.labelLg(locale, color: GetirStyleDeliveryUiColors.onSurface),
        ),
        subtitle: Text(
          '$details · $city',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GetirStyleDeliveryUiTypography.bodySm(
            locale,
            color: GetirStyleDeliveryUiColors.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: GetirStyleDeliveryUiColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
