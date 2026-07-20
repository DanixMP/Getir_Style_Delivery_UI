import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import '../core/location/device_position.dart';
import '../core/network/neshan_service.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../l10n/app_localizations.dart';

/// +/- zoom buttons for [NeshanMapView].
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.controller,
    this.minZoom = 5,
    this.maxZoom = 19,
    this.step = 1,
  });

  final MapController controller;
  final double minZoom;
  final double maxZoom;
  final double step;

  void _zoom(double delta) {
    final camera = controller.camera;
    final next = (camera.zoom + delta).clamp(minZoom, maxZoom);
    controller.move(camera.center, next.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: Colors.black26,
      color: GetirStyleDeliveryUiColors.surfaceContainerLowest.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add, onTap: () => _zoom(step)),
          Container(
            height: 1,
            width: 40,
            color: GetirStyleDeliveryUiColors.outlineVariant.withValues(alpha: 0.5),
          ),
          _ZoomButton(icon: Icons.remove, onTap: () => _zoom(-step)),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: GetirStyleDeliveryUiColors.primary, size: 22),
      ),
    );
  }
}

/// Centers the map on the user's GPS position when tapped.
class MapCurrentLocationButton extends StatefulWidget {
  const MapCurrentLocationButton({
    super.key,
    required this.onLocated,
  });

  final ValueChanged<LatLng> onLocated;

  @override
  State<MapCurrentLocationButton> createState() =>
      _MapCurrentLocationButtonState();
}

class _MapCurrentLocationButtonState extends State<MapCurrentLocationButton> {
  bool _loading = false;

  Future<void> _locate() async {
    if (_loading) return;
    setState(() => _loading = true);
    final pos = await readDevicePosition();
    if (!mounted) return;
    setState(() => _loading = false);

    if (pos == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationUnavailable)),
      );
      return;
    }
    widget.onLocated(LatLng(pos.lat, pos.lng));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      elevation: 3,
      shadowColor: Colors.black26,
      color: GetirStyleDeliveryUiColors.surfaceContainerLowest.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _loading ? null : _locate,
        child: Tooltip(
          message: l10n.useMyLocation,
          child: SizedBox(
            width: 44,
            height: 44,
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.my_location,
                    color: GetirStyleDeliveryUiColors.primary,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Interactive map — Neshan raster tiles on native, Carto tiles on web (CORS-safe).
class NeshanMapView extends StatelessWidget {
  const NeshanMapView({
    super.key,
    this.mapController,
    required this.center,
    this.zoom = 14,
    this.routePoints = const [],
    this.markers = const [],
    this.onMapReady,
    this.fitBounds,
    this.onCenterChanged,
    this.onTap,
    this.interactive = true,
  });

  final MapController? mapController;
  final LatLng center;
  final double zoom;
  final List<LatLng> routePoints;
  final List<NeshanMapMarker> markers;
  final VoidCallback? onMapReady;
  final List<LatLng>? fitBounds;
  final ValueChanged<LatLng>? onCenterChanged;
  final void Function(TapPosition tapPosition, LatLng point)? onTap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        backgroundColor: GetirStyleDeliveryUiColors.surfaceContainerHigh,
        onMapReady: () {
          if (fitBounds != null &&
              fitBounds!.length >= 2 &&
              mapController != null) {
            try {
              mapController!.fitCamera(
                CameraFit.coordinates(
                  coordinates: fitBounds!,
                  padding: const EdgeInsets.all(48),
                  maxZoom: 16,
                ),
              );
            } catch (_) {/* map not laid out yet */}
          }
          onMapReady?.call();
        },
        onTap: interactive ? onTap : null,
        onMapEvent: (event) {
          if (!interactive) return;
          if (event is MapEventMoveEnd && onCenterChanged != null) {
            final c = mapController?.camera.center;
            if (c != null) onCenterChanged!(c);
          }
        },
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.doubleTapZoom
              : InteractiveFlag.none,
        ),
      ),
      children: [
        _tileLayer(),
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.85),
                strokeWidth: 5,
              ),
            ],
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final m in markers)
                Marker(
                  point: m.point,
                  width: m.size,
                  height: m.size,
                  child: m.child,
                ),
            ],
          ),
      ],
    );
  }

  static Widget _tileLayer() {
    if (kIsWeb) {
      // OSM/Neshan tiles are blocked by browser CORS on web. Carto allows it.
      return TileLayer(
        urlTemplate:
            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
        subdomains: const ['a', 'b', 'c', 'd'],
        userAgentPackageName: 'com.getir_style_delivery_ui.app',
        maxZoom: 20,
        tileProvider: CancellableNetworkTileProvider(silenceExceptions: true),
      );
    }
    return TileLayer(
      urlTemplate: NeshanService.tileUrlTemplate,
      userAgentPackageName: 'com.example.getir_style_delivery_ui_v2',
      maxZoom: 19,
      tileProvider: CancellableNetworkTileProvider(silenceExceptions: true),
    );
  }
}

class NeshanMapMarker {
  const NeshanMapMarker({
    required this.point,
    required this.child,
    this.size = 44,
  });

  final LatLng point;
  final Widget child;
  final double size;
}
