import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/item_model.dart';
import '../../l10n/app_localizations.dart';
import 'cart_provider.dart';

/// Adds [item] to the cart and gives user feedback. Shared by every screen
/// that lists foods so the single-vendor rule is enforced consistently.
///
/// Returns the [AddToCartResult] so callers (e.g. the detail page) can react —
/// a `vendorMismatch` means nothing was added (a replace dialog was shown).
AddToCartResult addItemToCart(
  BuildContext context,
  ItemModel item, {
  int quantity = 1,
  bool showSnack = true,
}) {
  final cart = context.read<CartProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final result = cart.add(item, quantity: quantity);

  switch (result) {
    case AddToCartResult.vendorMismatch:
      showDialog<void>(
        context: context,
        builder: (ctx) {
          final dialogL10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(dialogL10n.vendorMismatchTitle),
            content: Text(dialogL10n.vendorMismatchBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(dialogL10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  cart.replaceWith(item, quantity: quantity);
                  Navigator.pop(ctx);
                },
                child: Text(dialogL10n.newCart),
              ),
            ],
          );
        },
      );
    case AddToCartResult.added:
    case AddToCartResult.increased:
      if (showSnack) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.addedToCart(item.name)),
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
  }
  return result;
}
