import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/presentation/models/deck_card_sort.dart';
import 'package:memox/features/decks/presentation/widgets/deck_cards_toolbar.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('DeckCardsToolbar keeps the header inset from the top edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SizedBox(
            height: DeckCardsToolbar.height,
            child: const DeckCardsToolbar(
              sort: DeckCardSort.date,
              showFlaggedOnly: false,
              onQueryChanged: _noopQuery,
              onFlagFilterChanged: _noopFlagFilter,
              onSortChanged: _noopSort,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(DeckCardsToolbar));
    final surfaceFinder = find
        .descendant(
          of: find.byType(DeckCardsToolbar),
          matching: find.byType(DecoratedBox),
        )
        .first;
    final toolbarRect = tester.getRect(surfaceFinder);
    final sortButtonRect = tester.getRect(
      find.widgetWithText(OutlinedButton, 'Date'),
    );
    final searchBarRect = tester.getRect(find.byType(AppSearchBar));
    final title = tester.widget<Text>(find.text('Cards'));
    final surface = tester.widget<DecoratedBox>(surfaceFinder);

    expect(
      sortButtonRect.top - toolbarRect.top,
      closeTo(SpacingTokens.sm, 0.01),
    );
    expect(
      searchBarRect.top - sortButtonRect.bottom,
      closeTo(SpacingTokens.sm, 0.01),
    );
    expect(
      title.style?.fontSize,
      Theme.of(context).textTheme.titleLarge?.fontSize,
    );
    expect(
      (surface.decoration as BoxDecoration).color,
      Theme.of(context).colorScheme.surfaceContainerLow,
    );
  });
}

void _noopQuery(String _) {}

void _noopFlagFilter(bool _) {}

void _noopSort(DeckCardSort _) {}
