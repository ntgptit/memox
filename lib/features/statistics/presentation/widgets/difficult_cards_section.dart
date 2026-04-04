import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';
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
                ...cards.map(
                  (card) => AppListTile(
                    title: card.card.front,
                    subtitle: card.deckName,
                    trailing: Text(
                      '${card.accuracy.round()}%',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: card.accuracy < 50
                            ? context.customColors.ratingAgain
                            : context.colors.onSurface,
                      ),
                    ),
                  ),
                ),
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
