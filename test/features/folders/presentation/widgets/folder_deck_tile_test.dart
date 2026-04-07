import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/presentation/widgets/folder_deck_tile.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/lists/app_card_list_tile.dart';
import 'package:memox/shared/widgets/lists/app_tile_glyph.dart';
import 'package:memox/shared/widgets/progress/mastery_ring.dart';

import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('FolderDeckTile uses the shared card row grammar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const FolderDeckTile(
          deck: DeckEntity(id: 1, name: 'Korean Core'),
          subtitle: '42 cards · 8 due today',
          masteryPercentage: 0.5,
        ),
      ),
    );

    expect(find.byType(AppCardListTile), findsOneWidget);
    expect(find.byType(AppTileGlyph), findsOneWidget);
    expect(find.byType(MasteryRing), findsOneWidget);
    expect(find.text('Korean Core'), findsOneWidget);
    expect(find.text('42 cards · 8 due today'), findsOneWidget);
  });

  testWidgets(
    'FolderDeckTile forwards highlight state through the card border',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const FolderDeckTile(
            deck: DeckEntity(id: 1, name: 'Korean Core'),
            subtitle: '42 cards · 8 due today',
            masteryPercentage: 0.5,
            isHighlighted: true,
          ),
        ),
      );

      final card = tester.widget<AppCard>(find.byType(AppCard));

      expect(card.borderColor, isNotNull);
    },
  );
}
