import 'package:flutter/material.dart';

import '../../core/localization/l10n_helpers.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/order_model.dart';
import '../../l10n/app_localizations.dart';

Color _statusColor(String status) {
  switch (status) {
    case 'delivered':
      return GetirStyleDeliveryUiColors.success;
    case 'cancelled':
      return GetirStyleDeliveryUiColors.error;
    default:
      return GetirStyleDeliveryUiColors.primary;
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.instance.orders.getOrders();
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
        title: Text(
          l10n.ordersTitle,
          style: GetirStyleDeliveryUiTypography.headlineMd(locale, color: GetirStyleDeliveryUiColors.onPrimary),
        ),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: GetirStyleDeliveryUiColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long,
                        size: 44, color: GetirStyleDeliveryUiColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noOrdersYet,
                    style: GetirStyleDeliveryUiTypography.bodyMd(
                      locale,
                      color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _OrderCard(
              order: orders[index],
              l10n: l10n,
              locale: locale,
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.l10n,
    required this.locale,
  });

  final OrderModel order;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final date = order.createdAt;
    return Container(
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
                  order.vendorName.isEmpty ? l10n.orderFallback : order.vendorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                ),
                child: Text(
                  orderStatusLabel(l10n, order.status),
                  style: GetirStyleDeliveryUiTypography.labelSm(locale, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.id.substring(0, 6)}'
                  '${date != null ? ' · ${date.year}/${date.month}/${date.day}' : ''}',
                  style: GetirStyleDeliveryUiTypography.bodySm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                  ),
                ),
              ),
              Text(
                formatToman(order.totalAmount),
                style: GetirStyleDeliveryUiTypography.labelLg(
                  locale,
                  color: GetirStyleDeliveryUiColors.primary,
                ),
              ),
            ],
          ),
          if (order.deliveryCode.isNotEmpty &&
              order.status != 'delivered' &&
              order.status != 'cancelled') ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user,
                      size: 16, color: GetirStyleDeliveryUiColors.primary),
                  const SizedBox(width: 8),
                  Text(l10n.deliveryCodeLabel,
                      style: GetirStyleDeliveryUiTypography.labelMd(
                          locale, color: GetirStyleDeliveryUiColors.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  Text(
                    order.deliveryCode,
                    textDirection: TextDirection.ltr,
                    style: GetirStyleDeliveryUiTypography.labelLg(locale, color: GetirStyleDeliveryUiColors.primary)
                        .copyWith(fontWeight: FontWeight.w900, letterSpacing: 3),
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
