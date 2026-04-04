import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

class FadeInWidget extends StatelessWidget {
  const FadeInWidget({
    required this.child,
    this.delay = Duration.zero,
    this.duration = DurationTokens.fast,
    this.slideY = 0.05,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideY;

  @override
  Widget build(BuildContext context) => child
      .animate(delay: delay)
      .fadeIn(duration: duration)
      .slideY(begin: slideY, end: 0, duration: duration);
}
