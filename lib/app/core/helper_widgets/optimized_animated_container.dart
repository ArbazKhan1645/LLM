// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

class OptimizedAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool shouldAnimate;

  const OptimizedAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.shouldAnimate = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: curve,
        switchOutCurve: curve,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return shouldAnimate
              ? FadeTransition(
                  opacity: animation,
                  child: child,
                )
              : child;
        },
        child: child,
      ),
    );
  }
}
