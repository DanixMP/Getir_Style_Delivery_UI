import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../data/models/neshan_reverse_result.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/neshan_map_view.dart';
import 'address_form_screen.dart';
import 'address_map_pick_result.dart';
import 'address_map_widgets.dart';

const _defaultCenter = LatLng(35.6892, 51.3890);

/// Step 1 — pick delivery location on the map.
class AddressMapPickerScreen extends StatefulWidget {
  const AddressMapPickerScreen({super.key});

  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  final MapController _map = MapController();
  Timer? _geocodeDebounce;
  NeshanReverseResult? _estimate;
  bool _resolving = false;
  String? _resolveError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seed = _initialCenter(context);
      _map.move(seed, 14);
      _scheduleResolve();
    });
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  LatLng _initialCenter(BuildContext context) {
    final selected = context.read<AddressProvider>().selected;
    if (selected != null &&
        selected.latitude != null &&
        selected.longitude != null) {
      return LatLng(selected.latitude!, selected.longitude!);
    }
    return _defaultCenter;
  }

  void _scheduleResolve() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 450), _resolveCenter);
  }

  Future<void> _resolveCenter() async {
    if (!mounted) return;
    setState(() {
      _resolving = true;
      _resolveError = null;
    });
    final point = _map.camera.center;
    final result = await AppServices.instance.tracking.reverse(point);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _resolving = false;
      _estimate = result;
      _resolveError = result == null ? l10n.addressNotFound : null;
    });
  }

  void _moveTo(LatLng point, {double? zoom}) {
    _map.move(point, zoom ?? _map.camera.zoom);
    _scheduleResolve();
  }

  void _continueToForm() {
    final estimate = _estimate;
    if (estimate == null || estimate.formattedAddress.isEmpty) return;
    final pick = AddressMapPickResult(
      latitude: estimate.lat,
      longitude: estimate.lng,
      formattedAddress: estimate.formattedAddress,
      city: estimate.resolvedCity,
      titleSuggestion: estimate.shortLabel,
    );
    context.pushGetirStyleDeliveryUi(
      AddressFormScreen(pick: pick),
      transition: GetirStyleDeliveryUiTransition.sharedAxisHorizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text(l10n.mapPickerTitle),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          NeshanMapView(
            mapController: _map,
            center: _defaultCenter,
            zoom: 14,
            onCenterChanged: (_) => _scheduleResolve(),
            onTap: (_, point) => _moveTo(point),
          ),
          const IgnorePointer(
            child: Align(
              alignment: Alignment(0, -0.06),
              child: AddressMapPickerPin(),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: MapZoomControls(controller: _map),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: MapCurrentLocationButton(
              onLocated: (p) => _moveTo(p, zoom: 16),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: AddressMapPickerOverlay(
                locale: locale,
                title: _estimate?.shortLabel ?? l10n.pickOnMapHint,
                subtitle: _resolving
                    ? l10n.resolvingAddress
                    : _resolveError ??
                        _estimate?.formattedAddress ??
                        l10n.moveMapHint,
                subtitleColor: _resolveError != null
                    ? GetirStyleDeliveryUiColors.error
                    : GetirStyleDeliveryUiColors.onSurfaceVariant,
                actionLabel: l10n.continueCompleteAddress,
                onAction: _continueToForm,
                actionEnabled: _estimate != null &&
                    _estimate!.formattedAddress.isNotEmpty &&
                    !_resolving,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
