import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../assets/app_assets.dart';

class GroceryCategory {
  const GroceryCategory({
    required this.label,
    required this.icon,
    this.imagePath = AppAssets.categoryDefault,
  });

  final String Function(AppLocalizations l10n) label;
  final IconData icon;
  final String imagePath;
}

List<GroceryCategory> groceryCategories(AppLocalizations l10n) => [
      GroceryCategory(
        label: (_) => l10n.catBeverages,
        icon: Icons.local_drink_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catSnacks,
        icon: Icons.cookie_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catMilkDairy,
        icon: Icons.egg_alt_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catFruitsVeggies,
        icon: Icons.eco_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catBreakfast,
        icon: Icons.free_breakfast_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catBakedGoods,
        icon: Icons.bakery_dining_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catIceCream,
        icon: Icons.icecream_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catFood,
        icon: Icons.ramen_dining_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catReadyToEat,
        icon: Icons.lunch_dining_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catMeatPoultry,
        icon: Icons.set_meal_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catFitAndForm,
        icon: Icons.fitness_center_outlined,
      ),
      GroceryCategory(
        label: (_) => l10n.catHomeCare,
        icon: Icons.cleaning_services_outlined,
      ),
    ];
