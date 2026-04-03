import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class DifficultCardsSection extends StatefulWidget {
  const DifficultCardsSection({
    required this.cards,
    required this.onPractice,
    super.key,
  });

  final List<DifficultCard> cards;
  final VoidCallback onPractice;

  @override
  State<DifficultCardsSection> createState() => _DifficultCardsSectionState();
}

class _DifficultCardsSectionState extends State<DifficultCardsSection> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SizeTokens.touchTarget,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.statisticsCardsToFocusTitle,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.expand_less_outlined
                      : Icons.expand_more_outlined,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.md),
            child: widget.cards.isEmpty
                ? Text(
                    context.l10n.statisticsNoDifficultCards,
                    style: context.textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      ...widget.cards.map(
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
                      const SizedBox(height: SpacingTokens.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextLinkButton(
                          label: context.l10n.statisticsPracticeTheseAction,
                          onTap: widget.onPractice,
                        ),
                      ),
                    ],
                  ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: DurationTokens.normal,
        ),
      ],
    ),
  );
}
