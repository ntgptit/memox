import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class FillMistakesPanel extends StatefulWidget {
  const FillMistakesPanel({
    required this.cards,
    required this.results,
    this.onTapCard,
    super.key,
  });

  final List<FlashcardEntity> cards;
  final List<FillCardResult> results;
  final ValueChanged<FlashcardEntity>? onTapCard;

  @override
  State<FillMistakesPanel> createState() => _FillMistakesPanelState();
}

class _FillMistakesPanelState extends State<FillMistakesPanel> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final mistakeResults = widget.results
        .where((item) => item.firstAttemptResult != FillResult.correct)
        .toList(growable: false);

    if (mistakeResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextLinkButton(
            label: context.l10n.fillMistakesListAction,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const SizedBox(height: SpacingTokens.md),
            for (var index = 0; index < mistakeResults.length; index++)
              _MistakeRow(
                card: _findCard(mistakeResults[index].cardId),
                result: mistakeResults[index],
                onTap: widget.onTapCard,
                showDivider: index < mistakeResults.length - 1,
              ),
          ],
        ],
      ),
    );
  }

  FlashcardEntity _findCard(String cardId) =>
      widget.cards.firstWhere((card) => '${card.id}' == cardId);
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow({
    required this.card,
    required this.result,
    required this.showDivider,
    this.onTap,
  });

  final FlashcardEntity card;
  final FillCardResult result;
  final bool showDivider;
  final ValueChanged<FlashcardEntity>? onTap;

  @override
  Widget build(BuildContext context) => AppListTile(
    title: card.front,
    subtitle:
        '${card.back} (${context.l10n.fillMistakeSummary(result.retryCount)})',
    trailing: onTap == null
        ? null
        : Icon(
            Icons.open_in_new_outlined,
            color: context.colors.onSurfaceVariant,
          ),
    onTap: onTap == null ? null : () => onTap!(card),
    showDivider: showDivider,
  );
}
