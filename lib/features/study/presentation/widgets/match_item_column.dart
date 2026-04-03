import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/widgets/match_item_card.dart';

class MatchItemColumn extends StatelessWidget {
  const MatchItemColumn({
    required this.items,
    required this.state,
    required this.onSelect,
    super.key,
  });

  final List<({String id, String text, MatchItemType type})> items;
  final MatchState state;
  final ValueChanged<({String id, String text, MatchItemType type})> onSelect;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where((item) => !_isSettledMatched(item))
        .toList();
    return AnimatedSize(
      duration: DurationTokens.normal,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          for (final item in visibleItems) ...[
            MatchItemCard(
              text: item.text,
              isSelected: _isSelected(item),
              isMatched: _isAnimatingMatch(item),
              isWrong: _isWrong(item),
              onTap: () => onSelect(item),
            ),
            if (item != visibleItems.last)
              const SizedBox(height: SpacingTokens.sm),
          ],
        ],
      ),
    );
  }

  bool _isAnimatingMatch(({String id, String text, MatchItemType type}) item) {
    final result = state.lastResult;

    if (result == null || result.outcome != MatchAttemptOutcome.correct) {
      return false;
    }

    final selectedId = item.type == MatchItemType.term
        ? result.termId
        : result.definitionId;
    return item.id == selectedId;
  }

  bool _isSelected(({String id, String text, MatchItemType type}) item) =>
      item.type == MatchItemType.term
      ? state.selectedTermId == item.id
      : state.selectedDefinitionId == item.id;

  bool _isSettledMatched(({String id, String text, MatchItemType type}) item) =>
      !_isAnimatingMatch(item) &&
      (item.type == MatchItemType.term
          ? state.matchedPairIds.contains(item.id)
          : state.isDefinitionMatched(item.id));

  bool _isWrong(({String id, String text, MatchItemType type}) item) {
    final result = state.lastResult;

    if (result == null || result.outcome != MatchAttemptOutcome.wrong) {
      return false;
    }

    final selectedId = item.type == MatchItemType.term
        ? result.termId
        : result.definitionId;
    return item.id == selectedId;
  }
}
