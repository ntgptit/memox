import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/lists/expandable_tile.dart';

class DifficultCardsSection extends StatelessWidget {
  const DifficultCardsSection({
    required this.cards,
    required this.onPractice,
    super.key,
  });

  final List<DifficultCard> cards;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: ExpandableTile(
      headerPadding: const EdgeInsets.all(SpacingTokens.cardPadding),
      expandedContentPadding: const EdgeInsets.fromLTRB(
        SpacingTokens.cardPadding,
        SpacingTokens.md,
        SpacingTokens.cardPadding,
        SpacingTokens.cardPadding,
      ),
      headerBuilder: (context, {required expanded}) => Text(
        context.l10n.statisticsCardsToFocusTitle,
        style: context.textTheme.titleMedium,
      ),
      expandedContent: cards.isEmpty
          ? Text(
              context.l10n.statisticsNoDifficultCards,
              style: context.textTheme.bodySmall,
            )
          : Column(
              children: [
                ...cards.map((card) => _DifficultCardRow(card: card)),
                const Gap.md(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextLinkButton(
                    label: context.l10n.statisticsPracticeTheseAction,
                    onTap: onPractice,
                  ),
                ),
              ],
            ),
    ),
  );
}

class _DifficultCardRow extends StatelessWidget {
  const _DifficultCardRow({required this.card});

  final DifficultCard card;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: context.colors.outline.withValues(
            alpha: OpacityTokens.divider,
          ),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.card.front,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall,
                ),
                const Gap.xs(),
                Text(card.deckName, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          const Gap.md(),
          Text(
            '${card.accuracy.round()}%',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
        ],
      ),
    ),
  );
}
