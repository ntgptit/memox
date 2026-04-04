import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/folders/presentation/widgets/folder_detail_app_bar_title.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';
import 'package:memox/shared/widgets/navigation/top_bar_back_button.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('shows loading indicator while folder detail loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          folderRepositoryProvider.overrideWithValue(
            _DelayedFolderRepository(
              folders: const [
                FolderEntity(id: 1, name: 'Root'),
                FolderEntity(id: 2, name: 'Korean1', parentId: 1),
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
        child: buildTestApp(home: const FolderDetailScreen(folderId: 2)),
      ),
    );
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);
    expect(find.byType(TopBarBackButton), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Korean1'), findsWidgets);
  });

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
      expect(
        find.text(
          'This folder already contains subfolders. '
          'Create another subfolder here.',
        ),
        findsNothing,
      );
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
    expect(find.byType(BreadcrumbBar), findsOneWidget);
    expect(find.textContaining('Contains'), findsNothing);
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
    expect(find.byIcon(Icons.check_outlined), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.text('Drag items to change their order.'), findsOneWidget);
    final deckCard = find
        .ancestor(of: find.text('Korean Core'), matching: find.byType(AppCard))
        .first;
    expect(
      find.descendant(
        of: deckCard,
        matching: find.byIcon(Icons.drag_indicator_outlined),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'This folder already contains decks. Create another deck here.',
      ),
      findsNothing,
    );
  });

  testWidgets('keeps folder detail title close to the shared back slot', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          folderRepositoryProvider.overrideWithValue(
            FakeFolderRepository(
              folders: const [
                FolderEntity(id: 1, name: 'Root'),
                FolderEntity(id: 2, name: 'Korean1', parentId: 1),
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
        child: buildTestApp(home: const FolderDetailScreen(folderId: 2)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Korean1')),
      findsNothing,
    );
    final bodyTitle = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Korean1' &&
          widget.style?.fontSize == TypographyTokens.headlineMedium,
    );
    final titleRect = tester.getRect(
      find.descendant(of: find.byType(FolderDetailHeader), matching: bodyTitle),
    );
    final breadcrumbRect = tester.getRect(find.text('Home'));

    expect(titleRect.left, closeTo(breadcrumbRect.left, 0.01));
  });

  testWidgets('shows depth warning only for deep folder hierarchies', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          folderRepositoryProvider.overrideWithValue(
            FakeFolderRepository(
              folders: const [
                FolderEntity(id: 1, name: 'Root'),
                FolderEntity(id: 2, name: 'A', parentId: 1),
                FolderEntity(id: 3, name: 'B', parentId: 2),
                FolderEntity(id: 4, name: 'C', parentId: 3),
                FolderEntity(id: 5, name: 'Deep', parentId: 4),
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
        child: buildTestApp(home: const FolderDetailScreen(folderId: 5)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This folder is 5 levels deep. Consider simplifying the hierarchy.',
      ),
      findsOneWidget,
    );
  });
}

class _DelayedFolderRepository extends FakeFolderRepository {
  _DelayedFolderRepository({super.folders});

  @override
  Stream<FolderEntity?> watchById(int id) async* {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    yield await getById(id);
  }
}
