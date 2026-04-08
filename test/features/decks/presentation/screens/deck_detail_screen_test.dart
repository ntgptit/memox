import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/presentation/widgets/card_list_tile.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/presentation/screens/deck_detail_screen.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/feedback/skeleton_parts.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('DeckDetailScreen shows skeleton loading while data loads', (
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
            _DelayedDeckRepository(
              decks: const [
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pump();

    expect(find.byType(SkeletonHeader), findsOneWidget);
    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.text('Korean Core'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Korean Core'), findsOneWidget);
  });

  testWidgets('DeckDetailScreen renders stats and cards', (tester) async {
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
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: [
                const FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
                FlashcardEntity(
                  id: 2,
                  deckId: 3,
                  front: '감사합니다',
                  back: 'Thank you',
                  status: CardStatus.mastered,
                  nextReviewDate: DateTime.now().add(const Duration(days: 1)),
                ),
              ],
            ),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(DeckDetailScreen));
    expect(find.text('Korean Core'), findsOneWidget);
    expect(find.text(context.l10n.studyDueCardsAction(1)), findsOneWidget);
    expect(find.text(context.l10n.deckCardsDueSubtitle(2, 1)), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text(context.l10n.cardsTitle), findsOneWidget);
    expect(find.text(context.l10n.searchCardsHint), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    await tester.tap(find.text('안녕하세요'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
    expect(find.byTooltip('Create card'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsWidgets);
    expect(find.byTooltip('Delete deck'), findsOneWidget);
  });

  testWidgets('DeckDetailScreen shows empty deck actions before card tools', (
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
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const []),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No cards yet'), findsOneWidget);
    expect(find.text('Add first card'), findsOneWidget);
    expect(find.text('Import batch'), findsOneWidget);
    expect(find.text('Cards'), findsNothing);
    expect(find.text('Search cards'), findsNothing);
  });

  testWidgets('DeckDetailScreen does not overflow on compact viewports', (
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
                FolderEntity(id: 2, name: 'Languages', parentId: 1),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(
              decks: const [
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: [
                const FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
                FlashcardEntity(
                  id: 2,
                  deckId: 3,
                  front: '감사합니다',
                  back: 'Thank you',
                  status: CardStatus.mastered,
                  nextReviewDate: DateTime.now().add(const Duration(days: 1)),
                ),
              ],
            ),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(DeckDetailScreen));
    expect(tester.takeException(), isNull);
    expect(find.text('Korean Core'), findsWidgets);
    expect(find.text(context.l10n.studyDueCardsAction(1)), findsOneWidget);
  });

  testWidgets('DeckDetailScreen loads more cards while scrolling', (
    tester,
  ) async {
    final cards = List.generate(
      25,
      (index) => FlashcardEntity(
        id: index + 1,
        deckId: 3,
        front: 'Card ${index + 1}',
        back: 'Back ${index + 1}',
      ),
    );

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
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: cards),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(
      find.text('Card 25'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Card 25'), findsOneWidget);
  });

  testWidgets('DeckDetailScreen keeps breathing room below the cards toolbar', (
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
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: 'First card',
                  back: 'First back',
                ),
                FlashcardEntity(
                  id: 2,
                  deckId: 3,
                  front: 'Second card',
                  back: 'Second back',
                ),
              ],
            ),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final searchBarRect = tester.getRect(find.byType(AppSearchBar));
    final firstCardRect = tester.getRect(
      find.descendant(
        of: find.byType(CardListTile).first,
        matching: find.byType(AppCard),
      ),
    );

    expect(
      firstCardRect.top - searchBarRect.bottom,
      closeTo(SpacingTokens.sm, 0.01),
    );
    expect(find.byTooltip('Flagged'), findsNothing);
  });

  testWidgets('DeckDetailScreen keeps the last card above the fab', (
    tester,
  ) async {
    final cards = List.generate(
      12,
      (index) => FlashcardEntity(
        id: index + 1,
        deckId: 3,
        front: 'Card ${index + 1}',
        back: 'Back ${index + 1}',
      ),
    );

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
                DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: cards),
          ),
        ],
        child: buildTestApp(home: const DeckDetailScreen(deckId: 3)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Card 12'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final lastCardRect = tester.getRect(
      find.descendant(
        of: find.byType(CardListTile).last,
        matching: find.byType(AppCard),
      ),
    );
    final fabRect = tester.getRect(find.byType(FloatingActionButton));

    expect(fabRect.top - lastCardRect.bottom, closeTo(SpacingTokens.lg, 0.01));
  });
}

class _DelayedDeckRepository extends FakeDeckRepository {
  _DelayedDeckRepository({super.decks});

  @override
  Stream<DeckEntity?> watchById(int id) async* {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    yield await getById(id);
  }
}
