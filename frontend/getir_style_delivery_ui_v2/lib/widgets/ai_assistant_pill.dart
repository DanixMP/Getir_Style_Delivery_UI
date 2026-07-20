import 'package:flutter/material.dart';

import '../core/theme/pages/navigation_theme.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../l10n/app_localizations.dart';

/// Compact floating AI pill above the bottom nav.
class AiAssistantPill extends StatelessWidget {
  const AiAssistantPill({
    super.key,
    required this.locale,
    this.onTap,
    this.compact = false,
  });

  final Locale locale;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      color: NavigationTheme.barBackground,
      borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 10 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.smart_toy_outlined,
                color: NavigationTheme.activeIcon,
                size: compact ? 20 : 22,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.aiAssistant,
                style: GetirStyleDeliveryUiTypography.labelMd(
                  locale,
                  color: NavigationTheme.activeIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Morphing shell used while the pill travels toward the profile banner.
class AiAssistantMergeShell extends StatelessWidget {
  const AiAssistantMergeShell({
    super.key,
    required this.locale,
    required this.progress,
    required this.child,
  });

  final Locale locale;
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = GetirStyleDeliveryUiRadius.full +
        (GetirStyleDeliveryUiRadius.xxl - GetirStyleDeliveryUiRadius.full) * progress;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: GetirStyleDeliveryUiColors.primary.withValues(
              alpha: 0.15 + progress * 0.2,
            ),
            blurRadius: 10 + progress * 8,
            spreadRadius: progress * 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
