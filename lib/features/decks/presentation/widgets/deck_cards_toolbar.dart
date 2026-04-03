import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/presentation/models/deck_card_sort.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';

class DeckCardsToolbar extends StatelessWidget {
  const DeckCardsToolbar({
    required this.sort,
    required this.onQueryChanged,
    required this.onSortChanged,
    super.key,
  });

  final DeckCardSort sort;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<DeckCardSort> onSortChanged;

  static double get height =>
      SizeTokens.searchBarHeight +
      SizeTokens.buttonHeight +
      (SpacingTokens.md * 3);

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      child: Column(
        children: [
          AppSearchBar(
            hint: context.l10n.searchCardsHint,
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: SpacingTokens.md),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<DeckCardSort>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: DeckCardSort.date,
                  label: Text(context.l10n.sortDateLabel),
                ),
                ButtonSegment(
                  value: DeckCardSort.alpha,
                  label: Text(context.l10n.sortAlphaLabel),
                ),
                ButtonSegment(
                  value: DeckCardSort.status,
                  label: Text(context.l10n.sortStatusLabel),
                ),
              ],
              selected: {sort},
              onSelectionChanged: (selection) => onSortChanged(selection.first),
            ),
          ),
        ],
      ),
    ),
  );
}
