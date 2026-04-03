import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class FillMistakesPanel extends StatefulWidget {
  const FillMistakesPanel({required this.cards, required this.results, super.key});

  final List<FlashcardEntity> cards;
  final List<FillCardResult> results;

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
            for (final result in mistakeResults)
              _MistakeRow(card: _findCard(result.cardId), result: result),
          ],
        ],
      ),
    );
  }

  FlashcardEntity _findCard(String cardId) =>
      widget.cards.firstWhere((card) => '${card.id}' == cardId);
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow({required this.card, required this.result});

  final FlashcardEntity card;
  final FillCardResult result;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
    child: Text(
      '${card.front} → ${card.back} (${context.l10n.fillMistakeSummary(result.retryCount)})',
      style: context.textTheme.bodySmall,
    ),
  );
}
