import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    required this.progress,
    this.height = SizeTokens.progressBarHeight,
    this.color,
    this.trackColor,
    super.key,
  });

  final double progress;
  final double height;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.full),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor ?? context.colors.surfaceContainerHighest),
            AnimatedFractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: safeProgress,
              duration: DurationTokens.slow,
              child: ColoredBox(color: color ?? context.colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
