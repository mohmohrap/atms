import 'package:flutter/material.dart';

void navigateToWithFade(BuildContext context, Widget screen) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 350),
    reverseTransitionDuration: Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ));
}
