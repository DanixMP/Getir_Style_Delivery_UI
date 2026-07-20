import 'package:flutter/material.dart';

import '../core/navigation/getir_style_delivery_ui_page_route.dart';
import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../features/ai_chat/ai_chat_screen.dart';
import '../l10n/app_localizations.dart';

/// Full-width AI entry on the profile screen (destination of the merge animation).
class ProfileAiBanner extends StatelessWidget {
  const ProfileAiBanner({
    super.key,
    required this.locale,
    this.onTap,
  });

  final Locale locale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => context.pushGetirStyleDeliveryUi(const AiChatScreen()),
        borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GetirStyleDeliveryUiColors.primary, GetirStyleDeliveryUiColors.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GetirStyleDeliveryUiColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(GetirStyleDeliveryUiRadius.lg),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: GetirStyleDeliveryUiColors.secondaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiAssistant,
                      style: GetirStyleDeliveryUiTypography.labelLg(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.aiBannerSubtitle,
                      style: GetirStyleDeliveryUiTypography.bodySm(
                        locale,
                        color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
