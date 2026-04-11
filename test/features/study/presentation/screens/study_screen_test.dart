import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/providers/study_entry_provider.dart';
import 'package:memox/features/study/presentation/providers/study_hub_provider.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('study screen renders empty hub state when nothing is ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('Study'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('study screen renders recommended study hub card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: [_dueReviewCard]),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Korean Basics'), findsOneWidget);
    expect(find.text('Start with Review in Korean Basics'), findsOneWidget);
  });

  testWidgets('study screen surfaces active session on the hub', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        ActiveStudySessionSnapshot(
          deckId: 3,
          mode: StudyMode.review,
          session: StudySession(
            id: 1,
            deckId: 3,
            startedAt: DateTime(2026, 4, 3, 10),
          ),
          payload: <String, dynamic>{
            'cards': <Map<String, dynamic>>[_singleCard.toJson()],
            'results': const <Map<String, dynamic>>[],
          },
        ).toJson(),
      ),
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Resume current mode?'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets(
    'study screen tolerates malformed active-session payload on the hub',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        'active_study_session_v1',
        jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 3,
            mode: StudyMode.review,
            session: StudySession(
              id: 11,
              deckId: 3,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: const <String, dynamic>{
              'cards': 'invalid',
              'results': 'invalid',
            },
          ).toJson(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(),
            ),
          ],
          child: buildTestApp(home: const StudyScreen()),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    },
  );

  testWidgets('study screen ignores stale active sessions on the hub', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        const ActiveStudySessionSnapshot(
          deckId: 999,
          mode: StudyMode.review,
          session: StudySession(id: 2, deckId: 999),
          payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
        ).toJson(),
      ),
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: [_dueReviewCard]),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await _pumpStudyScreen(tester);

    final preferences = await SharedPreferences.getInstance();

    expect(find.text('Resume current mode?'), findsNothing);
    expect(find.text('Korean Basics'), findsOneWidget);
    expect(find.text('Start with Review in Korean Basics'), findsOneWidget);
    expect(preferences.getString('active_study_session_v1'), isNull);
  });

  testWidgets('study screen clears completed active sessions on the hub', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        const ActiveStudySessionSnapshot(
          deckId: 3,
          mode: StudyMode.review,
          session: StudySession(id: 13, deckId: 3),
          modeState: StudySessionModeState.completed,
          sessionCompleted: true,
          payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
        ).toJson(),
      ),
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: [_dueReviewCard]),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await _pumpStudyScreen(tester);

    final preferences = await SharedPreferences.getInstance();

    expect(find.text('Resume current mode?'), findsNothing);
    expect(find.text('Korean Basics'), findsOneWidget);
    expect(find.text('Start with Review in Korean Basics'), findsOneWidget);
    expect(preferences.getString('active_study_session_v1'), isNull);
  });

  testWidgets('study screen shows hub loading state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyHubProvider.overrideWithValue(
            const AsyncValue<StudyHubData>.loading(),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('study screen shows hub async errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyHubProvider.overrideWithValue(
            AsyncValue<StudyHubData>.error(
              Exception('hub failed'),
              StackTrace.empty,
            ),
          ),
        ],
        child: buildTestApp(home: const StudyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('hub failed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'study screen shows a loading indicator while direct entry is resolving',
    (tester) async {
      final resolution = Completer<StudyEntryResolution>();
      const request = (deckId: 3, mode: StudyMode.review);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyEntryProvider(
              request,
            ).overrideWith((ref) => resolution.future),
          ],
          child: buildTestApp(
            home: const StudyScreen(deckId: 3, mode: StudyMode.review),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(
        find.text('No cards are due in this deck right now.'),
        findsNothing,
      );

      resolution.complete(
        const StudyEntryResolution.nothingToStudy(
          deckId: 3,
          mode: StudyMode.review,
        ),
      );
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'study screen retries a failed direct entry resolution and then opens the mode',
    (tester) async {
      var shouldFail = true;
      const request = (deckId: 3, mode: StudyMode.match);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyEntryProvider(request).overrideWith((ref) async {
              if (shouldFail) {
                throw Exception('entry failed');
              }

              return const StudyEntryResolution.ready(
                deckId: 3,
                mode: StudyMode.match,
              );
            }),
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: const [_singleCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            matchEngineProvider(
              3,
            ).overrideWithValue(MatchEngine(random: Random(1))),
          ],
          child: buildTestApp(
            home: const StudyScreen(deckId: 3, mode: StudyMode.match),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('entry failed'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      shouldFail = false;
      await tester.tap(find.text('Try again'));
      await _pumpStudyScreen(tester);
      await _pumpStudyScreen(tester);

      expect(find.text('Match'), findsOneWidget);
      expect(find.text('안녕하세요'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'study screen requires an explicit decision when another session is active',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 7,
            mode: StudyMode.review,
            session: StudySession(
              id: 3,
              deckId: 7,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': <Map<String, dynamic>>[_singleCard.toJson()],
              'results': const <Map<String, dynamic>>[],
            },
          ).toJson(),
        ),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: const [_singleCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(
                decks: const [
                  _studyDeck,
                  DeckEntity(id: 7, name: 'Saved Session'),
                ],
              ),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            matchEngineProvider(
              3,
            ).overrideWithValue(MatchEngine(random: Random(1))),
          ],
          child: buildTestApp(
            home: const StudyScreen(deckId: 3, mode: StudyMode.match),
          ),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Another study session is still saved'), findsOneWidget);
      expect(find.text('Back to study hub'), findsOneWidget);
      expect(find.text('Discard and start new'), findsOneWidget);
      expect(find.text('안녕하세요'), findsNothing);

      await tester.tap(find.text('Discard and start new'));
      await _pumpStudyScreen(tester);
      await _pumpStudyScreen(tester);

      expect(find.text('Another study session is still saved'), findsNothing);
      expect(find.text('Match'), findsOneWidget);
      expect(find.text('안녕하세요'), findsOneWidget);
    },
  );

  testWidgets('study screen renders match mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            3,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.match),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(EmptyStateView), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('study screen renders review mode when requested', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.review),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(EmptyStateView), findsNothing);
  });

  testWidgets('study screen shows explicit refusal when nothing is due', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: [_notDueReviewCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.review),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(
      find.text('No cards are due in this deck right now.'),
      findsOneWidget,
    );
    expect(find.text('안녕하세요'), findsNothing);
  });

  testWidgets(
    'study screen resumes a matching snapshot even when no cards are due',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 3,
            mode: StudyMode.review,
            session: StudySession(
              id: 1,
              deckId: 3,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': <Map<String, dynamic>>[_notDueReviewCard.toJson()],
              'currentIndex': 0,
              'nextReviewTimes': const <String, String>{},
              'isFlipped': false,
              'results': const <Map<String, dynamic>>[],
            },
          ).toJson(),
        ),
      });

      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: [_notDueReviewCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          ],
          child: buildTestApp(
            home: const StudyScreen(deckId: 3, mode: StudyMode.review),
          ),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsOneWidget);
      expect(
        find.text('No cards are due in this deck right now.'),
        findsNothing,
      );
    },
  );

  testWidgets('study screen does not resume a completed matching snapshot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        ActiveStudySessionSnapshot(
          deckId: 3,
          mode: StudyMode.review,
          session: StudySession(
            id: 14,
            deckId: 3,
            startedAt: DateTime(2026, 4, 3, 10),
          ),
          modeState: StudySessionModeState.completed,
          sessionCompleted: true,
          payload: <String, dynamic>{
            'cards': <Map<String, dynamic>>[_notDueReviewCard.toJson()],
            'currentIndex': 0,
            'nextReviewTimes': const <String, String>{},
            'isFlipped': false,
            'results': const <Map<String, dynamic>>[],
          },
        ).toJson(),
      ),
    });

    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: [_notDueReviewCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.review),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    final preferences = await SharedPreferences.getInstance();

    expect(find.text('Resume current mode?'), findsNothing);
    expect(
      find.text('No cards are due in this deck right now.'),
      findsOneWidget,
    );
    expect(preferences.getString('active_study_session_v1'), isNull);
  });

  testWidgets(
    'study screen start over re-runs entry gating after a snapshot bypass',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 3,
            mode: StudyMode.review,
            session: StudySession(
              id: 1,
              deckId: 3,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': <Map<String, dynamic>>[_notDueReviewCard.toJson()],
              'currentIndex': 0,
              'nextReviewTimes': const <String, String>{},
              'isFlipped': false,
              'results': const <Map<String, dynamic>>[],
            },
          ).toJson(),
        ),
      });

      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: [_notDueReviewCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          ],
          child: buildTestApp(
            home: const StudyScreen(deckId: 3, mode: StudyMode.review),
          ),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsOneWidget);

      await tester.tap(find.text('Start over'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Resume current mode?'), findsNothing);
      expect(
        find.text('No cards are due in this deck right now.'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('study screen shows explicit refusal when the deck is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 999, mode: StudyMode.match),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Deck not found'), findsOneWidget);
    expect(
      find.text('This deck is no longer available for study.'),
      findsOneWidget,
    );
  });

  testWidgets('study screen renders guess mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            3,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.guess),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Guess'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(EmptyStateView), findsNothing);
  });

  testWidgets('study screen renders recall mode when requested', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(3).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.recall),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Recall'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(EmptyStateView), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('study screen renders fill mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: 'Water',
                  back: 'banana',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          fillRandomProvider(3).overrideWithValue(Random(1)),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.fill),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Fill'), findsOneWidget);
    expect(find.text('Complete the blank'), findsOneWidget);
    expect(find.byType(EmptyStateView), findsNothing);
  });

  testWidgets('study screen prompts to resume an active session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        ActiveStudySessionSnapshot(
          deckId: 3,
          mode: StudyMode.review,
          session: StudySession(
            id: 1,
            deckId: 3,
            startedAt: DateTime(2026, 4, 3, 10),
          ),
          payload: <String, dynamic>{
            'cards': <Map<String, dynamic>>[_singleCard.toJson()],
            'currentIndex': 0,
            'nextReviewTimes': const <String, String>{},
            'isFlipped': false,
            'results': const <Map<String, dynamic>>[
              <String, dynamic>{'cardId': 1, 'rating': 'good'},
            ],
          },
        ).toJson(),
      ),
    });

    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(
            FakeDeckRepository(decks: const [_studyDeck]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.review),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Resume current mode?'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);

    await tester.tap(find.text('Start over'));
    await _pumpStudyScreen(tester);

    expect(find.text('Resume current mode?'), findsNothing);
  });

  testWidgets(
    'study screen rechecks the resume prompt when the requested mode changes',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 3,
            mode: StudyMode.review,
            session: StudySession(
              id: 1,
              deckId: 3,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': <Map<String, dynamic>>[_singleCard.toJson()],
              'currentIndex': 0,
              'nextReviewTimes': const <String, String>{},
              'isFlipped': false,
              'results': const <Map<String, dynamic>>[],
            },
          ).toJson(),
        ),
      });

      final route = ValueNotifier<({int deckId, StudyMode mode})>((
        deckId: 3,
        mode: StudyMode.guess,
      ));
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      addTearDown(route.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: [_dueReviewCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            guessEngineProvider(
              3,
            ).overrideWithValue(GuessEngine(random: Random(1))),
          ],
          child: buildTestApp(home: _SwappableStudyScreenHost(route: route)),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsNothing);

      route.value = (deckId: 3, mode: StudyMode.review);
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsOneWidget);
    },
  );

  testWidgets('study screen ignores resume probe failures', (tester) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        ActiveStudySessionSnapshot(
          deckId: 3,
          mode: StudyMode.match,
          session: StudySession(
            id: 15,
            deckId: 3,
            startedAt: DateTime(2026, 4, 3, 10),
          ),
          payload: <String, dynamic>{
            'cards': <Map<String, dynamic>>[_singleCard.toJson()],
            'currentIndex': 0,
          },
        ).toJson(),
      ),
    });

    const request = (deckId: 3, mode: StudyMode.match);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(_ThrowingDeckRepository()),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          studyEntryProvider(request).overrideWith(
            (ref) async => const StudyEntryResolution.ready(
              deckId: 3,
              mode: StudyMode.match,
            ),
          ),
          matchEngineProvider(
            3,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.match),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Resume current mode?'), findsNothing);
    expect(find.text('Match'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'study screen offers resume after leaving an in-progress session',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: const [_singleCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          ],
          child: buildTestApp(
            home: const _StudyRouteHost(
              child: StudyScreen(deckId: 3, mode: StudyMode.review),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Exit'));
      await _pumpStudyScreen(tester);
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('active_study_session_v1'), isNotNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: const [_singleCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          ],
          child: buildTestApp(
            home: const StudyScreen(deckId: 3, mode: StudyMode.review),
          ),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsOneWidget);
    },
  );

  testWidgets(
    'study hub updates when a mode saves a resumable snapshot in the same container',
    (tester) async {
      final route = ValueNotifier<({int? deckId, StudyMode? mode})>((
        deckId: null,
        mode: null,
      ));
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      addTearDown(route.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: const [_singleCard]),
            ),
            deckRepositoryProvider.overrideWithValue(
              FakeDeckRepository(decks: const [_studyDeck]),
            ),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          ],
          child: buildTestApp(home: _NullableStudyScreenHost(route: route)),
        ),
      );
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsNothing);
      expect(find.text('Korean Basics'), findsOneWidget);

      route.value = (deckId: 3, mode: StudyMode.review);
      await _pumpStudyScreen(tester);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('active_study_session_v1'), isNotNull);

      route.value = (deckId: null, mode: null);
      await _pumpStudyScreen(tester);

      expect(find.text('Resume current mode?'), findsOneWidget);
    },
  );
}

const FlashcardEntity _singleCard = FlashcardEntity(
  id: 1,
  deckId: 3,
  front: '안녕하세요',
  back: 'Hello',
);

final FlashcardEntity _dueReviewCard = _singleCard.copyWith(
  id: 11,
  front: '감사합니다',
  back: 'Thank you',
  status: CardStatus.reviewing,
  nextReviewDate: DateTime(2026, 4),
);

final FlashcardEntity _notDueReviewCard = _singleCard.copyWith(
  id: 12,
  front: '잘 가요',
  back: 'Goodbye',
  status: CardStatus.reviewing,
  nextReviewDate: DateTime(2026, 5),
);

const DeckEntity _studyDeck = DeckEntity(id: 3, name: 'Korean Basics');

final class _FakeStudyRepository implements StudyRepository {
  @override
  Future<StudySession> completeSession(StudySession session) async => session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(
    id: 1,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}

final class _ThrowingDeckRepository extends FakeDeckRepository {
  _ThrowingDeckRepository();

  @override
  Future<DeckEntity?> getById(int id) async {
    throw StateError('deck probe failed');
  }
}

Future<void> _pumpStudyScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

class _StudyRouteHost extends StatefulWidget {
  const _StudyRouteHost({required this.child});

  final Widget child;

  @override
  State<_StudyRouteHost> createState() => _StudyRouteHostState();
}

class _StudyRouteHostState extends State<_StudyRouteHost> {
  var _didPush = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPush) {
      return;
    }

    _didPush = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => widget.child)),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SwappableStudyScreenHost extends StatelessWidget {
  const _SwappableStudyScreenHost({required this.route});

  final ValueNotifier<({int deckId, StudyMode mode})> route;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<({int deckId, StudyMode mode})>(
        valueListenable: route,
        builder: (context, value, child) =>
            StudyScreen(deckId: value.deckId, mode: value.mode),
      );
}

class _NullableStudyScreenHost extends StatelessWidget {
  const _NullableStudyScreenHost({required this.route});

  final ValueNotifier<({int? deckId, StudyMode? mode})> route;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<({int? deckId, StudyMode? mode})>(
        valueListenable: route,
        builder: (context, value, child) =>
            StudyScreen(deckId: value.deckId, mode: value.mode),
      );
}
