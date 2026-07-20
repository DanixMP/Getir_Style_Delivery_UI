import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getir_style_delivery_ui_v2/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getir_style_delivery_ui_v2/core/localization/locale_provider.dart';
import 'package:getir_style_delivery_ui_v2/core/providers/address_provider.dart';
import 'package:getir_style_delivery_ui_v2/core/providers/app_services.dart';
import 'package:getir_style_delivery_ui_v2/core/providers/auth_provider.dart';
import 'package:getir_style_delivery_ui_v2/core/providers/profile_avatar_provider.dart';
import 'package:getir_style_delivery_ui_v2/core/providers/service_provider.dart';
import 'package:getir_style_delivery_ui_v2/features/cart/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GetirStyleDeliveryUi app launches login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    AppServices.instance.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
          ChangeNotifierProvider(create: (_) => ServiceProvider(prefs)),
          ChangeNotifierProvider(create: (_) => AddressProvider(prefs)),
          ChangeNotifierProvider(create: (_) => ProfileAvatarProvider(prefs)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              AppServices.instance.auth,
              AppServices.instance.account,
            )..isLoading = false,
          ),
        ],
        child: const GetirStyleDeliveryUiApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
