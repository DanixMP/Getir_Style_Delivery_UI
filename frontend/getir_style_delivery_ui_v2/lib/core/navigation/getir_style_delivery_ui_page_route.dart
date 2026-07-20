import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

enum GetirStyleDeliveryUiTransition {
  fadeThrough,
  sharedAxisHorizontal,
  sharedAxisVertical,
  fadeScale,
}

/// Smooth page routes used across the app.
class GetirStyleDeliveryUiPageRoute<T> extends PageRouteBuilder<T> {
  GetirStyleDeliveryUiPageRoute({
    required Widget page,
    this.transition = GetirStyleDeliveryUiTransition.fadeThrough,
    super.settings,
  }) : super(
          pageBuilder: (_, _, _) => page,
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transition) {
              case GetirStyleDeliveryUiTransition.fadeThrough:
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              case GetirStyleDeliveryUiTransition.sharedAxisHorizontal:
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              case GetirStyleDeliveryUiTransition.sharedAxisVertical:
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child,
                );
              case GetirStyleDeliveryUiTransition.fadeScale:
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
            }
          },
        );

  final GetirStyleDeliveryUiTransition transition;
}

extension GetirStyleDeliveryUiNavigator on BuildContext {
  Future<T?> pushGetirStyleDeliveryUi<T>(
    Widget page, {
    GetirStyleDeliveryUiTransition transition = GetirStyleDeliveryUiTransition.fadeThrough,
  }) {
    return Navigator.of(this).push<T>(
      GetirStyleDeliveryUiPageRoute<T>(page: page, transition: transition),
    );
  }
}
