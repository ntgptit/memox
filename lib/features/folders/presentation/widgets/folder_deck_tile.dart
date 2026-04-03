import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/progress/mastery_ring.dart';

class FolderDeckTile extends StatelessWidget {
  const FolderDeckTile({
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
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      leftBorderColor: isHighlighted ? context.colors.primary : null,
      child: Row(
        children: [
          Icon(Icons.style_outlined, color: Color(deck.colorValue)),
          const SizedBox(width: SpacingTokens.lg),
          Expanded(
            child: _DeckText(name: deck.name, subtitle: subtitle),
          ),
          const SizedBox(width: SpacingTokens.md),
          MasteryRing(
            percentage: masteryPercentage,
            showZeroPercentText: true,
          ),
        ],
      ),
    );
  }
}

class _DeckText extends StatelessWidget {
  const _DeckText({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: textTheme.titleMedium),
        Text(subtitle, style: textTheme.bodySmall),
      ],
    );
  }
}
