import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/app_services.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => Material(
        color: const Color(0xFFFFF3F3),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            details.exceptionAsString(),
            style: const TextStyle(color: Color(0xFFB00020), fontSize: 14),
          ),
        ),
      );
  final prefs = await SharedPreferences.getInstance();
  AppServices.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AppServices.instance.auth,
            AppServices.instance.account,
          )..bootstrap(),
        ),
      ],
      child: const GetirStyleDeliveryUiOpsApp(),
    ),
  );
}
