import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/presentation/widgets/deck_tile.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('DeckTile displays stats and tags', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const DeckTile(
          deck: DeckEntity(
            id: 1,
            name: 'Core Vocabulary',
            tags: <String>['topik', 'verbs'],
          ),
          subtitle: '42 cards · 8 due today',
          masteryPercentage: 0.5,
        ),
      ),
    );

    expect(find.text('Core Vocabulary'), findsOneWidget);
    expect(find.text('42 cards · 8 due today'), findsOneWidget);
    expect(find.text('topik'), findsOneWidget);
    expect(find.text('verbs'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.style_outlined), findsOneWidget);
  });
}
