import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/presentation/widgets/deck_tile.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/lists/app_card_list_tile.dart';
import 'package:memox/shared/widgets/lists/app_edit_delete_menu.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('DeckTile displays stats and tags', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const DeckTile(
          deck: DeckEntity(
            id: 1,
            name: 'Core Vocabulary',
            description: 'Daily phrases and verbs',
            tags: <String>['topik', 'verbs'],
          ),
          subtitle: '42 cards · 8 due today',
          masteryPercentage: 0.5,
          dueCount: 8,
        ),
      ),
    );

    expect(find.text('Core Vocabulary'), findsOneWidget);
    expect(find.text('42 cards · 8 due today'), findsOneWidget);
    expect(find.text('Daily phrases and verbs'), findsOneWidget);
    expect(find.text('topik'), findsOneWidget);
    expect(find.text('verbs'), findsOneWidget);
    expect(find.byType(AppCardListTile), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.style_outlined), findsOneWidget);
    expect(find.text('8'), findsOneWidget);

    final card = tester.widget<AppCard>(find.byType(AppCard));
    expect(card.backgroundColor, isNull);
    expect(card.borderRadius, isNull);
  });

  testWidgets('DeckTile shows popup edit and delete actions', (tester) async {
    var edited = false;
    var deleted = false;

    await tester.pumpWidget(
      buildTestApp(
        home: DeckTile(
          deck: const DeckEntity(id: 1, name: 'Core Vocabulary'),
          subtitle: '42 cards · 8 due today',
          masteryPercentage: 0.5,
          dueCount: 8,
          onEdit: () => edited = true,
          onDelete: () => deleted = true,
        ),
      ),
    );

    expect(find.byType(AppEditDeleteMenu), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete deck'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(edited, isTrue);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete deck'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });

  testWidgets('DeckTile keeps due pill vertically aligned with action menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: DeckTile(
          deck: const DeckEntity(id: 1, name: 'Core Vocabulary'),
          subtitle: '42 cards · 8 due today',
          masteryPercentage: 0.5,
          dueCount: 8,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dueCenter = tester.getCenter(find.text('8'));
    final menuCenter = tester.getCenter(find.byIcon(Icons.more_vert));

    expect(dueCenter.dy, closeTo(menuCenter.dy, 1));
  });

  testWidgets('DeckTile renders reorder handle inside the card shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const DeckTile(
          deck: DeckEntity(id: 1, name: 'Core Vocabulary'),
          subtitle: '42 cards · 8 due today',
          masteryPercentage: 0.5,
          dueCount: 8,
          reorderHandle: Icon(Icons.drag_indicator_outlined),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppCardListTile),
        matching: find.byIcon(Icons.drag_indicator_outlined),
      ),
      findsOneWidget,
    );
    expect(find.byType(AppEditDeleteMenu), findsNothing);
  });
}
