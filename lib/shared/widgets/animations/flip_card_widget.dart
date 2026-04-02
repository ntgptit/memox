import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

class FlipCardWidget extends StatelessWidget {
  const FlipCardWidget({
    required this.front,
    required this.back,
    required this.isFlipped,
    this.duration = DurationTokens.cardFlip,
    super.key,
  });

  final Widget front;
  final Widget back;
  final bool isFlipped;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: isFlipped ? 1 : 0),
    duration: duration,
    builder: (context, value, _) {
      final showingBack = value >= 0.5;
      final angle = showingBack ? value * math.pi - math.pi : value * math.pi;
      final scale = 1 - (0.04 * (1 - ((value - 0.5).abs() * 2)));
      final child = showingBack
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(math.pi),
              child: back,
            )
          : front;

      return Transform.scale(
        scale: scale,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: child,
        ),
      );
    },
  );
}
