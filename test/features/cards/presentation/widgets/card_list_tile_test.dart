import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/features/cards/presentation/widgets/card_list_tile.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/lists/app_edit_delete_menu.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('CardListTile header pressable reaches the card edges', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Center(
          child: SizedBox(
            width: 320,
            child: CardListTile(
              card: const FlashcardEntity(
                id: 1,
                deckId: 3,
                front: '안녕하세요',
                back: 'Hello',
                hint: 'Greeting',
              ),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardSurface = find
        .descendant(of: find.byType(AppCard), matching: find.byType(Material))
        .first;
    final headerPressable = find
        .descendant(
          of: find.byType(AppPressable),
          matching: find.byType(InkWell),
        )
        .first;

    expect(tester.getTopLeft(headerPressable), tester.getTopLeft(cardSurface));
    expect(
      tester.getTopRight(headerPressable),
      tester.getTopRight(cardSurface),
    );
  });

  testWidgets('CardListTile expands when the header is tapped', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: CardListTile(
          card: const FlashcardEntity(
            id: 1,
            deckId: 3,
            front: '안녕하세요',
            back: 'Hello',
            hint: 'Greeting',
          ),
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Greeting'), findsNothing);

    await tester.tap(find.text('안녕하세요'));
    await tester.pumpAndSettle();

    expect(find.text('Greeting'), findsOneWidget);
    expect(find.byType(AppEditDeleteMenu), findsOneWidget);

    final context = tester.element(find.byType(CardListTile));
    final card = tester.widget<AppCard>(find.byType(AppCard));
    expect(
      card.backgroundColor,
      Theme.of(context).colorScheme.surfaceContainerLow,
    );
    expect(card.borderColor, Theme.of(context).colorScheme.outlineVariant);
  });

  testWidgets('CardListTile hides the reserved flag tag from visible chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: CardListTile(
          card: const FlashcardEntity(
            id: 1,
            deckId: 3,
            front: '안녕하세요',
            back: 'Hello',
            tags: <String>[flaggedCardTag, 'grammar'],
          ),
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('안녕하세요'));
    await tester.pumpAndSettle();

    expect(find.text('grammar'), findsOneWidget);
    expect(find.text(flaggedCardTag), findsNothing);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
  });
}
