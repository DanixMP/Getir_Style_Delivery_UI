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
import '../../data/models/menu_models.dart';
import '../../data/models/order_model.dart';
import '../settings/settings_screen.dart';

const _fa = Locale('fa');

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final title = user?.vendorBusinessName.isNotEmpty == true
        ? user!.vendorBusinessName
        : (user?.fullName ?? '');
    final tabs = [
      const _OrdersTab(),
      const _MenuTab(),
      SettingsTabScaffold(appBarTitle: 'تنظیمات — $title'),
    ];
    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: _tab < 2
          ? AppBar(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
              centerTitle: true,
              title: Text('پنل فروشنده — $title',
                  style: GetirStyleDeliveryUiTypography.headlineSm(_fa, color: GetirStyleDeliveryUiColors.onPrimary)),
            )
          : null,
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        indicatorColor: GetirStyleDeliveryUiColors.primaryFixed,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'سفارش‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'منو',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Orders (real-time) ───────────────────────────────

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<OrderModel>? _orders;
  String? _error;
  Timer? _poll;
  Set<String> _knownPending = {};

  @override
  void initState() {
    super.initState();
    _load(initial: true);
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load({bool initial = false}) async {
    try {
      final orders = await AppServices.instance.ops.getOrders();
      if (!mounted) return;

      // Detect newly-arrived pending orders to alert the vendor.
      final pending = orders.where((o) => o.status == 'pending').map((o) => o.id).toSet();
      final fresh = pending.difference(_knownPending);
      if (!initial && fresh.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: GetirStyleDeliveryUiColors.primary,
            content: Text(
              fresh.length == 1 ? 'سفارش جدید رسید!' : '${fresh.length} سفارش جدید رسید!',
              style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onPrimary),
            ),
          ),
        );
      }
      setState(() {
        _orders = orders;
        _knownPending = pending;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      // Keep last good data on transient errors; only surface if nothing yet.
      if (_orders == null) setState(() => _error = 'خطا در دریافت سفارش‌ها');
    }
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

  @override
  Widget build(BuildContext context) {
    final orders = _orders;
    if (orders == null) {
      return Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Text(_error!, style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.error)),
      );
    }
    // Active orders first (pending/accepted/preparing), then the rest.
    final active = orders.where((o) => _isActive(o.status)).toList();
    final done = orders.where((o) => !_isActive(o.status)).toList();
    final ordered = [...active, ...done];

    return RefreshIndicator(
      onRefresh: _load,
      child: ordered.isEmpty
          ? ListView(children: [
              const SizedBox(height: 140),
              const Icon(Icons.receipt_long, size: 56, color: GetirStyleDeliveryUiColors.outline),
              const SizedBox(height: 12),
              Text('سفارشی ندارید',
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
            ])
          : ListView(
              padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
              children: [for (final o in ordered) _VendorOrderCard(o, _setStatus)],
            ),
    );
  }

  bool _isActive(String s) => s == 'pending' || s == 'accepted' || s == 'preparing';
}

class _VendorOrderCard extends StatelessWidget {
  const _VendorOrderCard(this.order, this.onStatus);

  final OrderModel order;
  final void Function(OrderModel, String) onStatus;

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
        border: Border.all(
          color: s == 'pending' ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.outlineVariant,
          width: s == 'pending' ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('سفارش #${order.id.substring(0, 6)}',
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
          ]),
          const SizedBox(height: 8),
          for (final it in order.items)
            Text('• ${it.itemName} × ${it.quantity}',
                style: GetirStyleDeliveryUiTypography.bodySm(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(formatToman(order.totalAmount),
              style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.primary)),
          if (s == 'pending' || s == 'accepted') ...[
            const SizedBox(height: 10),
            Row(children: [
              if (s == 'pending')
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: GetirStyleDeliveryUiColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg))),
                    onPressed: () => onStatus(order, 'accepted'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('پذیرش سفارش'),
                  ),
                ),
              if (s == 'accepted')
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: GetirStyleDeliveryUiColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg))),
                    onPressed: () => onStatus(order, 'preparing'),
                    icon: const Icon(Icons.soup_kitchen, size: 18),
                    label: const Text('آماده شد / در حال آماده‌سازی'),
                  ),
                ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: GetirStyleDeliveryUiColors.error,
                    side: const BorderSide(color: GetirStyleDeliveryUiColors.error)),
                onPressed: () => onStatus(order, 'cancelled'),
                child: const Text('لغو'),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────── Menu (add/manage items) ───────────────────────────────

class _MenuTab extends StatefulWidget {
  const _MenuTab();

  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  List<MenuItem>? _items;
  List<CategoryModel> _categories = [];
  String? _error;
  bool _loading = true;

  String? get _vendorId => context.read<AuthProvider>().user?.vendorProfileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _vendorId;
    if (id == null || id.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'پروفایل فروشنده یافت نشد.';
      });
      return;
    }
    try {
      final results = await Future.wait([
        AppServices.instance.ops.getMyItems(id),
        AppServices.instance.ops.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _items = results[0] as List<MenuItem>;
        _categories = results[1] as List<CategoryModel>;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items == null) _error = 'خطا در دریافت منو';
      });
    }
  }

  Future<void> _toggleAvailability(MenuItem item, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.updateItem(item.id, isAvailable: value);
      await _load();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تغییر وضعیت ناموفق بود.')));
    }
  }

  Future<void> _editPrice(MenuItem item) async {
    final controller = TextEditingController(text: item.price.toString());
    final newPrice = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('قیمت ${item.name}', style: GetirStyleDeliveryUiTypography.headlineSm(_fa)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'تومان'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text.trim())),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    if (newPrice == null || newPrice <= 0 || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.ops.updateItem(item.id, price: newPrice);
      await _load();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تغییر قیمت ناموفق بود.')));
    }
  }

  Future<void> _addItem() async {
    final user = context.read<AuthProvider>().user;
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GetirStyleDeliveryUiRadius.xxl)),
      ),
      builder: (ctx) => _AddItemSheet(
        categories: _categories,
        defaultCategoryId: user?.vendorCategoryId,
        city: user?.vendorCity.isNotEmpty == true ? user!.vendorCity : (user?.city ?? ''),
      ),
    );
    if (created == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null && _items == null) {
      body = Center(
        child: Text(_error!, style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.error)),
      );
    } else {
      final items = _items ?? [];
      body = RefreshIndicator(
        onRefresh: _load,
        child: items.isEmpty
            ? ListView(children: [
                const SizedBox(height: 140),
                const Icon(Icons.restaurant_menu, size: 56, color: GetirStyleDeliveryUiColors.outline),
                const SizedBox(height: 12),
                Text('هنوز آیتمی اضافه نکرده‌اید',
                    textAlign: TextAlign.center,
                    style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
              ])
            : ListView(
                padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
                children: [
                  for (final it in items)
                    _MenuItemCard(it, _toggleAvailability, _editPrice),
                ],
              ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('افزودن آیتم'),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard(this.item, this.onToggle, this.onEditPrice);

  final MenuItem item;
  final void Function(MenuItem, bool) onToggle;
  final void Function(MenuItem) onEditPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: GetirStyleDeliveryUiTypography.labelLg(_fa, color: GetirStyleDeliveryUiColors.onSurface)),
                if (item.categorySlug.isNotEmpty)
                  Text(item.categorySlug,
                      style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => onEditPrice(item),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(formatToman(item.price),
                        style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.primary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 14, color: GetirStyleDeliveryUiColors.primary),
                  ]),
                ),
              ],
            ),
          ),
          Column(children: [
            Switch(
              value: item.isAvailable,
              activeTrackColor: GetirStyleDeliveryUiColors.primary,
              onChanged: (v) => onToggle(item, v),
            ),
            Text(item.isAvailable ? 'موجود' : 'ناموجود',
                style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
          ]),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({
    required this.categories,
    required this.defaultCategoryId,
    required this.city,
  });

  final List<CategoryModel> categories;
  final String? defaultCategoryId;
  final String city;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  String? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final cats = widget.categories;
    if (cats.any((c) => c.id == widget.defaultCategoryId)) {
      _categoryId = widget.defaultCategoryId;
    } else if (cats.isNotEmpty) {
      _categoryId = cats.first.id;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final price = int.tryParse(_price.text.trim()) ?? 0;
    final messenger = ScaffoldMessenger.of(context);
    if (name.isEmpty || price <= 0 || _categoryId == null) {
      messenger.showSnackBar(const SnackBar(content: Text('نام، قیمت و دسته‌بندی لازم است.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await AppServices.instance.ops.createItem(
        name: name,
        price: price,
        categoryId: _categoryId!,
        city: widget.city,
        description: _desc.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(content: Text('افزودن آیتم ناموفق بود.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('افزودن آیتم جدید',
              textAlign: TextAlign.center, style: GetirStyleDeliveryUiTypography.headlineSm(_fa)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'نام آیتم'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'قیمت', suffixText: 'تومان'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _categoryId,
            decoration: const InputDecoration(labelText: 'دسته‌بندی'),
            items: [
              for (final c in widget.categories)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GetirStyleDeliveryUiColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg)),
            ),
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('افزودن'),
          ),
        ],
      ),
    );
  }
}
