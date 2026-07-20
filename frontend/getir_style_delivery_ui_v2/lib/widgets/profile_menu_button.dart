import 'package:flutter/material.dart';

import '../navigation/main_shell_scope.dart';

/// Opens the profile side drawer when inside [MainShellScope].
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({
    super.key,
    this.color,
    this.icon = Icons.menu,
  });

  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => MainShellScope.openDrawerIfAvailable(context),
    );
  }
}
