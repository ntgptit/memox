import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class DeckTileDuePill extends StatelessWidget {
  const DeckTileDuePill({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.customColors.ratingHard.withValues(
        alpha: OpacityTokens.focus,
      ),
      borderRadius: BorderRadius.circular(RadiusTokens.full),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Text(
        '$count',
        style: context.textTheme.labelMedium?.copyWith(
          color: context.customColors.ratingHard,
        ),
      ),
    ),
  );
}
