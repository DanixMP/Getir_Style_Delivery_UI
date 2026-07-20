import '../models/getir_style_delivery_ui_service.dart';

/// Maps UI service tiles to backend catalog category slugs (API.md §5.3).
String? categorySlugForService(GetirStyleDeliveryUiServiceId id) => switch (id) {
      GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi => 'getir_style_delivery_ui-groceries',
      GetirStyleDeliveryUiServiceId.food => 'getir_style_delivery_ui-food',
      GetirStyleDeliveryUiServiceId.restaurant => 'getir_style_delivery_ui-restaurant',
      GetirStyleDeliveryUiServiceId.water => 'getir_style_delivery_ui-drink',
      GetirStyleDeliveryUiServiceId.more => 'getir_style_delivery_ui-dessert',
      GetirStyleDeliveryUiServiceId.locals => 'getir_style_delivery_ui-medic',
      GetirStyleDeliveryUiServiceId.taxi => 'getir_style_delivery_ui-taxi',
      GetirStyleDeliveryUiServiceId.finans => null,
    };

GetirStyleDeliveryUiServiceId serviceForCategorySlug(String slug) => switch (slug) {
      'getir_style_delivery_ui-groceries' => GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi,
      'getir_style_delivery_ui-food' => GetirStyleDeliveryUiServiceId.food,
      'getir_style_delivery_ui-restaurant' => GetirStyleDeliveryUiServiceId.restaurant,
      'getir_style_delivery_ui-drink' => GetirStyleDeliveryUiServiceId.water,
      'getir_style_delivery_ui-dessert' => GetirStyleDeliveryUiServiceId.more,
      'getir_style_delivery_ui-medic' => GetirStyleDeliveryUiServiceId.locals,
      'getir_style_delivery_ui-taxi' => GetirStyleDeliveryUiServiceId.taxi,
      _ => GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi,
    };
