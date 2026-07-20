import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_services.dart';
import '../../core/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/category_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/vendor_model.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String? _apiLatency;
  String? _apiError;
  bool _apiOk = false;
  String? _killSwitch;
  String? _accessPreview;
  List<CategoryModel> _categories = [];
  List<VendorModel> _vendors = [];
  List<ItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() => _loading = true);
    await _pingApi();
    await _loadCatalog();
    await _loadKillSwitch();
    await _loadTokenPreview();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadTokenPreview() async {
    final token = await AppServices.instance.apiClient.accessToken;
    if (token == null || token.length < 12) {
      setState(() => _accessPreview = token ?? 'none');
      return;
    }
    setState(() => _accessPreview = '${token.substring(0, 8)}…${token.substring(token.length - 4)}');
  }

  Future<void> _pingApi() async {
    final sw = Stopwatch()..start();
    try {
      await AppServices.instance.catalog.getCategories();
      sw.stop();
      setState(() {
        _apiOk = true;
        _apiLatency = '${sw.elapsedMilliseconds} ms';
        _apiError = null;
      });
    } catch (e) {
      sw.stop();
      setState(() {
        _apiOk = false;
        _apiLatency = '${sw.elapsedMilliseconds} ms';
        _apiError = e.toString();
      });
    }
  }

  Future<void> _loadCatalog() async {
    try {
      final catalog = AppServices.instance.catalog;
      final cats = await catalog.getCategories();
      final vendors = await catalog.getVendors(city: AppConfig.defaultCity);
      final items = await catalog.getItems(city: AppConfig.defaultCity);
      setState(() {
        _categories = cats;
        _vendors = vendors;
        _items = items;
      });
    } catch (e) {
      setState(() => _apiError = e.toString());
    }
  }

  Future<void> _loadKillSwitch() async {
    try {
      const key = String.fromEnvironment(
        'DEVELOPER_SECRET_KEY',
        defaultValue: 'very-long-random-string-only-you-know',
      );
      final resp = await AppServices.instance.apiClient.dio.post(
        '/developer/kill-switch/status/',
        options: Options(headers: {'X-Developer-Key': key}),
      );
      setState(() => _killSwitch = jsonEncode(resp.data));
    } catch (e) {
      setState(() => _killSwitch = 'unavailable ($e)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devDebugTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refreshAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section('Environment', [
                  _row('API base', AppConfig.apiBaseUrl),
                  _row('Server', AppConfig.serverOrigin),
                  _row('Platform', defaultTargetPlatform.name),
                  _row('kDebugMode', '$kDebugMode'),
                  _row('City', AppConfig.defaultCity),
                ]),
                _section('API connection', [
                  _row('Status', _apiOk ? 'OK' : 'FAILED'),
                  _row('Latency', _apiLatency ?? '—'),
                  if (_apiError != null) _row('Error', _apiError!),
                  _row('Kill switch', _killSwitch ?? '—'),
                ]),
                _section('Auth', [
                  _row('User', user?.fullName ?? '—'),
                  _row('Phone', user?.phone ?? '—'),
                  _row('Role', user?.role ?? '—'),
                  _row('User ID', user?.id ?? '—'),
                  _row('Access token', _accessPreview ?? '—'),
                ]),
                _section('Catalog summary', [
                  _row('Categories', '${_categories.length}'),
                  _row('Vendors (Tehran)', '${_vendors.length}'),
                  _row('Items (Tehran)', '${_items.length}'),
                ]),
                _dataTable(
                  'Categories',
                  ['Name', 'Slug', 'Soon'],
                  _categories
                      .map((c) => [c.name, c.slug, '${c.isComingSoon}'])
                      .toList(),
                  locale,
                ),
                _dataTable(
                  'Vendors',
                  ['Business', 'City', 'Rating'],
                  _vendors
                      .map((v) => [
                            v.businessName,
                            v.city,
                            v.rating.toStringAsFixed(1),
                          ])
                      .toList(),
                  locale,
                ),
                _dataTable(
                  'Items (first 30)',
                  ['Name', 'Vendor', 'Price'],
                  _items
                      .take(30)
                      .map((i) => [
                            i.name,
                            i.vendorName,
                            formatToman(i.price),
                          ])
                      .toList(),
                  locale,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.devClearSession),
                ),
              ],
            ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: SelectableText(
              value,
              onTap: () => Clipboard.setData(ClipboardData(text: value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataTable(
    String title,
    List<String> headers,
    List<List<String>> rows,
    Locale locale,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${rows.length})',
              style: GetirStyleDeliveryUiTypography.labelLg(locale),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
                rows: rows
                    .map(
                      (cells) => DataRow(
                        cells: cells
                            .map((c) => DataCell(Text(c, maxLines: 2)))
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
