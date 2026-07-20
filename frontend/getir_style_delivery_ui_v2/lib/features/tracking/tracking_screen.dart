import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/address_model.dart';
import '../../data/models/neshan_reverse_result.dart';
import '../../core/network/neshan_service.dart';
import '../../widgets/profile_menu_button.dart';
import '../../widgets/neshan_map_view.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/order_model.dart';
import '../../widgets/placeholder_image.dart';
import '../address/address_manager_sheet.dart';
import '../cart/cart_checkout_footer.dart';
import '../cart/cart_provider.dart';
import 'voice_call_screen.dart';

/// Live delivery tracking: map (top half) + ETA and the peyk's real-time
/// position below. Peyk GPS is shown only after the peyk confirms pickup;
/// order status updates arrive over a dedicated WebSocket.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

// Tehran city center — used as the destination anchor at pilot scale, since
// orders carry a free-text address rather than coordinates.
const _cityCenter = LatLng(35.6892, 51.3890);

const _activeStatuses = {'pending', 'accepted', 'preparing', 'picked_up'};

const _activeMapHeightFactor = 0.58;
const _idleMapHeightFactor = 0.45;

/// Pinned map band — stays fixed while the rest of the page scrolls beneath it.
class _FixedMapHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FixedMapHeaderDelegate({required this.height, required this.map});

  final double height;
  final Widget map;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return map;
  }

  @override
  bool shouldRebuild(covariant _FixedMapHeaderDelegate old) =>
      height != old.height;
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _map = MapController();

  OrderModel? _order;
  bool _loading = true;

  LatLng _destination = _cityCenter;
  LatLng? _peyk;
  int _etaMinutes = 25;
  bool _live = false; // true once real GPS arrives over the socket

  // Neshan routing.
  List<LatLng> _routePoints = [];
  String _distanceText = '';
  int _ticks = 0;

  WebSocketChannel? _trackingChannel;
  WebSocketChannel? _orderChannel;
  StreamSubscription? _trackingSub;
  StreamSubscription? _orderSub;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _trackingSub?.cancel();
    _orderSub?.cancel();
    _trackingChannel?.sink.close();
    _orderChannel?.sink.close();
    super.dispose();
  }

  Future<void> _load() async {
    final address = context.read<AddressProvider>().selected;
    try {
      final orders = await AppServices.instance.orders.getOrders();
      final active = orders
          .where((o) => _activeStatuses.contains(o.status))
          .cast<OrderModel?>()
          .firstWhere((_) => true, orElse: () => null);
      final dest = address != null && address.hasCoordinates
          ? LatLng(address.latitude!, address.longitude!)
          : _cityCenter;
      if (!mounted) return;
      setState(() {
        _order = active;
        _loading = false;
        _destination = dest;
        _peyk = null;
        _live = false;
        _routePoints = [];
      });
      if (active != null) {
        _connectTrackingSocket(active.id);
        _connectOrderSocket(active.id);
        _startPolling(active.id);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyOrder(OrderModel order) {
    if (!mounted) return;
    if (order.status == 'delivered' || order.status == 'cancelled') {
      _clearActiveOrder(showDelivered: order.status == 'delivered');
      return;
    }
    final tracking = order.status == 'picked_up';
    setState(() {
      _order = order;
      if (!tracking) {
        _peyk = null;
        _live = false;
        _routePoints = [];
        _distanceText = '';
      }
    });
    if (tracking && _peyk != null) {
      _fetchRoute();
    } else {
      _fitDestinationOnly();
    }
  }

  void _clearActiveOrder({bool showDelivered = false}) {
    _poll?.cancel();
    _poll = null;
    _trackingSub?.cancel();
    _orderSub?.cancel();
    _trackingChannel?.sink.close();
    _orderChannel?.sink.close();
    _trackingChannel = null;
    _orderChannel = null;
    if (!mounted) return;
    setState(() {
      _order = null;
      _peyk = null;
      _live = false;
      _routePoints = [];
    });
    if (showDelivered) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderDeliveredSnackbar)),
      );
    }
  }

  Future<void> _refreshOrder(String orderId) async {
    try {
      final order = await AppServices.instance.orders.getOrder(orderId);
      _applyOrder(order);
    } catch (_) {/* keep last known state */}
  }

  void _startPolling(String orderId) {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _refreshOrder(orderId));
  }
  void _syncDestinationFromAddress() {
    final address = context.read<AddressProvider>().selected;
    if (address != null && address.hasCoordinates) {
      _destination = LatLng(address.latitude!, address.longitude!);
    }
  }

  Future<void> _fetchRoute() async {
    final p = _peyk;
    if (p == null) return;
    _syncDestinationFromAddress();
    final result = await AppServices.instance.tracking.route(p, _destination);
    if (!mounted) return;
    if (result == null || result.points.length < 2) {
      setState(() => _routePoints = []);
      return;
    }
    final snapped = NeshanService.snapRouteEndpoints(
      result.points,
      p,
      _destination,
    );
    if (!NeshanService.routeConnects(p, _destination, snapped)) {
      setState(() => _routePoints = []);
      return;
    }
    setState(() {
      _routePoints = snapped;
      _distanceText = result.distanceText;
      if (result.durationMinutes > 0) _etaMinutes = result.durationMinutes;
    });
    _fitCamera();
  }

  /// Fast ETA refresh via Neshan Distance Matrix (live traffic).
  Future<void> _fetchEta() async {
    final p = _peyk;
    if (p == null) return;
    final result = await AppServices.instance.tracking.distance(p, _destination);
    if (result == null || !mounted) return;
    setState(() {
      _distanceText = result.distanceText;
      if (result.durationMinutes > 0) _etaMinutes = result.durationMinutes;
    });
  }

  Future<void> _connectTrackingSocket(String orderId) async {
    try {
      final token = await AppServices.instance.apiClient.accessToken;
      final wsBase = AppConfig.serverOrigin
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final uri = Uri.parse('$wsBase/ws/tracking/$orderId/'
          '${token != null ? '?token=$token' : ''}');
      _trackingChannel = WebSocketChannel.connect(uri);
      _trackingSub = _trackingChannel!.stream.listen(
        _onTrackingMessage,
        onError: (_) {},
        onDone: () {},
        cancelOnError: true,
      );
    } catch (_) {
      // Polling still refreshes order status if the socket is unavailable.
    }
  }

  Future<void> _connectOrderSocket(String orderId) async {
    try {
      final token = await AppServices.instance.apiClient.accessToken;
      final wsBase = AppConfig.serverOrigin
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final uri = Uri.parse('$wsBase/ws/orders/$orderId/'
          '${token != null ? '?token=$token' : ''}');
      _orderChannel = WebSocketChannel.connect(uri);
      _orderSub = _orderChannel!.stream.listen(
        _onOrderMessage,
        onError: (_) {},
        onDone: () {},
        cancelOnError: true,
      );
    } catch (_) {
      // Polling fallback keeps status in sync.
    }
  }

  void _onOrderMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      if (data['type'] != 'order.status') return;
      final status = data['status'] as String? ?? '';
      final orderId = data['order_id'] as String? ?? _order?.id;
      if (orderId == null) return;
      if (status == 'delivered' || status == 'cancelled') {
        _clearActiveOrder(showDelivered: status == 'delivered');
        return;
      }
      if (_order != null) {
        setState(() => _order = _order!.copyWith(status: status));
      }
      _refreshOrder(orderId);
    } catch (_) {/* ignore malformed frames */}
  }

  void _onTrackingMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      if (data['type'] != 'location.update') return;
      if (_order?.status != 'picked_up') return;
      final lat = (data['latitude'] as num).toDouble();
      final lng = (data['longitude'] as num).toDouble();
      if (!mounted) return;
      setState(() {
        _live = true;
        _peyk = LatLng(lat, lng);
      });
      _fitCamera();
      _fetchEta();
      if (_ticks++ % 4 == 0) _fetchRoute();
    } catch (_) {/* ignore malformed frames */}
  }

  void _fitDestinationOnly() {
    try {
      _map.move(_destination, 14);
    } catch (_) {/* map not ready yet */}
  }

  void _fitCamera() {
    final p = _peyk;
    if (p == null) return;
    try {
      _map.fitCamera(
        CameraFit.coordinates(
          coordinates: [p, _destination],
          padding: const EdgeInsets.all(60),
          maxZoom: 15,
        ),
      );
    } catch (_) {/* map not ready yet */}
  }

  int get _statusStep {
    switch (_order?.status) {
      case 'delivered':
        return 2;
      case 'picked_up':
        return 1;
      default:
        return 0;
    }
  }

  bool get _showPeykOnMap =>
      _order?.status == 'picked_up' && _peyk != null;

  Future<void> _startVoiceCall(OrderModel order) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!order.hasAssignedPeyk) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.callAfterPeykAssigned)),
      );
      return;
    }
    try {
      final session = await AppServices.instance.communications.initiateOrderCall(order.id);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VoiceCallScreen(
          session: session,
          peerName: order.assignedPeykName?.isNotEmpty == true
              ? order.assignedPeykName!
              : l10n.getirStyleDeliveryUiCourier,
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.callUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final mapHeight = MediaQuery.sizeOf(context).height * _activeMapHeightFactor;
    final idle = !_loading && _order == null;

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      extendBodyBehindAppBar: idle,
      appBar: AppBar(
        backgroundColor: idle
            ? GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.9)
            : GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        elevation: idle ? 0 : 1,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: const ProfileMenuButton(color: GetirStyleDeliveryUiColors.onPrimary),
        title: Text(
          'GetirStyleDeliveryUi',
          style: GetirStyleDeliveryUiTypography.headlineLg(
            locale,
            color: GetirStyleDeliveryUiColors.onPrimary,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? _NoActiveOrder(l10n: l10n, locale: locale)
              : CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _FixedMapHeaderDelegate(
                        height: mapHeight,
                        map: _buildMap(),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        GetirStyleDeliveryUiSpacing.marginMobile,
                        GetirStyleDeliveryUiSpacing.marginMobile,
                        GetirStyleDeliveryUiSpacing.marginMobile,
                        shellBottomInset(context),
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _TrackingInfo(
                          l10n: l10n,
                          locale: locale,
                          order: _order!,
                          etaMinutes: _etaMinutes,
                          distanceText: _distanceText,
                          step: _statusStep,
                          live: _live,
                          onCall: _startVoiceCall,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  /// Interactive Neshan map with live route polyline and markers.
  Widget _buildMap() {
    final p = _showPeykOnMap ? _peyk : null;
    final bounds = p != null ? [p, _destination] : [_destination];
    return Stack(
      fit: StackFit.expand,
      children: [
        NeshanMapView(
          mapController: _map,
          center: p ?? _destination,
          zoom: 14,
          routePoints: p != null ? _routePoints : const [],
          fitBounds: bounds,
          markers: [
            NeshanMapMarker(point: _destination, child: const _DestinationPin()),
            if (p != null)
              NeshanMapMarker(point: p, size: 48, child: const _PeykPin()),
          ],
        ),
        Positioned(
          right: 12,
          top: 56,
          child: MapZoomControls(controller: _map),
        ),
      ],
    );
  }
}

/// Top map band — picker (once) or saved preview, edge-to-edge under the app bar.
class _IdleTopMapSection extends StatelessWidget {
  const _IdleTopMapSection();

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressProvider>();
    if (!addresses.hasMappedAddress) {
      return const _AddressMapPicker();
    }
    final selected = addresses.selected;
    if (selected == null) return const _AddressMapPicker();
    return _SavedAddressMapTop(address: selected);
  }
}

/// One-time map picker at the top (full bleed, blends with app bar).
class _AddressMapPicker extends StatefulWidget {
  const _AddressMapPicker();

  @override
  State<_AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<_AddressMapPicker> {
  final MapController _map = MapController();
  Timer? _geocodeDebounce;
  NeshanReverseResult? _estimate;
  bool _resolving = false;
  bool _saving = false;
  String? _resolveError;

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  void _scheduleResolve() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 450), _resolveCenter);
  }

  Future<void> _resolveCenter() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _resolving = true;
      _resolveError = null;
    });
    final point = _map.camera.center;
    final result = await AppServices.instance.tracking.reverse(point);
    if (!mounted) return;
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

  Future<void> _confirmAddress() async {
    final estimate = _estimate;
    if (estimate == null || estimate.formattedAddress.isEmpty) return;
    setState(() => _saving = true);
    await context.read<AddressProvider>().saveAsDefaultFromMap(
          title: estimate.shortLabel,
          details: estimate.formattedAddress,
          city: estimate.resolvedCity,
          latitude: estimate.lat,
          longitude: estimate.lng,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.defaultAddressSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;

    return Stack(
      fit: StackFit.expand,
      children: [
        NeshanMapView(
          mapController: _map,
          center: _cityCenter,
          zoom: 13,
          onMapReady: _resolveCenter,
          onCenterChanged: (_) => _scheduleResolve(),
          onTap: (_, point) => _moveTo(point),
        ),
        const IgnorePointer(
          child: Align(
            alignment: Alignment(0, -0.05),
            child: _MapPickerPin(),
          ),
        ),
        Positioned(
          left: 12,
          top: topPad,
          child: MapZoomControls(controller: _map),
        ),
        Positioned(
          right: 12,
          top: topPad,
          child: MapCurrentLocationButton(
            onLocated: (p) => _moveTo(p, zoom: 16),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _MapAddressOverlay(
            l10n: l10n,
            locale: locale,
            title: _estimate?.shortLabel ?? l10n.newAddress,
            subtitle: _resolving
                ? l10n.resolvingAddress
                : _resolveError ??
                    _estimate?.formattedAddress ??
                    l10n.moveMapHint,
            subtitleColor: _resolveError != null
                ? GetirStyleDeliveryUiColors.error
                : GetirStyleDeliveryUiColors.onSurfaceVariant,
            actionLabel: l10n.saveAddress,
            onAction: _confirmAddress,
            actionEnabled: _estimate != null &&
                _estimate!.formattedAddress.isNotEmpty &&
                !_resolving &&
                !_saving,
            actionLoading: _saving,
            onManage: null,
          ),
        ),
      ],
    );
  }
}

/// Read-only top map for a saved default address.
class _SavedAddressMapTop extends StatelessWidget {
  const _SavedAddressMapTop({required this.address});

  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final center = LatLng(address.latitude!, address.longitude!);

    return Stack(
      fit: StackFit.expand,
      children: [
        NeshanMapView(
          center: center,
          zoom: 15,
          interactive: false,
          markers: [
            NeshanMapMarker(point: center, child: const _DestinationPin()),
          ],
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _MapAddressOverlay(
            l10n: l10n,
            locale: locale,
            title: address.title,
            subtitle: address.details,
            onManage: () => showAddressManager(context),
          ),
        ),
      ],
    );
  }
}

/// Address chip floating on the bottom edge of the top map.
class _MapAddressOverlay extends StatelessWidget {
  const _MapAddressOverlay({
    required this.l10n,
    required this.locale,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.actionLabel,
    this.onAction,
    this.actionEnabled = true,
    this.actionLoading = false,
    this.onManage,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;
  final bool actionLoading;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      elevation: 3,
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
                const Icon(Icons.location_on, color: GetirStyleDeliveryUiColors.primary),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GetirStyleDeliveryUiTypography.bodySm(
                          locale,
                          color: subtitleColor ?? GetirStyleDeliveryUiColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onManage != null)
                  TextButton(
                    onPressed: onManage,
                    child: Text(
                      l10n.change,
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                  ),
                ),
                onPressed: actionEnabled && !actionLoading ? onAction : null,
                child: actionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: GetirStyleDeliveryUiColors.onPrimary,
                        ),
                      )
                    : Text(
                        actionLabel!,
                        style: GetirStyleDeliveryUiTypography.labelMd(
                          locale,
                          color: GetirStyleDeliveryUiColors.onPrimary,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapPickerPin extends StatelessWidget {
  const _MapPickerPin();

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
              BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6),
            ],
          ),
          child: const Icon(
            Icons.home,
            size: 22,
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

class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.secondaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6),
        ],
      ),
      child: const Icon(Icons.home, size: 22, color: GetirStyleDeliveryUiColors.onSecondaryContainer),
    );
  }
}

class _PeykPin extends StatelessWidget {
  const _PeykPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.delivery_dining, size: 26, color: GetirStyleDeliveryUiColors.onPrimary),
    );
  }
}

class _TrackingInfo extends StatelessWidget {
  const _TrackingInfo({
    required this.l10n,
    required this.locale,
    required this.order,
    required this.etaMinutes,
    required this.distanceText,
    required this.step,
    required this.live,
    required this.onCall,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final OrderModel order;
  final int etaMinutes;
  final String distanceText;
  final int step;
  final bool live;
  final void Function(OrderModel order) onCall;

  String _etaTitle() {
    if (order.status == 'picked_up') return l10n.etaTitle;
    if (order.hasAssignedPeyk) return l10n.assignedPeykTitle;
    return l10n.orderStatusHeader;
  }

  String _etaValue() {
    if (order.status == 'picked_up') {
      return etaMinutes <= 0 ? l10n.arrivingSoon : l10n.etaMinutes(etaMinutes);
    }
    if (order.status == 'preparing' && order.hasAssignedPeyk) {
      return l10n.peykPickingUp;
    }
    if (order.status == 'accepted') return l10n.awaitingPreparation;
    return l10n.processing;
  }

  String _gpsLabel() {
    if (order.status != 'picked_up') {
      return l10n.peykLocationAfterPickup;
    }
    if (live) return l10n.livePeykLocation;
    return l10n.awaitingPeykLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ETA hero box.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: GetirStyleDeliveryUiColors.primaryFixed,
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
          ),
          child: Column(
            children: [
              Text(
                _etaTitle(),
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _etaValue(),
                textAlign: TextAlign.center,
                style: GetirStyleDeliveryUiTypography.headlineLg(
                  locale,
                  color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                ).copyWith(fontWeight: FontWeight.w900),
              ),
              if (distanceText.isNotEmpty && order.status == 'picked_up') ...[
                const SizedBox(height: 2),
                Text(
                  l10n.distanceLabel(distanceText),
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    live ? Icons.gps_fixed : Icons.gps_not_fixed,
                    size: 14,
                    color: live ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _gpsLabel(),
                      textAlign: TextAlign.center,
                      style: GetirStyleDeliveryUiTypography.labelSm(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (order.deliveryCode.isNotEmpty && order.status != 'delivered') ...[
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
          _ReceiveCodeCard(code: order.deliveryCode, l10n: l10n, locale: locale),
        ],
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
        _StatusSteps(step: step, l10n: l10n, locale: locale),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
        _PeykCard(
          l10n: l10n,
          locale: locale,
          order: order,
          onCall: order.hasAssignedPeyk ? () => onCall(order) : null,
        ),
        const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
            border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: GetirStyleDeliveryUiColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.orderFromVendor(order.vendorName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.bodyMd(
                    locale,
                    color: GetirStyleDeliveryUiColors.onSurface,
                  ),
                ),
              ),
              Text(
                '#${order.id.substring(0, 6)}',
                style: GetirStyleDeliveryUiTypography.labelMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The 6-digit handoff PIN the customer reads to the peyk on delivery.
class _ReceiveCodeCard extends StatelessWidget {
  const _ReceiveCodeCard({required this.code, required this.l10n, required this.locale});

  final String code;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GetirStyleDeliveryUiColors.primary, GetirStyleDeliveryUiColors.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user,
                  size: 16, color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(
                l10n.deliveryCodeTitle,
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            code,
            textDirection: TextDirection.ltr,
            style: GetirStyleDeliveryUiTypography.headlineLg(
              locale,
              color: GetirStyleDeliveryUiColors.secondaryContainer,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 12, fontSize: 38),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tellCodeToPeyk,
            textAlign: TextAlign.center,
            style: GetirStyleDeliveryUiTypography.labelSm(
              locale,
              color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSteps extends StatelessWidget {
  const _StatusSteps({required this.step, required this.l10n, required this.locale});

  final int step;
  final AppLocalizations l10n;
  final Locale locale;

  static const _icons = [Icons.restaurant, Icons.delivery_dining, Icons.check_circle];

  @override
  Widget build(BuildContext context) {
    final labels = [l10n.stepPreparing, l10n.stepOnWay, l10n.stepDelivered];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? GetirStyleDeliveryUiColors.primary
                          : GetirStyleDeliveryUiColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icons[i],
                      size: 20,
                      color: i <= step
                          ? GetirStyleDeliveryUiColors.onPrimary
                          : GetirStyleDeliveryUiColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: GetirStyleDeliveryUiTypography.labelSm(
                      locale,
                      color: i <= step
                          ? GetirStyleDeliveryUiColors.onSurface
                          : GetirStyleDeliveryUiColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (i < 2)
              Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.only(bottom: 22),
                color: i < step ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.primaryFixed,
              ),
          ],
        ],
      ),
    );
  }
}

class _PeykCard extends StatelessWidget {
  const _PeykCard({
    required this.l10n,
    required this.locale,
    required this.order,
    required this.onCall,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final OrderModel order;
  final VoidCallback? onCall;

  String _name() =>
      order.assignedPeykName?.isNotEmpty == true ? order.assignedPeykName! : l10n.getirStyleDeliveryUiCourier;

  String _subtitle() {
    switch (order.status) {
      case 'picked_up':
        return l10n.deliveringYourOrder;
      case 'preparing':
        return order.hasAssignedPeyk
            ? l10n.peykReceivingFromVendor
            : l10n.awaitingPeykAssignment;
      case 'accepted':
        return l10n.orderConfirmedPreparing;
      default:
        return l10n.orderRegistered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: GetirStyleDeliveryUiColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name(),
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                  ),
                ),
                Text(
                  _subtitle(),
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: onCall == null ? GetirStyleDeliveryUiColors.outlineVariant : GetirStyleDeliveryUiColors.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onCall,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.call, color: GetirStyleDeliveryUiColors.onPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when there's no active delivery: top map + scrollable cart below.
class _NoActiveOrder extends StatelessWidget {
  const _NoActiveOrder({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final mapHeight = MediaQuery.sizeOf(context).height * _idleMapHeightFactor;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _FixedMapHeaderDelegate(
                  height: mapHeight,
                  map: const _IdleTopMapSection(),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  GetirStyleDeliveryUiSpacing.marginMobile,
                  GetirStyleDeliveryUiSpacing.marginMobile,
                  GetirStyleDeliveryUiSpacing.marginMobile,
                  cart.isEmpty ? shellBottomInset(context) : GetirStyleDeliveryUiSpacing.stackSm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: GetirStyleDeliveryUiColors.primaryFixed,
                          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_shipping_outlined,
                                  size: 40, color: GetirStyleDeliveryUiColors.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noActiveOrder,
                              style: GetirStyleDeliveryUiTypography.headlineSm(
                                locale,
                                color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.noActiveOrderDesc,
                              textAlign: TextAlign.center,
                              style: GetirStyleDeliveryUiTypography.bodySm(
                                locale,
                                color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                      Text(
                        l10n.yourCart,
                        style: GetirStyleDeliveryUiTypography.labelLg(
                          locale,
                          color: GetirStyleDeliveryUiColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
                      if (cart.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                            border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.shopping_cart_outlined,
                                  size: 36, color: GetirStyleDeliveryUiColors.outline),
                              const SizedBox(height: 8),
                              Text(
                                l10n.cartEmpty,
                                style: GetirStyleDeliveryUiTypography.bodyMd(
                                  locale,
                                  color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        for (final line in cart.lines)
                          _CartPreviewTile(line: line, locale: locale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!cart.isEmpty)
          CartCheckoutFooter(
            cart: cart,
            locale: locale,
            embeddedInShell: true,
          ),
      ],
    );
  }
}

class _CartPreviewTile extends StatelessWidget {
  const _CartPreviewTile({required this.line, required this.locale});

  final CartLine line;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          PlaceholderImage(
            networkUrl: line.item.displayImageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
            fallbackIcon: Icons.fastfood_outlined,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${line.quantity} × ${formatToman(line.item.price)}',
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatToman(line.lineTotal),
            style: GetirStyleDeliveryUiTypography.labelMd(locale, color: GetirStyleDeliveryUiColors.primary),
          ),
        ],
      ),
    );
  }
}
