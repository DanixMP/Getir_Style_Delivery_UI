import 'package:flutter/material.dart';

import '../assets/app_assets.dart';
import '../../l10n/app_localizations.dart';

enum GetirStyleDeliveryUiServiceId {
  getirStyleDeliveryUi,
  finans,
  more,
  food,
  restaurant,
  locals,
  water,
  taxi,
}

enum GetirStyleDeliveryUiServiceLayout { large, medium, compact }

class GetirStyleDeliveryUiService {
  const GetirStyleDeliveryUiService({
    required this.id,
    required this.imagePath,
    required this.layout,
    this.hasDescription = false,
    this.hasHint = false,
  });

  final GetirStyleDeliveryUiServiceId id;
  final String imagePath;
  final GetirStyleDeliveryUiServiceLayout layout;
  final bool hasDescription;
  final bool hasHint;

  String title(AppLocalizations l10n) => switch (id) {
        GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi => l10n.serviceGetirStyleDeliveryUi,
        GetirStyleDeliveryUiServiceId.finans => l10n.serviceFinans,
        GetirStyleDeliveryUiServiceId.more => l10n.serviceMore,
        GetirStyleDeliveryUiServiceId.food => l10n.serviceFood,
        GetirStyleDeliveryUiServiceId.restaurant => l10n.serviceRestaurant,
        GetirStyleDeliveryUiServiceId.locals => l10n.serviceLocals,
        GetirStyleDeliveryUiServiceId.water => l10n.serviceWater,
        GetirStyleDeliveryUiServiceId.taxi => l10n.serviceTaxi,
      };

  /// Brand label — uppercase Latin scripts to match the GETIR_STYLE_DELIVERY_UI app bar.
  String displayTitle(AppLocalizations l10n, Locale locale) {
    final raw = title(l10n);
    return switch (locale.languageCode) {
      'fa' || 'ar' => raw,
      _ => raw.toUpperCase(),
    };
  }

  String? subtitle(AppLocalizations l10n) => switch (id) {
        GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi => l10n.serviceGetirStyleDeliveryUiDesc,
        GetirStyleDeliveryUiServiceId.more => l10n.serviceMoreDesc,
        GetirStyleDeliveryUiServiceId.restaurant => l10n.dineInSubtitle,
        _ => null,
      };

  String? hint(AppLocalizations l10n) => switch (id) {
        GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi => l10n.serviceGetirStyleDeliveryUiHint,
        GetirStyleDeliveryUiServiceId.more => l10n.serviceMoreHint,
        _ => null,
      };
}

const getirStyleDeliveryUiServices = [
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.getirStyleDeliveryUi,
    imagePath: AppAssets.groceryBag,
    layout: GetirStyleDeliveryUiServiceLayout.large,
    hasDescription: true,
    hasHint: true,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.finans,
    imagePath: AppAssets.goldBars,
    layout: GetirStyleDeliveryUiServiceLayout.large,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.more,
    imagePath: AppAssets.supermarket,
    layout: GetirStyleDeliveryUiServiceLayout.large,
    hasDescription: true,
    hasHint: true,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.food,
    imagePath: AppAssets.burger,
    layout: GetirStyleDeliveryUiServiceLayout.compact,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.restaurant,
    imagePath: AppAssets.burger,
    layout: GetirStyleDeliveryUiServiceLayout.compact,
    hasDescription: true,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.locals,
    imagePath: AppAssets.locals,
    layout: GetirStyleDeliveryUiServiceLayout.compact,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.water,
    imagePath: AppAssets.water,
    layout: GetirStyleDeliveryUiServiceLayout.medium,
  ),
  GetirStyleDeliveryUiService(
    id: GetirStyleDeliveryUiServiceId.taxi,
    imagePath: AppAssets.taxi,
    layout: GetirStyleDeliveryUiServiceLayout.medium,
  ),
];

GetirStyleDeliveryUiService? getirStyleDeliveryUiServiceById(GetirStyleDeliveryUiServiceId id) {
  for (final service in getirStyleDeliveryUiServices) {
    if (service.id == id) return service;
  }
  return null;
}
