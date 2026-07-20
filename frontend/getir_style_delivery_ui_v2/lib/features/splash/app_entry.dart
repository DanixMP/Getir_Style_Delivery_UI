import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../navigation/main_shell.dart';
import 'splash_screen.dart';

/// Coordinates the launch splash with auth bootstrap, then routes to the app.
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  final _splashKey = GlobalKey<SplashScreenState>();
  bool _showMain = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launch());
  }

  Future<void> _launch() async {
    final auth = context.read<AuthProvider>();

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2300)),
      _waitWhile(() => auth.isLoading),
    ]);

    if (!mounted) return;
    await _splashKey.currentState?.playExit();
    if (!mounted) return;
    setState(() => _showMain = true);
  }

  Future<void> _waitWhile(bool Function() condition) async {
    while (condition() && mounted) {
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showMain) {
      final auth = context.watch<AuthProvider>();
      return auth.isAuthenticated ? const MainShell() : const LoginScreen();
    }
    return SplashScreen(key: _splashKey);
  }
}
