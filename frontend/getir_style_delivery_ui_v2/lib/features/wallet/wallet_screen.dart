import 'package:flutter/material.dart';

import '../../core/localization/l10n_helpers.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_radius.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/discount_model.dart';
import '../../data/models/wallet_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/profile_menu_button.dart';

enum _TxnFilter { all, credit, debit }

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<List<DiscountModel>> _discountsFuture;
  late Future<WalletModel> _walletFuture;
  late Future<List<WalletTransactionModel>> _transactionsFuture;
  _TxnFilter _filter = _TxnFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _walletFuture = AppServices.instance.wallet.getWallet();
    _transactionsFuture = AppServices.instance.wallet.getTransactions();
    _discountsFuture = AppServices.instance.ai.getDiscounts();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_walletFuture, _transactionsFuture, _discountsFuture]);
  }

  Future<void> _promptTopUp() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    const presets = [50000, 100000, 200000, 500000];
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GetirStyleDeliveryUiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        ),
        title: Text(l10n.addMoney),
        content: StatefulBuilder(
          builder: (ctx, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.topUp,
                  suffixText: l10n.currencyToman,
                  filled: true,
                  fillColor: GetirStyleDeliveryUiColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in presets)
                    ActionChip(
                      label: Text(formatToman(p)),
                      backgroundColor: GetirStyleDeliveryUiColors.primaryFixed,
                      labelStyle: const TextStyle(color: GetirStyleDeliveryUiColors.onPrimaryFixed),
                      onPressed: () => setLocal(() => controller.text = '$p'),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GetirStyleDeliveryUiColors.primary),
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text.trim())),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (amount == null || amount < 1000) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await AppServices.instance.wallet.initiateTopUp(amount);
      messenger.showSnackBar(SnackBar(content: Text(l10n.paymentLink(url))));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.topUpFailed)),
      );
    }
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
        centerTitle: true,
        leading: const ProfileMenuButton(color: GetirStyleDeliveryUiColors.onPrimary),
        title: Text(
          l10n.navWallet,
          style: GetirStyleDeliveryUiTypography.headlineMd(locale, color: GetirStyleDeliveryUiColors.onPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
          children: [
            FutureBuilder<WalletModel>(
              future: _walletFuture,
              builder: (context, snapshot) => _BalanceCard(
                l10n: l10n,
                locale: locale,
                wallet: snapshot.data,
                onAddMoney: _promptTopUp,
              ),
            ),
            const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
            FutureBuilder<List<DiscountModel>>(
              future: _discountsFuture,
              builder: (context, snapshot) {
                final discounts = snapshot.data ?? [];
                if (discounts.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.couponsAndOffers,
                      style: GetirStyleDeliveryUiTypography.labelMd(
                        locale,
                        color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: discounts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            _CouponCard(discount: discounts[index], locale: locale),
                      ),
                    ),
                    const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                  ],
                );
              },
            ),
            FutureBuilder<List<WalletTransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final txns = snapshot.data ?? [];
                final stats = _WalletStats.from(txns);
                final filtered = txns.where((t) {
                  switch (_filter) {
                    case _TxnFilter.all:
                      return true;
                    case _TxnFilter.credit:
                      return t.isCredit;
                    case _TxnFilter.debit:
                      return !t.isCredit;
                  }
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly in/out summary.
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.south_west,
                            color: GetirStyleDeliveryUiColors.success,
                            label: l10n.receivedThisMonth,
                            value: formatToman(stats.monthCredit),
                            locale: locale,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.north_east,
                            color: GetirStyleDeliveryUiColors.error,
                            label: l10n.paidThisMonth,
                            value: formatToman(stats.monthDebit),
                            locale: locale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoStrip(l10n: l10n, stats: stats, locale: locale),
                    const SizedBox(height: GetirStyleDeliveryUiSpacing.stackLg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.recentTransactions,
                            style: GetirStyleDeliveryUiTypography.labelMd(
                              locale,
                              color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (txns.isNotEmpty)
                          Text(
                            l10n.txnCount(txns.length),
                            style: GetirStyleDeliveryUiTypography.labelSm(
                              locale,
                              color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
                    if (txns.isNotEmpty) ...[
                      _FilterChips(
                        l10n: l10n,
                        filter: _filter,
                        locale: locale,
                        onChanged: (f) => setState(() => _filter = f),
                      ),
                      const SizedBox(height: GetirStyleDeliveryUiSpacing.stackSm),
                    ],
                    if (filtered.isEmpty)
                      _EmptyTransactions(l10n: l10n, locale: locale)
                    else
                      for (final t in filtered)
                        _TransactionTile(l10n: l10n, txn: t, locale: locale),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Aggregates real transaction data into the figures shown on the page.
class _WalletStats {
  _WalletStats({
    required this.monthCredit,
    required this.monthDebit,
    required this.totalCredit,
    required this.totalDebit,
    required this.count,
    required this.lastTopUp,
  });

  final int monthCredit;
  final int monthDebit;
  final int totalCredit;
  final int totalDebit;
  final int count;
  final DateTime? lastTopUp;

  factory _WalletStats.from(List<WalletTransactionModel> txns) {
    final now = DateTime.now();
    var mc = 0, md = 0, tc = 0, td = 0;
    DateTime? lastTopUp;
    for (final t in txns) {
      if (t.isCredit) {
        tc += t.amount;
      } else {
        td += t.amount;
      }
      final d = t.createdAt;
      if (d != null && d.year == now.year && d.month == now.month) {
        if (t.isCredit) {
          mc += t.amount;
        } else {
          md += t.amount;
        }
      }
      if (t.txnType == 'topup' && lastTopUp == null && d != null) {
        lastTopUp = d; // list is newest-first
      }
    }
    return _WalletStats(
      monthCredit: mc,
      monthDebit: md,
      totalCredit: tc,
      totalDebit: td,
      count: txns.length,
      lastTopUp: lastTopUp,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.l10n,
    required this.locale,
    required this.onAddMoney,
    this.wallet,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onAddMoney;
  final WalletModel? wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GetirStyleDeliveryUiColors.primary, GetirStyleDeliveryUiColors.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.9), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.availableBalance,
                style: GetirStyleDeliveryUiTypography.bodyMd(
                  locale,
                  color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              if (wallet != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
                  ),
                  child: Text(
                    wallet!.isActive ? l10n.active : l10n.inactive,
                    style: GetirStyleDeliveryUiTypography.labelSm(
                      locale,
                      color: GetirStyleDeliveryUiColors.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            wallet == null ? '—' : formatToman(wallet!.balance),
            style: GetirStyleDeliveryUiTypography.headlineLg(
              locale,
              color: GetirStyleDeliveryUiColors.secondaryContainer,
            ).copyWith(fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAddMoney,
              icon: const Icon(Icons.add),
              label: Text(l10n.addMoney),
              style: FilledButton.styleFrom(
                backgroundColor: GetirStyleDeliveryUiColors.secondaryContainer,
                foregroundColor: GetirStyleDeliveryUiColors.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.locale,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GetirStyleDeliveryUiTypography.labelSm(
                    locale,
                    color: GetirStyleDeliveryUiColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GetirStyleDeliveryUiTypography.labelLg(locale, color: GetirStyleDeliveryUiColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.l10n, required this.stats, required this.locale});

  final AppLocalizations l10n;
  final _WalletStats stats;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final last = stats.lastTopUp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
      ),
      child: Row(
        children: [
          _InfoCell(
            label: l10n.totalTopUp,
            value: formatToman(stats.totalCredit),
            locale: locale,
          ),
          _divider(),
          _InfoCell(
            label: l10n.lastTopUp,
            value: last == null
                ? '—'
                : '${last.year}/${last.month}/${last.day}',
            locale: locale,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: GetirStyleDeliveryUiColors.onPrimaryFixed.withValues(alpha: 0.12),
      );
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value, required this.locale});

  final String label;
  final String value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GetirStyleDeliveryUiTypography.labelSm(
              locale,
              color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GetirStyleDeliveryUiTypography.labelMd(
              locale,
              color: GetirStyleDeliveryUiColors.onPrimaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.l10n,
    required this.filter,
    required this.locale,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final _TxnFilter filter;
  final Locale locale;
  final ValueChanged<_TxnFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(l10n.filterAll, _TxnFilter.all),
        const SizedBox(width: 8),
        _chip(l10n.filterCredit, _TxnFilter.credit),
        const SizedBox(width: 8),
        _chip(l10n.filterDebit, _TxnFilter.debit),
      ],
    );
  }

  Widget _chip(String label, _TxnFilter value) {
    final selected = filter == value;
    return _ChipButton(label: label, selected: selected, onTap: () => onChanged(value), locale: locale);
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.locale,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? GetirStyleDeliveryUiColors.primary : GetirStyleDeliveryUiColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: GetirStyleDeliveryUiTypography.labelMd(
              locale,
              color: selected ? GetirStyleDeliveryUiColors.onPrimary : GetirStyleDeliveryUiColors.onPrimaryFixed,
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.discount, required this.locale});

  final DiscountModel discount;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: GetirStyleDeliveryUiColors.secondaryContainer,
              borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
            ),
            child: Text(
              '${discount.discountPercent}%',
              style: GetirStyleDeliveryUiTypography.labelMd(
                locale,
                color: GetirStyleDeliveryUiColors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            discount.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GetirStyleDeliveryUiTypography.bodyMd(
              locale,
              color: GetirStyleDeliveryUiColors.onPrimaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
        border: Border.all(color: GetirStyleDeliveryUiColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 36, color: GetirStyleDeliveryUiColors.outline),
          const SizedBox(height: 8),
          Text(
            l10n.noTransactions,
            style: GetirStyleDeliveryUiTypography.bodyMd(
              locale,
              color: GetirStyleDeliveryUiColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.l10n, required this.txn, required this.locale});

  final AppLocalizations l10n;
  final WalletTransactionModel txn;
  final Locale locale;

  static const _icons = {
    'topup': Icons.add_circle_outline,
    'order_payment': Icons.shopping_bag_outlined,
    'refund': Icons.replay,
    'adjustment': Icons.tune,
  };

  @override
  Widget build(BuildContext context) {
    final date = txn.createdAt;
    final color = txn.isCredit ? GetirStyleDeliveryUiColors.success : GetirStyleDeliveryUiColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.primaryFixed,
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_icons[txn.txnType] ?? Icons.swap_horiz,
                size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txnTypeLabel(l10n, txn.txnType),
                  style: GetirStyleDeliveryUiTypography.labelLg(
                    locale,
                    color: GetirStyleDeliveryUiColors.onPrimaryFixed,
                  ),
                ),
                Row(
                  children: [
                    if (date != null)
                      Text(
                        '${date.year}/${date.month}/${date.day}',
                        style: GetirStyleDeliveryUiTypography.bodySm(
                          locale,
                          color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                        ),
                      ),
                    if (date != null) const SizedBox(width: 8),
                    Text(
                      l10n.balanceAfter(formatToman(txn.balanceAfter)),
                      style: GetirStyleDeliveryUiTypography.bodySm(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${txn.isCredit ? '+' : '-'}${formatToman(txn.amount)}',
            style: GetirStyleDeliveryUiTypography.labelLg(locale, color: color),
          ),
        ],
      ),
    );
  }
}
