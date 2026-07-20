import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/address_provider.dart';
import '../core/theme/pages/navigation_theme.dart';
import '../core/theme/getir_style_delivery_ui_spacing.dart';
import '../core/theme/getir_style_delivery_ui_typography.dart';
import '../features/address/address_manager_sheet.dart';
import '../l10n/app_localizations.dart';
import '../navigation/main_shell_scope.dart';

class GetirStyleDeliveryUiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GetirStyleDeliveryUiAppBar({
    super.key,
    this.title,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.titleColor,
    this.showAddressChip = false,
    this.trailing,
    this.leading,
  });

  final String? title;
  final bool? centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? titleColor;
  final bool showAddressChip;
  final Widget? trailing;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return AppBar(
      backgroundColor: backgroundColor ?? NavigationTheme.barBackground,
      foregroundColor: foregroundColor,
      elevation: 1,
      shadowColor: Colors.black26,
      centerTitle: centerTitle ?? (title != null),
      leading: leading ??
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => MainShellScope.openDrawerIfAvailable(context),
          ),
      title: title != null
          ? Text(
              title!,
              style: GetirStyleDeliveryUiTypography.headlineMd(
                locale,
                color: titleColor ?? foregroundColor,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.3),
            )
          : Text(
              l10n.appName,
              style: GetirStyleDeliveryUiTypography.headlineLg(
                locale,
                color: titleColor ?? NavigationTheme.activeIcon,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
      actions: [
        if (showAddressChip)
          Builder(
            builder: (context) {
              final selected = context.watch<AddressProvider>().selected;
              final hasSelection = selected != null;
              return Padding(
                padding: const EdgeInsets.only(right: GetirStyleDeliveryUiSpacing.marginMobile),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => showAddressManager(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on,
                              size: 18, color: foregroundColor),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Text(
                              hasSelection ? selected.title : l10n.addAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GetirStyleDeliveryUiTypography.labelMd(
                                locale,
                                color: foregroundColor,
                              ),
                            ),
                          ),
                          Icon(
                            hasSelection
                                ? Icons.keyboard_arrow_down
                                : Icons.add,
                            size: 18,
                            color: foregroundColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        if (trailing != null) trailing!,
        if (!showAddressChip && trailing == null) const SizedBox(width: 48),
      ],
    );
  }
}
