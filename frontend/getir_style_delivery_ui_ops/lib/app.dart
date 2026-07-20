import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/getir_style_delivery_ui_app_theme.dart';
import 'core/theme/getir_style_delivery_ui_colors.dart';
import 'features/auth/login_screen.dart';
import 'features/operator/operator_dashboard.dart';
import 'features/vendor/vendor_dashboard.dart';

class GetirStyleDeliveryUiOpsApp extends StatelessWidget {
  const GetirStyleDeliveryUiOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'GetirStyleDeliveryUi Ops',
      debugShowCheckedModeBanner: false,
      theme: GetirStyleDeliveryUiAppTheme.light(),
      darkTheme: GetirStyleDeliveryUiAppTheme.dark(),
      themeMode: theme.themeMode,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const _BootSplash(),
      ),
      home: auth.isLoading
          ? const _BootSplash()
          : !auth.isAuthenticated
              ? const LoginScreen()
              : auth.isVendor
                  ? const VendorDashboard()
                  : const OperatorDashboard(),
    );
  }
}

/// Visible splash while auth bootstraps — avoids a blank white screen on web.
class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: GetirStyleDeliveryUiColors.primary,
      body: Center(
        child: CircularProgressIndicator(color: GetirStyleDeliveryUiColors.secondaryContainer),
      ),
    );
  }
}
