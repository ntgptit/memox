import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';

class RecallPromptCard extends StatelessWidget {
  const RecallPromptCard({required this.card, super.key});

  final FlashcardEntity card;

  @override
  Widget build(BuildContext context) =>
      AppCard(
            backgroundColor: context.colors.surfaceContainerHighest,
            padding: const EdgeInsets.all(SpacingTokens.fieldGap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.recallPromptLabel.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    letterSpacing: TypographyTokens.labelSpacing,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  card.front,
                  style: context.appTextStyles.recallTerm,
                  textAlign: TextAlign.center,
                ),
                if (card.tags.isNotEmpty) ...[
                  const SizedBox(height: SpacingTokens.md),
                  TagChip(label: card.tags.first),
                ],
              ],
            ),
          )
          .animate()
          .fadeIn(duration: DurationTokens.normal)
          .scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1, 1),
            duration: DurationTokens.normal,
          );
}
