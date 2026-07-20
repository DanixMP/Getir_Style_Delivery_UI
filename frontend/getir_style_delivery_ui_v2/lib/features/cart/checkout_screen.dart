import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/app_services.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/dine_in_session_provider.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/wallet_model.dart';
import '../../l10n/app_localizations.dart';
import 'cart_provider.dart';

/// Payment options surfaced at checkout.
enum PayMethod { wallet, online, atHome }

extension on PayMethod {
  /// Maps to the backend Order.payment_method value.
  String get apiValue => switch (this) {
        PayMethod.wallet => 'wallet',
        PayMethod.online => 'online',
        PayMethod.atHome => 'cash',
      };
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  final _notesController = TextEditingController();

  PayMethod _method = PayMethod.wallet;
  bool _submitting = false;
  WalletModel? _wallet;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    final selectedAddress = context.read<AddressProvider>().selected;
    _addressController =
        TextEditingController(text: selectedAddress?.details ?? '');
    _cityController = TextEditingController(
      text: selectedAddress?.city.isNotEmpty == true
          ? selectedAddress!.city
          : (user?.city.isNotEmpty ?? false)
              ? user!.city
              : AppConfig.defaultCity,
    );
    _loadWallet();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await AppServices.instance.wallet.getWallet();
      if (mounted) setState(() => _wallet = wallet);
    } catch (_) {/* balance is informational only */}
  }

  Future<void> _placeOrder() async {
    final l10n = AppLocalizations.of(context);
    final cart = context.read<CartProvider>();
    final dineIn = context.read<DineInSessionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final isDineIn = cart.isDineIn && cart.tableId != null;

    if (cart.isEmpty || cart.vendorId == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.cartEmptyError)));
      return;
    }
    if (!isDineIn && _addressController.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.enterDeliveryAddress)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final services = AppServices.instance;
      final tableLabel = cart.tableLabel ?? dineIn.selectedTable?.label ?? '';
      final order = await services.orders.createOrder(
        vendorId: cart.vendorId!,
        items: cart.toOrderLines(),
        deliveryType: 'in_city',
        paymentMethod: _method.apiValue,
        deliveryAddress: isDineIn ? tableLabel : _addressController.text.trim(),
        deliveryCity: isDineIn
            ? ''
            : _cityController.text.trim(),
        customerNotes: _notesController.text.trim(),
        fulfillmentType: isDineIn ? 'dine_in' : null,
        diningTableId: isDineIn ? cart.tableId : null,
      );

      String message;
      switch (_method) {
        case PayMethod.wallet:
          await services.wallet.payOrder(order.id);
          message = l10n.orderPlacedWallet;
        case PayMethod.online:
          final url = await services.payments.initiate(order.id);
          message = l10n.orderPlacedOnline(url);
        case PayMethod.atHome:
          message = l10n.orderPlacedCash;
      }

      cart.clear();
      dineIn.clear();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message)));
      navigator.popUntil((route) => route.isFirst);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? (e.response!.data['detail']?.toString() ?? l10n.orderPlaceError)
          : l10n.orderPlaceError;
      messenger.showSnackBar(SnackBar(content: Text(detail)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderPlaceError)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final cart = context.watch<CartProvider>();
    final dineIn = context.watch<DineInSessionProvider>();
    final isDineIn = cart.isDineIn && cart.tableId != null;
    final tableLabel = cart.tableLabel ?? dineIn.selectedTable?.label ?? '';
    final restaurantName = (dineIn.vendorName?.isNotEmpty ?? false)
        ? dineIn.vendorName!
        : cart.vendorName;

    return Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.background,
      appBar: AppBar(
        backgroundColor: GetirStyleDeliveryUiColors.primary,
        foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
        title: Text(
          l10n.checkoutTitle,
          style: GetirStyleDeliveryUiTypography.headlineMd(locale, color: GetirStyleDeliveryUiColors.onPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
        children: [
          if (isDineIn)
            _SoftBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(text: l10n.dineInFulfillment, locale: locale),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.table_restaurant,
                        color: GetirStyleDeliveryUiColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.dineInTableSummary(tableLabel, restaurantName),
                          style: GetirStyleDeliveryUiTypography.bodyMd(
                            locale,
                            color: GetirStyleDeliveryUiColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Field(
                    controller: _notesController,
                    hint: l10n.noteOptional,
                  ),
                ],
              ),
            )
          else
            _SoftBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(text: l10n.deliveryAddress, locale: locale),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _addressController,
                    hint: l10n.fullAddressHint,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  _Field(controller: _cityController, hint: l10n.city),
                  const SizedBox(height: 10),
                  _Field(
                    controller: _notesController,
                    hint: l10n.noteOptional,
                  ),
                ],
              ),
            ),
          const SizedBox(height: GetirStyleDeliveryUiSpacing.stackMd),
          _SoftBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(text: l10n.paymentMethod, locale: locale),
                const SizedBox(height: 12),
                _PayOption(
                  method: PayMethod.wallet,
                  groupValue: _method,
                  icon: Icons.account_balance_wallet,
                  title: l10n.walletPay,
                  subtitle: _wallet == null
                      ? l10n.walletBalanceLoading
                      : l10n.walletBalanceLabel(formatToman(_wallet!.balance)),
                  onChanged: (v) => setState(() => _method = v),
                  locale: locale,
                ),
                _PayOption(
                  method: PayMethod.online,
                  groupValue: _method,
                  icon: Icons.credit_card,
                  title: l10n.onlinePay,
                  subtitle: l10n.zarinpalGateway,
                  onChanged: (v) => setState(() => _method = v),
                  locale: locale,
                ),
                _PayOption(
                  method: PayMethod.atHome,
                  groupValue: _method,
                  icon: Icons.home_outlined,
                  title: l10n.payAtDoor,
                  subtitle: l10n.payAtDoorSubtitle,
                  onChanged: (v) => setState(() => _method = v),
                  locale: locale,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
        decoration: BoxDecoration(
          color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(GetirStyleDeliveryUiRadius.xxl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.primaryFixed,
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.payableAmount,
                        style: GetirStyleDeliveryUiTypography.bodySm(
                          locale,
                          color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                        ),
                      ),
                      Text(
                        formatToman(cart.subtotal),
                        style: GetirStyleDeliveryUiTypography.headlineSm(
                          locale,
                          color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: GetirStyleDeliveryUiColors.primary,
                  foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                  ),
                ),
                onPressed: _submitting ? null : _placeOrder,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: GetirStyleDeliveryUiColors.onPrimary,
                        ),
                      )
                    : Text(
                        l10n.placeOrder,
                        style: GetirStyleDeliveryUiTypography.labelLg(
                          locale,
                          color: GetirStyleDeliveryUiColors.onPrimary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft purple rounded panel that groups a checkout section.
class _SoftBox extends StatelessWidget {
  const _SoftBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: child,
    );
  }
}

/// White filled input used inside the soft purple boxes.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
          borderSide: const BorderSide(color: GetirStyleDeliveryUiColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GetirStyleDeliveryUiTypography.labelLg(locale, color: GetirStyleDeliveryUiColors.onPrimaryFixed),
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.method,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    required this.locale,
  });

  final PayMethod method;
  final PayMethod groupValue;
  final IconData icon;
  final String title;
  final String subtitle;
  final ValueChanged<PayMethod> onChanged;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final selected = method == groupValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(method),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
              border: Border.all(
                color: selected ? GetirStyleDeliveryUiColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected
                        ? GetirStyleDeliveryUiColors.primary
                        : GetirStyleDeliveryUiColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? GetirStyleDeliveryUiColors.onPrimary
                        : GetirStyleDeliveryUiColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
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
                      Text(
                        subtitle,
                        style: GetirStyleDeliveryUiTypography.bodySm(
                          locale,
                          color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
