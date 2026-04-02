import 'package:flutter/material.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CardStatus.newCard => context.customColors.statusNew,
      CardStatus.learning => context.customColors.statusLearning,
      CardStatus.reviewing => context.customColors.statusReviewing,
      CardStatus.mastered => context.customColors.statusMastered,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(RadiusTokens.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: SizeTokens.statusDotSize,
              height: SizeTokens.statusDotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Text(
              status.label,
              style: context.appTextStyles.tagText.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
