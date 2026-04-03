import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/progress/mastery_bar.dart';

class DeckTile extends StatelessWidget {
  const DeckTile({
    required this.deck,
    required this.subtitle,
    required this.masteryPercentage,
    this.isHighlighted = false,
    this.onTap,
    super.key,
  });

  final DeckEntity deck;
  final String subtitle;
  final double masteryPercentage;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    borderRadius: RadiusTokens.md,
    borderColor: isHighlighted ? context.colors.primary : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.style_outlined, color: Color(deck.colorValue)),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _DeckCopy(name: deck.name, subtitle: subtitle),
            ),
          ],
        ),
        if (deck.tags.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.md),
          Wrap(
            spacing: SpacingTokens.chipGap,
            runSpacing: SpacingTokens.chipGap,
            children: deck.tags.map((tag) => TagChip(label: tag)).toList(),
          ),
        ],
        const SizedBox(height: SpacingTokens.md),
        MasteryBar(percentage: masteryPercentage),
      ],
    ),
  );
}

class _DeckCopy extends StatelessWidget {
  const _DeckCopy({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: context.textTheme.titleMedium),
      const SizedBox(height: SpacingTokens.xs),
      Text(subtitle, style: context.textTheme.bodySmall),
    ],
  );
}
