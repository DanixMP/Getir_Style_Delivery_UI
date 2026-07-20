import 'package:flutter/material.dart';

/// Exposes shell-level actions (e.g. open profile drawer) to nested screens.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.openProfileDrawer,
    required super.child,
  });

  final VoidCallback openProfileDrawer;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static void openDrawerIfAvailable(BuildContext context) {
    maybeOf(context)?.openProfileDrawer();
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      openProfileDrawer != oldWidget.openProfileDrawer;
}
