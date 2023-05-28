import 'package:flutter/material.dart';

import '../feature/pin/pin_overlay.dart';

const _kSlideTransitionDuration = Duration(milliseconds: 500);

class SecuredPageRoute<T> extends MaterialPageRoute<T> {
  final SecuredPageTransition transition;

  @override
  Duration get transitionDuration {
    switch (transition) {
      case SecuredPageTransition.platform:
        return super.transitionDuration;
      case SecuredPageTransition.slideInFromBottom:
        return _kSlideTransitionDuration;
    }
  }

  SecuredPageRoute({
    required WidgetBuilder builder,
    this.transition = SecuredPageTransition.platform,
    super.settings,
  }) : super(builder: (context) => PinOverlay(child: builder(context)));

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transition) {
      case SecuredPageTransition.platform:
        return super.buildTransitions(context, animation, secondaryAnimation, child);
      case SecuredPageTransition.slideInFromBottom:
        return _buildSlideInFromBottomTransitions(animation, child);
    }
  }

  Widget _buildSlideInFromBottomTransitions(Animation<double> animation, Widget child) {
    final curveTween = CurveTween(curve: Curves.easeInOutCubic);
    final offsetTween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero);
    final offsetAnimation = animation.drive(curveTween).drive(offsetTween);
    return SlideTransition(position: offsetAnimation, child: child);
  }
}

enum SecuredPageTransition { platform, slideInFromBottom }