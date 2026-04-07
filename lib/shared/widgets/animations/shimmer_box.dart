import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = RadiusTokens.sm,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: OpacityTokens.hover),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return box;
    }

    return box
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
          begin: 1,
          end: 0.4,
          duration: DurationTokens.slow * 2,
          curve: Curves.easeInOut,
        );
  }
}
