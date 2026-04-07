import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class GuessFeedbackCard extends StatelessWidget {
  const GuessFeedbackCard({required this.card, super.key});

  final FlashcardEntity card;

  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: context.colors.surfaceContainerLow,
    leftBorderColor: context.customColors.success,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.guessCorrectAnswerLabel,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(card.front, style: context.textTheme.titleMedium),
        const SizedBox(height: SpacingTokens.sm),
        Text(card.back, style: context.textTheme.bodyMedium),
        if (card.example.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.md),
          Text(
            context.l10n.guessExampleLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(card.example, style: context.textTheme.bodySmall),
        ],
        if (card.hint.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.md),
          Text(
            context.l10n.cardHintLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(card.hint, style: context.textTheme.bodySmall),
        ],
      ],
    ),
  );
}
