import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class MasteryBar extends StatelessWidget {
  const MasteryBar({
    required this.percentage,
    this.height = SizeTokens.masteryBarHeight,
    this.animate = true,
    super.key,
  });

  final double percentage;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final safePercentage = percentage.clamp(0.0, 1.0);
    final fill = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.customColors.masteryLow,
            context.customColors.masteryMid,
            context.customColors.masteryHigh,
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.full),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.colors.surfaceContainerHighest),
            if (animate)
              AnimatedFractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: safePercentage,
                duration: DurationTokens.slow,
                child: fill,
              ),
            if (!animate)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: safePercentage,
                child: fill,
              ),
          ],
        ),
      ),
    );
  }
}
