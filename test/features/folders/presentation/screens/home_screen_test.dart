import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('HomeScreen toggles folder sort mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          folderRepositoryProvider.overrideWithValue(
            FakeFolderRepository(
              folders: const [FolderEntity(id: 1, name: 'Japanese N5')],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const <DeckEntity>[]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
        ],
        child: buildTestApp(home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Japanese N5'), findsOneWidget);
    expect(find.text('MY FOLDERS'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byTooltip('Reorder'), findsOneWidget);
    expect(find.byTooltip('Create folder'), findsOneWidget);
    expect(find.text('Create folder'), findsNothing);

    await tester.tap(find.byTooltip('Reorder'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Done'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.text('Drag items to change their order.'), findsOneWidget);
  });
}
