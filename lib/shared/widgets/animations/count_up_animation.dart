import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';

class CountUpAnimation extends StatelessWidget {
  const CountUpAnimation({
    required this.end,
    required this.builder,
    this.duration = DurationTokens.countUp,
    this.curve = EasingTokens.emphasizedDecelerate,
    super.key,
  });

  final double end;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: end),
    duration: duration,
    curve: curve,
    builder: (context, value, _) => builder(context, value),
  );
}
