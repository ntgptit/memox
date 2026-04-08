import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/presentation/models/deck_card_sort.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';

class DeckCardsToolbar extends StatelessWidget {
  const DeckCardsToolbar({
    required this.sort,
    required this.showFlaggedOnly,
    required this.onQueryChanged,
    required this.onSortChanged,
    required this.onFlagFilterChanged,
    super.key,
  });

  final DeckCardSort sort;
  final bool showFlaggedOnly;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<DeckCardSort> onSortChanged;
  final ValueChanged<bool> onFlagFilterChanged;

  static double get height =>
      SizeTokens.searchBarHeight +
      SizeTokens.touchTarget +
      (SpacingTokens.sm * 3);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DeckCardsToolbarHeader(
            sort: sort,
            showFlaggedOnly: showFlaggedOnly,
            onPressed: () {
              unawaited(_pickSort(context, onSortChanged));
            },
            onToggleFlagged: () => onFlagFilterChanged(!showFlaggedOnly),
          ),
          const SizedBox(height: SpacingTokens.sm),
          AppSearchBar(
            variant: AppSearchBarVariant.toolbar,
            hint: context.l10n.searchCardsHint,
            onChanged: onQueryChanged,
          ),
        ],
      ),
    ),
  );
}

class _DeckCardsToolbarHeader extends StatelessWidget {
  const _DeckCardsToolbarHeader({
    required this.sort,
    required this.showFlaggedOnly,
    required this.onPressed,
    required this.onToggleFlagged,
  });

  final DeckCardSort sort;
  final bool showFlaggedOnly;
  final VoidCallback onPressed;
  final VoidCallback onToggleFlagged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.l10n.cardsTitle,
          style: context.textTheme.titleLarge,
        ),
      ),
      IconActionButton(
        icon: Icons.flag_outlined,
        tooltip: showFlaggedOnly
            ? context.l10n.cardsAllCardsAction
            : context.l10n.cardsFlaggedOnlyAction,
        onTap: onToggleFlagged,
      ),
      const SizedBox(width: SpacingTokens.sm),
      SecondaryButton(
        label: _sortLabel(context, sort),
        icon: Icons.sort_outlined,
        fullWidth: false,
        height: SizeTokens.buttonHeightSm,
        onPressed: onPressed,
      ),
    ],
  );
}

String _sortLabel(BuildContext context, DeckCardSort sort) => switch (sort) {
  DeckCardSort.date => context.l10n.sortDateLabel,
  DeckCardSort.alpha => context.l10n.sortAlphaLabel,
  DeckCardSort.status => context.l10n.sortStatusLabel,
};

Future<void> _pickSort(
  BuildContext context,
  ValueChanged<DeckCardSort> onSortChanged,
) async {
  final selected = await showChoiceBottomSheet<DeckCardSort>(
    context,
    title: context.l10n.cardsTitle,
    options: [
      ChoiceOption(
        value: DeckCardSort.date,
        title: context.l10n.sortDateLabel,
        icon: Icons.schedule_outlined,
      ),
      ChoiceOption(
        value: DeckCardSort.alpha,
        title: context.l10n.sortAlphaLabel,
        icon: Icons.sort_by_alpha_outlined,
      ),
      ChoiceOption(
        value: DeckCardSort.status,
        title: context.l10n.sortStatusLabel,
        icon: Icons.tune_outlined,
      ),
    ],
  );

  if (selected == null) {
    return;
  }

  onSortChanged(selected);
}
