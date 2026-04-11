import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/widgets/match_item_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

const int _matchTermMaxLines = 2;
const int _matchDefinitionMaxLines = 4;

class MatchItemBoard extends StatelessWidget {
  const MatchItemBoard({
    required this.state,
    required this.onSelect,
    super.key,
  });

  final MatchState state;
  final ValueChanged<({String id, String text, MatchItemType type})> onSelect;

  @override
  Widget build(BuildContext context) {
    final resolver = _MatchItemStateResolver(state);
    final terms = resolver.visibleItems(state.game.terms);
    final definitions = resolver.visibleItems(state.game.definitions);
    final rowCount = terms.length > definitions.length
        ? terms.length
        : definitions.length;

    if (rowCount == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final stableRowHeight = _stableRowHeight(
          constraints: constraints,
          boardPairCount: state.game.correctPairs.length,
        );
        return Align(
          alignment: Alignment.topCenter,
          child: AnimatedSize(
            duration: DurationTokens.normal,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < rowCount; index++) ...[
                    SizedBox(
                      height: stableRowHeight,
                      child: _MatchItemRow(
                        term: index < terms.length ? terms[index] : null,
                        definition: index < definitions.length
                            ? definitions[index]
                            : null,
                        resolver: resolver,
                        onSelect: onSelect,
                      ),
                    ),
                    if (index != rowCount - 1) const Gap.sm(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

double _stableRowHeight({
  required BoxConstraints constraints,
  required int boardPairCount,
}) {
  final slotCount = boardPairCount <= 0 ? 1 : boardPairCount;
  final totalGapHeight = SpacingTokens.sm * (slotCount - 1);
  final availableHeight = constraints.maxHeight.isFinite
      ? constraints.maxHeight
      : SizeTokens.flashcardMinHeight * slotCount + totalGapHeight;
  final rawHeight = (availableHeight - totalGapHeight) / slotCount;
  return rawHeight.clamp(SizeTokens.touchTarget, SizeTokens.flashcardMinHeight);
}

class _MatchItemRow extends StatelessWidget {
  const _MatchItemRow({
    required this.term,
    required this.definition,
    required this.resolver,
    required this.onSelect,
  });

  final ({String id, String text, MatchItemType type})? term;
  final ({String id, String text, MatchItemType type})? definition;
  final _MatchItemStateResolver resolver;
  final ValueChanged<({String id, String text, MatchItemType type})> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(child: _buildTermCard(context)),
      const Gap.md(),
      Expanded(child: _buildDefinitionCard(context)),
    ],
  );

  Widget _buildDefinitionCard(BuildContext context) => _buildCard(
    context.appTextStyles.questionText,
    definition,
    maxLines: _matchDefinitionMaxLines,
  );

  Widget _buildTermCard(BuildContext context) => _buildCard(
    context.appTextStyles.studyTerm,
    term,
    maxLines: _matchTermMaxLines,
  );

  Widget _buildCard(
    TextStyle textStyle,
    ({String id, String text, MatchItemType type})? item, {
    required int maxLines,
  }) {
    if (item == null) {
      return const SizedBox.shrink();
    }

    return MatchItemCard(
      text: item.text,
      textStyle: textStyle,
      maxLines: maxLines,
      isSelected: resolver.isSelected(item),
      isMatched: resolver.isAnimatingMatch(item),
      isWrong: resolver.isWrong(item),
      onTap: () => onSelect(item),
    );
  }
}

class _MatchItemStateResolver {
  const _MatchItemStateResolver(this.state);

  final MatchState state;

  List<({String id, String text, MatchItemType type})> visibleItems(
    List<({String id, String text, MatchItemType type})> items,
  ) => items.where((item) => !_isSettledMatched(item)).toList();

  bool isAnimatingMatch(({String id, String text, MatchItemType type}) item) {
    final result = state.lastResult;

    if (result == null || result.outcome != MatchAttemptOutcome.correct) {
      return false;
    }

    final selectedId = item.type == MatchItemType.term
        ? result.termId
        : result.definitionId;
    return item.id == selectedId;
  }

  bool isSelected(({String id, String text, MatchItemType type}) item) =>
      item.type == MatchItemType.term
      ? state.selectedTermId == item.id
      : state.selectedDefinitionId == item.id;

  bool isWrong(({String id, String text, MatchItemType type}) item) {
    final result = state.lastResult;

    if (result == null || result.outcome != MatchAttemptOutcome.wrong) {
      return false;
    }

    final selectedId = item.type == MatchItemType.term
        ? result.termId
        : result.definitionId;
    return item.id == selectedId;
  }

  bool _isSettledMatched(({String id, String text, MatchItemType type}) item) {
    if (isAnimatingMatch(item)) {
      return false;
    }

    return item.type == MatchItemType.term
        ? state.matchedPairIds.contains(item.id)
        : state.isDefinitionMatched(item.id);
  }
}
