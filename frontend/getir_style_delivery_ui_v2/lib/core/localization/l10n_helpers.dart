import '../../l10n/app_localizations.dart';

/// Localized labels for API order status codes.
String orderStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'pending':
      return l10n.orderStatusPending;
    case 'accepted':
      return l10n.orderStatusAccepted;
    case 'preparing':
      return l10n.orderStatusPreparing;
    case 'picked_up':
      return l10n.orderStatusPickedUp;
    case 'delivered':
      return l10n.orderStatusDelivered;
    case 'cancelled':
      return l10n.orderStatusCancelled;
    default:
      return status;
  }
}

/// Localized labels for wallet transaction types.
String txnTypeLabel(AppLocalizations l10n, String txnType) {
  switch (txnType) {
    case 'topup':
      return l10n.txnTypeTopup;
    case 'order_payment':
      return l10n.txnTypeOrderPayment;
    case 'refund':
      return l10n.txnTypeRefund;
    case 'adjustment':
      return l10n.txnTypeAdjustment;
    default:
      return l10n.txnGeneric;
  }
}
