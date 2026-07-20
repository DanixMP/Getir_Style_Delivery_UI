import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_services.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/location_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/order_model.dart';
import '../settings/settings_screen.dart';
import '../../widgets/peyk_settings_drawer.dart';
import 'voice_call_screen.dart';

const _fa = Locale('fa');

const _statusFa = {
  'pending': 'در انتظار',
  'accepted': 'تأیید شده',
  'preparing': 'آماده‌سازی',
  'picked_up': 'در حال ارسال',
  'delivered': 'تحویل شده',
  'cancelled': 'لغو شده',
};

const _callableStatuses = {'accepted', 'preparing', 'picked_up'};

class PeykHomeScreen extends StatefulWidget {
  const PeykHomeScreen({super.key});

  @override
  State<PeykHomeScreen> createState() => _PeykHomeScreenState();
}

class _PeykHomeScreenState extends State<PeykHomeScreen> {
  List<OrderModel>? _orders;
  Timer? _poll;
  Set<String> _knownIds = {};
  WebSocketChannel? _assignmentSocket;
  StreamSubscription? _assignmentSub;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
    _connectAssignmentSocket();
    // Fallback poll when WebSocket is unavailable (e.g. runserver without Daphne).
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _assignmentSub?.cancel();
    _assignmentSocket?.sink.close();
    super.dispose();
  }

  Future<void> _connectAssignmentSocket() async {
    try {
      final token = await AppServices.instance.apiClient.accessToken;
      if (token == null || token.isEmpty || !mounted) return;
      final wsBase = AppConfig.serverOrigin
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final uri = Uri.parse('$wsBase/ws/peyk/assignments/?token=$token');
      _assignmentSocket = WebSocketChannel.connect(uri);
      _assignmentSub = _assignmentSocket!.stream.listen(
        _onAssignmentEvent,
        onError: (_) {},
        onDone: () {},
        cancelOnError: true,
      );
    } catch (_) {
      // Polling fallback keeps the screen usable.
    }
  }

  void _onAssignmentEvent(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      if (data['type'] != 'assignment.created') return;
      if (!mounted) return;
      _load(showNewAssignmentNotice: true);
    } catch (_) {}
  }

  Future<void> _load({bool initial = false, bool showNewAssignmentNotice = false}) async {
    try {
      final orders = await AppServices.instance.orders.getAssignedOrders();
      if (!mounted) return;
      final ids = orders.map((o) => o.id).toSet();
      final hasNew = showNewAssignmentNotice ||
          (!initial && ids.difference(_knownIds).isNotEmpty);
      setState(() {
        _orders = orders;
        _knownIds = ids;
      });
      // Keep the location stream tagged with the order being delivered.
      final active = orders.where((o) => o.status == 'picked_up').cast<OrderModel?>().firstWhere((_) => true, orElse: () => null);
      context.read<LocationProvider>().setActiveOrder(active?.id);
      if (hasNew) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🛵 سفارش جدید به شما اختصاص یافت'),
          backgroundColor: GetirStyleDeliveryUiColors.primary,
        ));
      }
    } catch (_) {/* keep last data on transient errors */}
  }

  Future<void> _refresh() => _load();

  Future<void> _startVoiceCall(OrderModel order) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_callableStatuses.contains(order.status)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('تماس فقط برای سفارش فعال امکان‌پذیر است.')),
      );
      return;
    }
    try {
      final session = await AppServices.instance.communications.initiateOrderCall(order.id);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VoiceCallScreen(
          session: session,
          peerName: 'مشتری',
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('امکان شروع تماس وجود ندارد.')),
      );
    }
  }

  Future<void> _advance(OrderModel order, String to) async {
    final messenger = ScaffoldMessenger.of(context);
    final location = context.read<LocationProvider>();

    // Completing delivery needs the 6-digit PIN the customer reads to the peyk.
    String? code;
    if (to == 'delivered') {
      code = await _promptDeliveryPin();
      if (code == null) return; // cancelled
    }

    try {
      await AppServices.instance.orders
          .updateStatus(order.id, to, deliveryCode: code);
      if (to == 'picked_up') {
        location.setActiveOrder(order.id);
        if (!location.online) await location.goOnline();
      }
      if (to == 'delivered') location.setActiveOrder(null);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(to == 'picked_up'
            ? 'سفارش تحویل گرفته شد'
            : 'سفارش با موفقیت تحویل داده شد ✅'),
      ));
      await _load();
    } on DioException catch (e) {
      final wrongPin = e.response?.statusCode == 400 && to == 'delivered';
      messenger.showSnackBar(SnackBar(
        content: Text(wrongPin ? 'کد تحویل نادرست است.' : 'عملیات ناموفق بود.'),
      ));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('عملیات ناموفق بود.')));
    }
  }

  Future<String?> _promptDeliveryPin() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GetirStyleDeliveryUiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        ),
        title: Text('کد تحویل مشتری',
            style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'کد ۶ رقمی را از مشتری بپرسید و وارد کنید.',
              style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: GetirStyleDeliveryUiTypography.headlineMd(_fa, color: GetirStyleDeliveryUiColors.onSurface)
                  .copyWith(letterSpacing: 8, fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                filled: true,
                fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GetirStyleDeliveryUiColors.primary),
            onPressed: () {
              final c = controller.text.trim();
              if (c.length == 6) Navigator.pop(ctx, c);
            },
            child: const Text('تأیید تحویل'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      endDrawer: const PeykSettingsDrawer(),
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        centerTitle: true,
        title: Text('GETIR_STYLE_DELIVERY_UI پیک',
            style: GetirStyleDeliveryUiTypography.headlineMd(_fa, color: GetirStyleDeliveryUiColors.onPrimary)
                .copyWith(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'تنظیمات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'منو',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
          children: [
            _OnlineCard(name: user?.fullName ?? 'پیک'),
            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
            Text('سفارش‌های من',
                style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
            Builder(builder: (context) {
              final orders = _orders;
              if (orders == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (orders.isEmpty) return const _EmptyOrders();
              return Column(
                children: [
                  for (final o in orders)
                    _OrderCard(
                      order: o,
                      onAdvance: _advance,
                      onCall: _startVoiceCall,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final online = location.online;
    final sent = location.lastSentAt;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: online
              ? const [GetirStyleDeliveryUiColors.primary, GetirStyleDeliveryUiColors.tertiaryContainer]
              : [GetirStyleDeliveryUiColors.surfaceContainerHigh, GetirStyleDeliveryUiColors.surfaceContainer],
        ),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(online ? Icons.gps_fixed : Icons.gps_off,
                  color: online ? GetirStyleDeliveryUiColors.onPrimary : GetirStyleDeliveryUiColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    _fa,
                    color: online ? GetirStyleDeliveryUiColors.onPrimary : GetirStyleDeliveryUiColors.onSurface,
                  ),
                ),
              ),
              Switch(
                value: online,
                onChanged: (_) => location.toggle(),
                activeThumbColor: GetirStyleDeliveryUiColors.secondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            online ? 'آنلاین — ارسال موقعیت فعال است' : 'آفلاین',
            style: GetirStyleDeliveryUiTypography.bodyMd(
              _fa,
              color: online
                  ? GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.9)
                  : GetirStyleDeliveryUiColors.onSurfaceVariant,
            ),
          ),
          if (online) ...[
            const SizedBox(height: 8),
            Text(
              'موقعیت: ${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}'
              '${sent != null ? '  •  ${sent.hour.toString().padLeft(2, '0')}:${sent.minute.toString().padLeft(2, '0')}:${sent.second.toString().padLeft(2, '0')}' : ''}',
              textDirection: TextDirection.ltr,
              style: GetirStyleDeliveryUiTypography.labelSm(
                _fa,
                color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onAdvance,
    required this.onCall,
  });

  final OrderModel order;
  final void Function(OrderModel, String) onAdvance;
  final void Function(OrderModel) onCall;

  @override
  Widget build(BuildContext context) {
    final canPickUp = order.status == 'preparing';
    final canDeliver = order.status == 'picked_up';
    final waitingForVendor = order.status == 'accepted';
    final canCall = _callableStatuses.contains(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.vendorName.isEmpty ? 'سفارش' : order.vendorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixed),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                ),
                child: Text(
                  _statusFa[order.status] ?? order.status,
                  style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${order.deliveryAddress}، ${order.deliveryCity}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.bodySm(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                formatToman(order.totalAmount),
                style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                order.paymentMethod == 'cash'
                    ? 'پرداخت در محل'
                    : order.isPaid
                        ? 'پرداخت‌شده'
                        : 'پرداخت‌نشده',
                style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant),
              ),
            ],
          ),
          if (canCall) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: GetirStyleDeliveryUiColors.primary,
                  side: const BorderSide(color: GetirStyleDeliveryUiColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                  ),
                ),
                onPressed: () => onCall(order),
                icon: const Icon(Icons.call),
                label: Text(
                  'تماس با مشتری',
                  style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.primary),
                ),
              ),
            ),
          ],
          if (canPickUp || canDeliver) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                  ),
                ),
                onPressed: () =>
                    onAdvance(order, canPickUp ? 'picked_up' : 'delivered'),
                icon: Icon(canPickUp ? Icons.inventory_2 : Icons.check_circle),
                label: Text(
                  canPickUp ? 'تحویل گرفتن سفارش' : 'تحویل دادن به مشتری',
                  style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onPrimary),
                ),
              ),
            ),
          ] else if (waitingForVendor) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, size: 18, color: GetirStyleDeliveryUiColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سفارش به شما اختصاص یافت — در انتظار آماده‌سازی فروشنده',
                      style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (order.status == 'preparing') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: GetirStyleDeliveryUiColors.secondaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, size: 18, color: GetirStyleDeliveryUiColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سفارش آماده است — از فروشنده تحویل بگیرید و «تحویل گرفتن سفارش» را بزنید',
                      style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 44, color: GetirStyleDeliveryUiColors.outline),
          const SizedBox(height: 8),
          Text(
            'سفارشی به شما اختصاص نیافته است',
            style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
