import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';

/// A single shimmering placeholder rectangle.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = RadiusTokens.md,
    super.key,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.colors.onSurface.withValues(
      alpha: OpacityTokens.outline,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: DurationTokens.pulse, color: context.colors.surface);
  }
}
