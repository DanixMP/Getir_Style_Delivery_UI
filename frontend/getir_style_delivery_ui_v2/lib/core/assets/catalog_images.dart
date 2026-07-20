import 'package:flutter/material.dart';

/// Catalog image helpers — only real uploaded URLs are used (no demo stock photos).
abstract final class CatalogImages {
  /// Prefer the item's uploaded image; otherwise empty (UI shows icon fallback).
  static String forItem({
    String? existingUrl,
    String? name,
    String? categorySlug,
  }) {
    if (existingUrl != null && existingUrl.isNotEmpty) return existingUrl;
    return '';
  }

  /// No stock category photos — callers should use [iconForCategory] as fallback.
  static String forCategory(String slug) => '';

  static IconData iconForCategory(String slug) => switch (slug) {
        'getir_style_delivery_ui-food' => Icons.restaurant,
        'getir_style_delivery_ui-restaurant' => Icons.view_in_ar_outlined,
        'getir_style_delivery_ui-drink' => Icons.local_cafe,
        'getir_style_delivery_ui-dessert' => Icons.cake_outlined,
        'getir_style_delivery_ui-medic' => Icons.medical_services_outlined,
        'getir_style_delivery_ui-groceries' => Icons.shopping_basket_outlined,
        'getir_style_delivery_ui-taxi' => Icons.local_taxi,
        _ => Icons.category_outlined,
      };
}
