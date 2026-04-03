import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/shared/widgets/navigation/top_bar_back_button.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets(
    'does not offer deck creation when folder already has subfolders',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            folderRepositoryProvider.overrideWithValue(
              FakeFolderRepository(
                folders: const [
                  FolderEntity(id: 1, name: 'Root'),
                  FolderEntity(id: 2, name: 'Child', parentId: 1),
                ],
              ),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const <DeckEntity>[]),
            ),
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(),
            ),
          ],
          child: buildTestApp(home: const FolderDetailScreen(folderId: 1)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Create subfolder'), findsOneWidget);
      expect(find.text('Create subfolder'), findsNothing);
      expect(find.text('Create deck'), findsNothing);
      expect(find.byType(TopBarBackButton), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    },
  );

  testWidgets('shows deck edit and delete actions when folder contains decks', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          folderRepositoryProvider.overrideWithValue(
            FakeFolderRepository(
              folders: const [
                FolderEntity(id: 1, name: 'Root'),
                FolderEntity(id: 2, name: 'Languages', parentId: 1),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(
              decks: const [
                DeckEntity(
                  id: 3,
                  name: 'Korean Core',
                  folderId: 2,
                  description: 'First 50 phrases',
                ),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
        ],
        child: buildTestApp(home: const FolderDetailScreen(folderId: 2)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Korean Core'), findsOneWidget);
    expect(find.text('First 50 phrases'), findsOneWidget);
    expect(find.byTooltip('Reorder'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete deck'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Reorder'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Done'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.text('Drag items to change their order.'), findsOneWidget);
  });
}
