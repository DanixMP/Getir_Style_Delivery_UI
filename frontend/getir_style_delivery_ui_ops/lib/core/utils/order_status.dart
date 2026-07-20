import 'package:flutter/material.dart';

import '../theme/getir_style_delivery_ui_colors.dart';

const orderStatusFa = {
  'pending': 'در انتظار',
  'accepted': 'تأیید شده',
  'preparing': 'در حال آماده‌سازی',
  'picked_up': 'در حال ارسال',
  'delivered': 'تحویل شده',
  'cancelled': 'لغو شده',
};

Color orderStatusColor(String status) {
  switch (status) {
    case 'delivered':
      return GetirStyleDeliveryUiColors.success;
    case 'cancelled':
      return GetirStyleDeliveryUiColors.error;
    case 'picked_up':
      return GetirStyleDeliveryUiColors.tertiaryContainer;
    default:
      return GetirStyleDeliveryUiColors.primary;
  }
}
