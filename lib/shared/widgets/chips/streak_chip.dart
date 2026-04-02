import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count < 2) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.customColors.mastery.withValues(
          alpha: OpacityTokens.press,
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department_outlined),
            const SizedBox(width: SpacingTokens.xs),
            Text(count.toString(), style: context.appTextStyles.tagText),
          ],
        ),
      ),
    ).animate().scale(duration: DurationTokens.normal);
  }
}
