import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_services.dart';
import '../../core/providers/dine_in_session_provider.dart';
import '../../data/models/dine_in_venue_model.dart';
import '../../data/models/dining_table_model.dart';
import '../../features/cart/cart_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/panorama_table_view.dart';
import 'restaurant_menu_screen.dart';

class PanoramaTablePickerScreen extends StatefulWidget {
  const PanoramaTablePickerScreen({super.key, required this.venue});

  final DineInVenueModel venue;

  @override
  State<PanoramaTablePickerScreen> createState() =>
      _PanoramaTablePickerScreenState();
}

class _PanoramaTablePickerScreenState extends State<PanoramaTablePickerScreen> {
  DiningTableModel? _selected;
  bool _holding = false;

  void _onTableTap(DiningTableModel table) {
    final l10n = AppLocalizations.of(context);
    if (!table.isSelectable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tableOccupied)),
      );
      return;
    }
    setState(() => _selected = table);
  }

  Future<void> _confirm() async {
    final table = _selected;
    if (table == null || _holding) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _holding = true);
    try {
      await AppServices.instance.dineIn.holdTable(
        vendorId: widget.venue.vendor.id,
        tableId: table.id,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409 || status == 404) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.tableOccupied)));
        setState(() => _holding = false);
        return;
      }
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.tableHoldFailed)));
      setState(() => _holding = false);
      return;
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.tableHoldFailed)));
      setState(() => _holding = false);
      return;
    }

    if (!mounted) return;

    context.read<DineInSessionProvider>().selectTable(table);
    context.read<CartProvider>().setDineInContext(
          tableId: table.id,
          tableLabel: table.label,
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RestaurantMenuScreen(
          vendorId: widget.venue.vendor.id,
          vendorName: widget.venue.vendor.businessName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final panorama = widget.venue.panorama;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.selectYourTable),
      ),
      body: PanoramaTableView(
        imageUrl: panorama?.imageUrl ?? '',
        initialYaw: panorama?.initialYaw ?? 0,
        tables: widget.venue.tables,
        selectedTable: _selected,
        onTableSelected: _onTableTap,
        onConfirm: _confirm,
        loading: _holding,
      ),
    );
  }
}
