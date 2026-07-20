import 'package:flutter/material.dart';

/// Forces left-to-right layout for phone numbers, OTP, and numeric fields.
class LtrInputScope extends StatelessWidget {
  const LtrInputScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}
