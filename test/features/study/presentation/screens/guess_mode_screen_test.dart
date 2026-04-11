import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/screens/guess_mode_screen.dart';
import 'package:memox/features/study/presentation/widgets/guess_option_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('GuessModeScreen renders the current question', (tester) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);

    expect(find.text('Guess'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(
      find.text('Guess mode works best with 8+ cards. This deck only has 1.'),
      findsOneWidget,
    );

    final termText = tester.widget<Text>(find.text('안녕하세요'));
    expect(termText.style?.fontSize, TypographyTokens.headlineMedium);
  });

  testWidgets('GuessModeScreen shows completion after a correct answer', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
          guessAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);

    final optionButton = find
        .ancestor(
          of: find.text('안녕하세요'),
          matching: find.byType(GuessOptionButton),
        )
        .first;
    await tester.ensureVisible(optionButton);
    await tester.tap(optionButton);
    await _pumpGuessScreen(tester);

    expect(find.text('Guess complete'), findsOneWidget);
    expect(find.text('1/1 correct (100%)'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('GuessModeScreen shows continue affordance before auto-advance', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
          guessAutoAdvanceDelayProvider.overrideWith(
            (ref) => const Duration(milliseconds: 500),
          ),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);

    final optionButton = find
        .ancestor(
          of: find.text('안녕하세요'),
          matching: find.byType(GuessOptionButton),
        )
        .first;
    await tester.ensureVisible(optionButton);
    await tester.tap(optionButton);
    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Guess complete'), findsNothing);

    await tester.tap(find.text('Continue'));
    await _pumpGuessScreen(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpGuessScreen(tester);

    expect(find.text('Guess complete'), findsOneWidget);
  });

  testWidgets('GuessModeScreen advances when the answered screen is tapped', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
          guessAutoAdvanceDelayProvider.overrideWith(
            (ref) => const Duration(milliseconds: 500),
          ),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);

    final optionButton = find
        .ancestor(
          of: find.text('안녕하세요'),
          matching: find.byType(GuessOptionButton),
        )
        .first;
    await tester.ensureVisible(optionButton);
    await tester.tap(optionButton);
    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Hello'));
    await _pumpGuessScreen(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpGuessScreen(tester);

    expect(find.text('Guess complete'), findsOneWidget);
  });

  testWidgets(
    'GuessModeScreen explains the correct answer after a wrong guess',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(
                cards: const [
                  FlashcardEntity(
                    id: 1,
                    deckId: 5,
                    front: '안녕하세요',
                    back: 'Hello',
                    example: 'Use this when greeting politely.',
                    hint: 'Formal greeting',
                  ),
                ],
              ),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            guessEngineProvider(
              5,
            ).overrideWithValue(GuessEngine(random: Random(1))),
          ],
          child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
        ),
      );
      await _pumpGuessScreen(tester);

      final wrongOption = find
          .ancestor(
            of: find.text('???').first,
            matching: find.byType(GuessOptionButton),
          )
          .first;
      await tester.ensureVisible(wrongOption);
      await tester.tap(wrongOption);
      await _pumpGuessScreen(tester);

      expect(find.text('Correct answer'), findsOneWidget);
      expect(find.text('안녕하세요'), findsWidgets);
      expect(find.text('Example'), findsOneWidget);
      expect(find.text('Use this when greeting politely.'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Formal greeting'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    },
  );

  testWidgets('GuessModeScreen shows a retry hint when a card returns', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);

    final wrongOption = find
        .ancestor(
          of: find.text('???').first,
          matching: find.byType(GuessOptionButton),
        )
        .first;
    await tester.ensureVisible(wrongOption);
    await tester.tap(wrongOption);
    await _pumpGuessScreen(tester);
    await tester.tap(find.text('Continue'));
    await _pumpGuessScreen(tester);

    expect(
      find.text(
        'Retry round: revisit the cards that still need one more pass.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('GuessModeScreen lists difficult cards after a wrong answer', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);

    final wrongOption = find
        .ancestor(
          of: find.text('???').first,
          matching: find.byType(GuessOptionButton),
        )
        .first;
    await tester.ensureVisible(wrongOption);
    await tester.tap(wrongOption);
    await _pumpGuessScreen(tester);
    await tester.tap(find.text('Continue'));
    await _pumpGuessScreen(tester);
    final retryWrongOption = find
        .ancestor(
          of: find.text('???').first,
          matching: find.byType(GuessOptionButton),
        )
        .first;
    await tester.ensureVisible(retryWrongOption);
    await tester.tap(retryWrongOption);
    await _pumpGuessScreen(tester);
    await tester.tap(find.text('Continue'));
    await _pumpGuessScreen(tester);

    expect(find.text('Review difficult cards'), findsOneWidget);
  });

  testWidgets('GuessModeScreen keeps the saved snapshot after exit', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await _pumpGuessScreen(tester);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('active_study_session_v1'), isNotNull);

    await tester.tap(find.byTooltip('Exit'));
    await tester.pump();
    await tester.tap(find.text('Exit').last);
    await tester.pumpAndSettle();

    expect(preferences.getString('active_study_session_v1'), isNotNull);
  });
}

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

Future<void> _pumpGuessScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
