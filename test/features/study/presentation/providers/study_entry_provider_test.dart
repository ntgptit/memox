import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_entry_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test(
    'non-review entry returns nothingToStudy when the deck has no cards',
    () async {
      final container = ProviderContainer(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [DeckEntity(id: 1, name: 'Deck')]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        studyEntryProvider((deckId: 1, mode: StudyMode.guess)).future,
      );

      expect(result.status, StudyEntryStatus.nothingToStudy);
    },
  );

  test(
    'non-review entry returns nothingToStudy when all cards are mastered',
    () async {
      final container = ProviderContainer(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [DeckEntity(id: 1, name: 'Deck')]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 1,
                  front: 'Front',
                  back: 'Back',
                  status: CardStatus.mastered,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        studyEntryProvider((deckId: 1, mode: StudyMode.guess)).future,
      );

      expect(result.status, StudyEntryStatus.nothingToStudy);
    },
  );

  test('review entry returns nothingToStudy when no cards are due', () async {
    final container = ProviderContainer(
      overrides: [
        deckRepositoryProvider.overrideWithValue(
          FakeDeckRepository(decks: const [DeckEntity(id: 1, name: 'Deck')]),
        ),
        flashcardRepositoryProvider.overrideWithValue(
          FakeFlashcardRepository(
            cards: [
              FlashcardEntity(
                id: 99,
                deckId: 1,
                front: 'Front',
                back: 'Back',
                status: CardStatus.reviewing,
                nextReviewDate: DateTime(2026, 5),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      studyEntryProvider((deckId: 1, mode: StudyMode.review)).future,
    );

    expect(result.status, StudyEntryStatus.nothingToStudy);
  });

  test('entry returns containerNotFound when the deck is missing', () async {
    final container = ProviderContainer(
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
        flashcardRepositoryProvider.overrideWithValue(
          FakeFlashcardRepository(cards: const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      studyEntryProvider((deckId: 999, mode: StudyMode.match)).future,
    );

    expect(result.status, StudyEntryStatus.containerNotFound);
  });

  test('matching saved snapshot is cleared when the deck is missing', () async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        const ActiveStudySessionSnapshot(
          deckId: 999,
          mode: StudyMode.match,
          session: StudySession(id: 12, deckId: 999),
          payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
        ).toJson(),
      ),
    });
    final container = ProviderContainer(
      overrides: [
        deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
        flashcardRepositoryProvider.overrideWithValue(
          FakeFlashcardRepository(cards: const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      studyEntryProvider((deckId: 999, mode: StudyMode.match)).future,
    );
    final store = await container.read(activeStudySessionStoreProvider.future);

    expect(result.status, StudyEntryStatus.containerNotFound);
    expect(store.load(), isNull);
  });

  test('matching saved snapshot bypasses eligibility refusal', () async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        const ActiveStudySessionSnapshot(
          deckId: 1,
          mode: StudyMode.review,
          session: StudySession(id: 7, deckId: 1),
          payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
        ).toJson(),
      ),
    });
    final container = ProviderContainer(
      overrides: [
        deckRepositoryProvider.overrideWithValue(
          FakeDeckRepository(decks: const [DeckEntity(id: 1, name: 'Deck')]),
        ),
        flashcardRepositoryProvider.overrideWithValue(
          FakeFlashcardRepository(
            cards: [
              FlashcardEntity(
                id: 99,
                deckId: 1,
                front: 'Front',
                back: 'Back',
                status: CardStatus.reviewing,
                nextReviewDate: DateTime(2026, 5),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      studyEntryProvider((deckId: 1, mode: StudyMode.review)).future,
    );

    expect(result.status, StudyEntryStatus.ready);
  });

  test(
    'different saved snapshot returns activeSessionConflict when it is still valid',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          const ActiveStudySessionSnapshot(
            deckId: 2,
            mode: StudyMode.review,
            session: StudySession(id: 8, deckId: 2),
            payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
          ).toJson(),
        ),
      });
      final container = ProviderContainer(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(
              decks: const [
                DeckEntity(id: 1, name: 'Requested'),
                DeckEntity(id: 2, name: 'Saved'),
              ],
            ),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(id: 1, deckId: 1, front: 'Front', back: 'Back'),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        studyEntryProvider((deckId: 1, mode: StudyMode.guess)).future,
      );

      expect(result.status, StudyEntryStatus.activeSessionConflict);
      expect(result.activeDeckName, 'Saved');
      expect(result.activeSession?.deckId, 2);
      expect(result.activeSession?.mode, StudyMode.review);
    },
  );

  test(
    'stale saved snapshot is cleared before a new entry is resolved',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          const ActiveStudySessionSnapshot(
            deckId: 2,
            mode: StudyMode.review,
            session: StudySession(id: 9, deckId: 2),
            payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
          ).toJson(),
        ),
      });
      final container = ProviderContainer(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [DeckEntity(id: 1, name: 'Deck')]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(id: 1, deckId: 1, front: 'Front', back: 'Back'),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        studyEntryProvider((deckId: 1, mode: StudyMode.guess)).future,
      );
      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );

      expect(result.status, StudyEntryStatus.ready);
      expect(store.load(), isNull);
    },
  );

  test('completed saved snapshot is ignored during entry resolution', () async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        const ActiveStudySessionSnapshot(
          deckId: 2,
          mode: StudyMode.review,
          session: StudySession(id: 10, deckId: 2),
          modeState: StudySessionModeState.completed,
          sessionCompleted: true,
          payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
        ).toJson(),
      ),
    });
    final container = ProviderContainer(
      overrides: [
        deckRepositoryProvider.overrideWithValue(
          FakeDeckRepository(
            decks: const [
              DeckEntity(id: 1, name: 'Requested'),
              DeckEntity(id: 2, name: 'Completed'),
            ],
          ),
        ),
        flashcardRepositoryProvider.overrideWithValue(
          FakeFlashcardRepository(
            cards: const [
              FlashcardEntity(id: 1, deckId: 1, front: 'Front', back: 'Back'),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      studyEntryProvider((deckId: 1, mode: StudyMode.guess)).future,
    );
    final store = await container.read(activeStudySessionStoreProvider.future);

    expect(result.status, StudyEntryStatus.ready);
    expect(store.load(), isNull);
  });

  test('corrupted saved snapshot is ignored during entry resolution', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('active_study_session_v1', '{bad-json');
    final container = ProviderContainer(
      overrides: [
        deckRepositoryProvider.overrideWithValue(
          FakeDeckRepository(decks: const [DeckEntity(id: 1, name: 'Deck')]),
        ),
        flashcardRepositoryProvider.overrideWithValue(
          FakeFlashcardRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      studyEntryProvider((deckId: 1, mode: StudyMode.guess)).future,
    );

    expect(result.status, StudyEntryStatus.nothingToStudy);
  });
}
