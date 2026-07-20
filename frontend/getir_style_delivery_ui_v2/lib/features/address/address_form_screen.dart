import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/providers/address_provider.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../data/models/neshan_search_result.dart';
import '../../l10n/app_localizations.dart';
import 'address_map_pick_result.dart';

/// Step 2 — review and correct the address after map selection.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, required this.pick});

  final AddressMapPickResult pick;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _details;
  late final TextEditingController _city;
  late double _latitude;
  late double _longitude;

  List<NeshanSearchResult> _suggestions = [];
  Timer? _searchDebounce;
  bool _searching = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final pick = widget.pick;
    _title = TextEditingController(text: pick.titleSuggestion);
    _details = TextEditingController(text: pick.formattedAddress);
    _city = TextEditingController(text: pick.city);
    _latitude = pick.latitude;
    _longitude = pick.longitude;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _title.dispose();
    _details.dispose();
    _city.dispose();
    super.dispose();
  }

  void _onDetailsChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 2) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      setState(() => _searching = true);
      final results = await AppServices.instance.tracking.search(
        value,
        LatLng(_latitude, _longitude),
      );
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  void _pickSuggestion(NeshanSearchResult r) {
    setState(() {
      _details.text = r.displayLabel;
      _city.text = r.region.isNotEmpty ? r.region : _city.text;
      _latitude = r.lat;
      _longitude = r.lng;
      _suggestions = [];
    });
  }

  Future<void> _save() async {
    if (_details.text.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    await context.read<AddressProvider>().add(
          title: _title.text.trim().isEmpty ? l10n.addressFallback : _title.text.trim(),
          details: _details.text.trim(),
          city: _city.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(); // form
    Navigator.of(context).pop(); // map picker → back to address manager
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text(l10n.completeAddressTitle),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          GetirStyleDeliveryUiSpacing.marginMobile,
          GetirStyleDeliveryUiSpacing.stackMd,
          GetirStyleDeliveryUiSpacing.marginMobile,
          GetirStyleDeliveryUiSpacing.stackMd + bottomInset,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GetirStyleDeliveryUiColors.primaryFixed,
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: GetirStyleDeliveryUiColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.mapLocationSelected,
                    style: GetirStyleDeliveryUiTypography.bodySm(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: l10n.addressTitleLabel,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            maxLines: 3,
            onChanged: _onDetailsChanged,
            decoration: InputDecoration(
              labelText: l10n.fullAddressLabel,
              hintText: l10n.searchOrEditAddress,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.edit_location_alt, color: GetirStyleDeliveryUiColors.primary),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = _suggestions[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.place,
                      color: GetirStyleDeliveryUiColors.primary,
                      size: 20,
                    ),
                    title: Text(
                      s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      s.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GetirStyleDeliveryUiTypography.bodySm(
                        locale,
                        color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => _pickSuggestion(s),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            decoration: InputDecoration(
              labelText: l10n.city,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
              ),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: GetirStyleDeliveryUiColors.onPrimary,
                    ),
                  )
                : Text(
                    l10n.saveAddress,
                    style: GetirStyleDeliveryUiTypography.labelLg(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
