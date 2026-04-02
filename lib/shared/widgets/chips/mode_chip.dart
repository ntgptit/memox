import 'package:flutter/material.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class ModeChip extends StatelessWidget {
  const ModeChip({required this.mode, this.isSelected = false, super.key});

  final StudyMode mode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: DurationTokens.normal,
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.sm,
      vertical: SpacingTokens.xs,
    ),
    decoration: BoxDecoration(
      color: isSelected
          ? context.colors.primary.withValues(alpha: OpacityTokens.selected)
          : context.colors.surface.withValues(alpha: 0),
      border: Border.all(
        color: isSelected ? context.colors.primary : context.colors.outline,
      ),
      borderRadius: BorderRadius.circular(RadiusTokens.chip),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: SizeTokens.chipHeightSm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.full),
            ),
            child: Center(child: Text(mode.emoji)),
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        Text(mode.label, style: context.appTextStyles.tagText),
      ],
    ),
  );
}
