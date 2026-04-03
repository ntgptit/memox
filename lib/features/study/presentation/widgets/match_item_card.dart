import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class MatchItemCard extends StatelessWidget {
  const MatchItemCard({
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.isMatched = false,
    this.isWrong = false,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isMatched;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    final borderColor = isWrong
        ? context.colors.error
        : isSelected
        ? context.colors.primary
        : context.colors.outline.withValues(alpha: OpacityTokens.borderSubtle);
    final backgroundColor = isSelected
        ? context.colors.primary.withValues(alpha: OpacityTokens.selected)
        : isMatched
        ? context.customColors.success.withValues(alpha: OpacityTokens.selected)
        : context.colors.surface;
    final textColor = isSelected
        ? context.colors.primary
        : context.colors.onSurface;
    final child = AnimatedScale(
      scale: isSelected ? 1.02 : 1,
      duration: DurationTokens.normal,
      child: AppCard(
        onTap: onTap,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderRadius: RadiusTokens.md,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
    return child
        .animate(target: isWrong ? 1 : 0)
        .shakeX(
          duration: DurationTokens.slow,
          amount: SpacingTokens.xs,
          curve: Curves.easeOut,
        )
        .animate(target: isMatched ? 1 : 0)
        .fadeOut(duration: DurationTokens.slow)
        .scale(end: const Offset(0.92, 0.92), duration: DurationTokens.slow);
  }
}
