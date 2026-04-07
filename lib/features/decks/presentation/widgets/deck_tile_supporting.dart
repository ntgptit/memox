import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/progress/mastery_bar.dart';

class DeckTileSupporting extends StatelessWidget {
  const DeckTileSupporting({
    required this.deck,
    required this.masteryPercentage,
    super.key,
  });

  final DeckEntity deck;
  final double masteryPercentage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (deck.description.trim().isNotEmpty)
        Text(
          deck.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall,
        ),
      if (deck.description.trim().isNotEmpty && deck.tags.isNotEmpty)
        const Gap.md(),
      if (deck.tags.isNotEmpty)
        Wrap(
          spacing: SpacingTokens.chipGap,
          runSpacing: SpacingTokens.chipGap,
          children: deck.tags.map((tag) => TagChip(label: tag)).toList(),
        ),
      if (deck.description.trim().isNotEmpty || deck.tags.isNotEmpty)
        const Gap.md(),
      Row(
        children: [
          Expanded(child: MasteryBar(percentage: masteryPercentage)),
          const Gap.md(),
          Text(
            context.l10n.deckMasteryLabel((masteryPercentage * 100).round()),
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ],
  );
}
