import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';

/// Shared page transition for push routes.
///
/// Uses a combined fade + slight slide-up, which masks
/// the brief data-fetch delay on the incoming screen.
CustomTransitionPage<T> appFadeTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
  bool fullscreenDialog = false,
}) => CustomTransitionPage<T>(
  key: state.pageKey,
  fullscreenDialog: fullscreenDialog,
  reverseTransitionDuration: DurationTokens.fast,
  child: child,
  transitionsBuilder: _buildFadeSlideTransition,
);

const double _routeLoaderHoldEnd = 0.35;
const double _routeLoaderFadeEnd = 0.75;

Widget _buildFadeSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: EasingTokens.emphasizedDecelerate,
    reverseCurve: EasingTokens.emphasizedAccelerate,
  );

  return FadeTransition(
    opacity: curved,
    child: Stack(
      fit: StackFit.expand,
      children: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              if (animation.status == AnimationStatus.reverse) {
                return const SizedBox.shrink();
              }

              final opacity = _routeLoaderOpacity(animation.value);

              if (opacity == 0) {
                return const SizedBox.shrink();
              }

              return Opacity(
                opacity: opacity,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: const LoadingIndicator(),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

double _routeLoaderOpacity(double progress) {
  if (progress <= _routeLoaderHoldEnd) {
    return 1;
  }

  if (progress >= _routeLoaderFadeEnd) {
    return 0;
  }

  return 1 -
      ((progress - _routeLoaderHoldEnd) /
          (_routeLoaderFadeEnd - _routeLoaderHoldEnd));
}
