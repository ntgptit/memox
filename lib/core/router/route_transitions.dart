import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

/// Shared Axis Z — dung khi di sau vao phan cap noi dung.
/// Vi du: Home -> Folder -> Deck -> Study, Settings -> ThemePreview
CustomTransitionPage<T> sharedAxisZPage<T>({
  required Widget child,
  required GoRouterState state,
}) => CustomTransitionPage<T>(
  key: state.pageKey,
  child: child,
  transitionDuration: DurationTokens.normal,
  reverseTransitionDuration: DurationTokens.normal,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.scaled,
      child: child,
    );
  },
);

/// Fade Through — dung khi chuyen giua cac destination ngang hang.
/// Vi du: bottom nav tabs, search, cards screen
CustomTransitionPage<T> fadeThroughPage<T>({
  required Widget child,
  required GoRouterState state,
}) => CustomTransitionPage<T>(
  key: state.pageKey,
  child: child,
  transitionDuration: DurationTokens.normal,
  reverseTransitionDuration: DurationTokens.normal,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  },
);
