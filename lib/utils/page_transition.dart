import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({required this.page, required this.direction})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            Offset begin;

            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0, 1);
                break;
              case AxisDirection.down:
                begin = const Offset(0, -1);
                break;
              case AxisDirection.right:
                begin = const Offset(-1, 0);
                break;
              default:
                begin = const Offset(1, 0);
            }

            final tween =
                Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
