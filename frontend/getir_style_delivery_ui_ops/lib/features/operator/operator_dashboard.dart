import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_services.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/order_status.dart';
import '../../data/models/order_model.dart';
import '../../data/models/peyk_model.dart';
import '../settings/settings_screen.dart';

const _fa = Locale('fa');

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({super.key});

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tabs = [
      const _OrdersTab(),
      const _PeyksTab(),
      const _VendorsTab(),
      SettingsTabScaffold(appBarTitle: 'تنظیمات — ${user?.fullName ?? ''}'),
    ];
    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: _tab < 3
          ? AppBar(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
              centerTitle: true,
              title: Text('پنل اپراتور — ${user?.fullName ?? ''}',
                  style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
            )
          : null,
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'سفارش‌ها'),
          NavigationDestination(icon: Icon(Icons.delivery_dining), label: 'پیک‌ها'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'فروشگاه‌ها'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'تنظیمات'),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Orders ───────────────────────────────
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<OrderModel>? _orders;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 6), (_) => _load());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final orders = await AppServices.instance.ops.getOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (_) {/* keep last data */}
  }

  Future<void> _setStatus(OrderModel o, String to) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.updateOrderStatus(o.id, to);
      messenger.showSnackBar(SnackBar(content: Text('وضعیت: ${orderStatusFa[to]}')));
      await _load();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('عملیات ناموفق بود.')));
    }
  }

  Future<void> _assign(OrderModel o) async {
    final peyks = await AppServices.instance.ops.getPeyks();
    if (!mounted) return;
    final available = peyks.where((p) => p.isAvailable).toList();
    final pool = available.isNotEmpty ? available : peyks;
    final picked = await showModalBottomSheet<PeykModel>(
      context: context,
      backgroundColor: GetirStyleDeliveryUiColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GetirStyleDeliveryUiRadius.xxl)),
      ),
      builder: (_) => _PeykPickerSheet(peyks: pool),
    );
    if (picked == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    // Optimistic update so the card reflects the assignment immediately.
    setState(() {
      _orders = _orders
          ?.map((order) => order.id == o.id
              ? order.copyWith(
                  assignedPeykId: picked.userId,
                  assignedPeykName: picked.fullName,
                )
              : order)
          .toList();
    });
    try {
      await AppServices.instance.ops.assignPeyk(o.id, picked.userId);
      messenger.showSnackBar(SnackBar(content: Text('${picked.fullName} اختصاص یافت')));
      await _load();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('اختصاص پیک ناموفق بود.')));
      await _load(); // revert optimistic state from server
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;
    return RefreshIndicator(
      onRefresh: _load,
      child: Builder(
        builder: (context) {
          if (orders == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orders.isEmpty) {
            return const _Empty(icon: Icons.receipt_long, text: 'سفارشی وجود ندارد');
          }
          return ListView(
            padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
            children: [for (final o in orders) _OrderCard(o, _setStatus, _assign)],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(this.order, this.onStatus, this.onAssign);

  final OrderModel order;
  final void Function(OrderModel, String) onStatus;
  final void Function(OrderModel) onAssign;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(order.status);
    final s = order.status;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.vendorName.isEmpty ? 'سفارش' : order.vendorName,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full)),
                child: Text(orderStatusFa[s] ?? s,
                    style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${order.deliveryAddress}، ${order.deliveryCity}',
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GetirStyleDeliveryUiTypography.bodySm(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Row(children: [
            Text(formatToman(order.totalAmount),
                style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.primary)),
            const SizedBox(width: 8),
            Text('#${order.id.substring(0, 6)} · ${order.items.length} قلم',
                style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
          ]),
          if (order.hasAssignedPeyk) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.delivery_dining, size: 16, color: GetirStyleDeliveryUiColors.success),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'پیک: ${order.assignedPeykName ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.success),
                ),
              ),
            ]),
            if (s == 'preparing')
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'تحویل از فروشنده را پیک در اپ خود تأیید می‌کند',
                  style: GetirStyleDeliveryUiTypography.labelSm(
                    _fa,
                    color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (s == 'pending')
              _act('تأیید', Icons.check, () => onStatus(order, 'accepted')),
            if (s == 'accepted')
              _act('آماده‌سازی', Icons.soup_kitchen, () => onStatus(order, 'preparing')),
            if ((s == 'accepted' || s == 'preparing') && !order.hasAssignedPeyk)
              _act('اختصاص پیک', Icons.delivery_dining, () => onAssign(order),
                  filled: true),
            if (s == 'pending' || s == 'accepted')
              _act('لغو', Icons.close, () => onStatus(order, 'cancelled'), danger: true),
          ]),
        ],
      ),
    );
  }

  Widget _act(String label, IconData icon, VoidCallback onTap,
      {bool filled = false, bool danger = false}) {
    final bg = danger
        ? GetirStyleDeliveryUiColors.errorContainer
        : filled
            ? GetirStyleDeliveryUiColors.primary
            : GetirStyleDeliveryUiColors.primaryFixed;
    final fg = danger
        ? GetirStyleDeliveryUiColors.onErrorContainer
        : filled
            ? GetirStyleDeliveryUiColors.onPrimary
            : GetirStyleDeliveryUiColors.onPrimaryFixed;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 4),
            Text(label, style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: fg)),
          ]),
        ),
      ),
    );
  }
}

class _PeykPickerSheet extends StatelessWidget {
  const _PeykPickerSheet({required this.peyks});
  final List<PeykModel> peyks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('انتخاب پیک',
                style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
            const SizedBox(height: 12),
            if (peyks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('پیکی موجود نیست', textAlign: TextAlign.center),
              ),
            for (final p in peyks)
              ListTile(
                onTap: () => Navigator.pop(context, p),
                leading: CircleAvatar(
                  backgroundColor: p.isAvailable
                      ? GetirStyleDeliveryUiColors.successContainer
                      : GetirStyleDeliveryUiColors.surfaceContainerHigh,
                  child: Icon(Icons.delivery_dining,
                      color: p.isAvailable ? GetirStyleDeliveryUiColors.success : GetirStyleDeliveryUiColors.outline),
                ),
                title: Text(p.fullName,
                    style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
                subtitle: Text(
                    '${p.peykCode} · ${p.vehicleType == 'car' ? 'خودرو' : 'موتور'} · ⭐${p.rating.toStringAsFixed(1)}'
                    '${p.isAvailable ? ' · آنلاین' : ''}'),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── Peyks ───────────────────────────────
class _PeyksTab extends StatefulWidget {
  const _PeyksTab();
  @override
  State<_PeyksTab> createState() => _PeyksTabState();
}

class _PeyksTabState extends State<_PeyksTab> {
  List<PeykModel>? _peyks;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    // Near-realtime: refresh the board every 4s so peyks appear/disappear as
    // they go online/offline (WebSocket push needs Daphne/JWT-WS auth).
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final peyks = await AppServices.instance.ops.getPeyks();
      if (mounted) setState(() => _peyks = peyks);
    } catch (_) {/* keep last data on transient errors */}
  }

  Future<void> _toggle(PeykModel p) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.setPeykAvailability(p.id, !p.isAvailable);
      await _load();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تغییر وضعیت ناموفق بود.')));
    }
  }

  Future<void> _call(PeykModel p) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.callPeyk(p.userId);
      messenger.showSnackBar(SnackBar(content: Text('در حال تماس با ${p.fullName}…')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('برقراری تماس ناموفق بود.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final peyks = _peyks;
    return RefreshIndicator(
      onRefresh: _load,
      child: Builder(
        builder: (context) {
          if (peyks == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (peyks.isEmpty) {
            return const _Empty(icon: Icons.delivery_dining, text: 'پیکی ثبت نشده است');
          }
          return ListView(
            padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
            children: [
              _OnlineCount(peyks: peyks),
              for (final p in peyks)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                    border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: p.isAvailable
                          ? GetirStyleDeliveryUiColors.successContainer
                          : GetirStyleDeliveryUiColors.surfaceContainerHigh,
                      child: Icon(Icons.delivery_dining,
                          color: p.isAvailable ? GetirStyleDeliveryUiColors.success : GetirStyleDeliveryUiColors.outline),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.fullName,
                            style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
                        Text(
                            '${p.peykCode} · ${p.vehicleType == 'car' ? 'خودرو' : 'موتور'} · ⭐${p.rating.toStringAsFixed(1)}',
                            style: GetirStyleDeliveryUiTypography.bodySm(
                                _fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
                      ]),
                    ),
                    IconButton(
                      tooltip: 'تماس',
                      icon: const Icon(Icons.call, color: GetirStyleDeliveryUiColors.primary),
                      onPressed: () => _call(p),
                    ),
                    Switch(value: p.isAvailable, onChanged: (_) => _toggle(p)),
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OnlineCount extends StatelessWidget {
  const _OnlineCount({required this.peyks});
  final List<PeykModel> peyks;

  @override
  Widget build(BuildContext context) {
    final online = peyks.where((p) => p.isAvailable).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
      ),
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: const BoxDecoration(
              color: GetirStyleDeliveryUiColors.success, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$online پیک آنلاین از ${peyks.length}',
              style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixed)),
        ),
        Text('به‌روزرسانی خودکار',
            style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant)),
      ]),
    );
  }
}

// ─────────────────────────────── Vendors ──────────────────────────────
class _VendorsTab extends StatefulWidget {
  const _VendorsTab();
  @override
  State<_VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<_VendorsTab> {
  late Future<List<VendorChecklistModel>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = AppServices.instance.ops.getVendorChecklist();

  Future<void> _toggleItem(ChecklistItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.setItemAvailability(item.id, !item.isAvailable);
      setState(_reload);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تغییر ناموفق بود.')));
    }
  }

  Future<void> _callVendor(VendorChecklistModel v) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.callVendor(v.vendorId);
      messenger.showSnackBar(
          SnackBar(content: Text('در حال تماس با ${v.businessName}…')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('برقراری تماس ناموفق بود.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(_reload),
      child: FutureBuilder<List<VendorChecklistModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final vendors = snapshot.data ?? [];
          if (vendors.isEmpty) {
            return const _Empty(icon: Icons.storefront, text: 'فروشگاهی در شهر شما نیست');
          }
          return ListView(
            padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
            children: [
              for (final v in vendors)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                    border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.storefront, color: GetirStyleDeliveryUiColors.primary),
                      title: Text(v.businessName,
                          style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
                      subtitle: Text('${v.items.length} محصول'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GetirStyleDeliveryUiColors.primary,
                                side: const BorderSide(color: GetirStyleDeliveryUiColors.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
                              ),
                              onPressed: () => _callVendor(v),
                              icon: const Icon(Icons.call, size: 18),
                              label: const Text('تماس با فروشنده (آماده‌سازی/موجودی)'),
                            ),
                          ),
                        ),
                        for (final it in v.items)
                          ListTile(
                            title: Text(it.name,
                                style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
                            subtitle: Text(formatToman(it.price)),
                            trailing: Switch(
                                value: it.isAvailable, onChanged: (_) => _toggleItem(it)),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const SizedBox(height: 120),
      Icon(icon, size: 56, color: GetirStyleDeliveryUiColors.outline),
      const SizedBox(height: 12),
      Text(text,
          textAlign: TextAlign.center,
          style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
    ]);
  }
}
