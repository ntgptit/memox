import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/decks/presentation/widgets/deck_stats_grid.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('DeckStatsGrid gives semantic emphasis to due known and new', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: DeckStatsGrid(
            stats: (
              total: 21,
              due: 8,
              known: 5,
              learning: 6,
              newCards: 2,
              mastery: 0.3,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(DeckStatsGrid));
    final dueValue = tester.widget<Text>(find.text('8'));
    final knownValue = tester.widget<Text>(find.text('5'));
    final newValue = tester.widget<Text>(find.text('2'));

    expect(dueValue.style?.color, context.colors.primary);
    expect(knownValue.style?.color, context.customColors.statusMastered);
    expect(newValue.style?.color, context.customColors.statusReviewing);
  });
}
