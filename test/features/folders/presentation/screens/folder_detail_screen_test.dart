import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
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
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    },
  );
}
