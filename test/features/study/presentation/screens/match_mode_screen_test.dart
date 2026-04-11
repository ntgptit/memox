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
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/screens/match_mode_screen.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('MatchModeScreen renders the current round', (tester) async {
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
                  deckId: 4,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await _pumpMatchScreen(tester);

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('1 pair left'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);

    final termText = tester.widget<Text>(find.text('안녕하세요'));
    final definitionText = tester.widget<Text>(find.text('Hello'));
    expect(termText.style?.fontSize, TypographyTokens.headlineMedium);
    expect(definitionText.style?.fontSize, TypographyTokens.titleMedium);

    final termCard = find
        .ancestor(of: find.text('안녕하세요'), matching: find.byType(AppCard))
        .first;
    final definitionCard = find
        .ancestor(of: find.text('Hello'), matching: find.byType(AppCard))
        .first;
    final termRect = tester.getRect(termCard);
    final definitionRect = tester.getRect(definitionCard);

    expect(termRect.width, closeTo(definitionRect.width, 1));
    expect(termRect.height, closeTo(definitionRect.height, 1));
  });

  testWidgets('MatchModeScreen shows completion after a correct match', (
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
                  deckId: 4,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await _pumpMatchScreen(tester);

    await tester.tap(find.text('안녕하세요'));
    await tester.tap(find.text('Hello'));
    await _pumpMatchScreen(tester);

    expect(find.text('All matched!'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('MatchModeScreen keeps one-side selection without a hint', (
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
                  deckId: 4,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
                FlashcardEntity(
                  id: 2,
                  deckId: 4,
                  front: '감사합니다',
                  back: 'Thank you',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await _pumpMatchScreen(tester);

    await tester.tap(find.text('안녕하세요'));
    await _pumpMatchScreen(tester);

    expect(find.text('Tap the selected card again to clear it.'), findsNothing);
  });

  testWidgets(
    'MatchModeScreen continues to the next board instead of finishing early',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: _cards(6)),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            matchEngineProvider(
              4,
            ).overrideWithValue(MatchEngine(random: Random(1))),
          ],
          child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
        ),
      );
      await _pumpMatchScreen(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MatchModeScreen)),
      );

      expect(find.text('Board 1 of 2'), findsOneWidget);

      await _solveCurrentBoard(tester, container);

      expect(find.text('All matched!'), findsNothing);
      expect(find.text('Board 2 of 2'), findsOneWidget);
      expect(find.text('1 pair left'), findsOneWidget);
    },
  );

  testWidgets('MatchModeScreen completes after the final grouped board', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(6)),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await _pumpMatchScreen(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MatchModeScreen)),
    );

    await _solveCurrentBoard(tester, container);
    await _solveCurrentBoard(tester, container);

    expect(find.text('All matched!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'MatchModeScreen completion keeps mistake labels from earlier grouped boards',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: _cards(6)),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            matchEngineProvider(
              4,
            ).overrideWithValue(MatchEngine(random: Random(1))),
          ],
          child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
        ),
      );
      await _pumpMatchScreen(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MatchModeScreen)),
      );
      final firstBoardState = container
          .read(matchSessionProvider(4))
          .requireValue;
      final mistakenTerm = firstBoardState.game.terms.first;
      final correctDefinitionId =
          firstBoardState.game.correctPairs[mistakenTerm.id]!;
      final mistakenDefinition = firstBoardState.game.definitions.firstWhere(
        (item) => item.id != correctDefinitionId,
      );
      final expectedBack = firstBoardState.game.definitions
          .firstWhere((item) => item.id == correctDefinitionId)
          .text;

      await tester.tap(find.text(mistakenTerm.text).first);
      await tester.pump();
      await tester.tap(find.text(mistakenDefinition.text).first);
      await _pumpMatchScreen(tester);
      await _solveCurrentBoard(tester, container);
      await _solveCurrentBoard(tester, container);
      await tester.tap(find.byType(TextLinkButton));
      await tester.pumpAndSettle();

      expect(find.text(mistakenTerm.text), findsOneWidget);
      expect(find.text(expectedBack), findsOneWidget);
      expect(find.text(mistakenTerm.id), findsNothing);
    },
  );

  testWidgets('MatchModeScreen truncates long definitions with ellipsis', (
    tester,
  ) async {
    const longDefinition =
        'Drowsy driving / Lái xe khi buồn ngủ '
        '(Danh từ, hành vi lái xe trong trạng thái buồn ngủ gây nguy hiểm)';
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
                  deckId: 4,
                  front: '졸음운전',
                  back: longDefinition,
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await _pumpMatchScreen(tester);

    final definitionText = tester.widget<Text>(find.text(longDefinition));

    expect(definitionText.maxLines, 4);
    expect(definitionText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('MatchModeScreen keeps the saved snapshot after exit', (
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
                  deckId: 4,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await _pumpMatchScreen(tester);
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

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 4,
    front: 'Term ${index + 1}',
    back: 'Definition ${index + 1}',
  ),
);

Future<void> _solveCurrentBoard(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final state = container.read(matchSessionProvider(4)).requireValue;

  for (final term in state.game.terms) {
    final definitionId = state.game.correctPairs[term.id]!;
    final definition = state.game.definitions.firstWhere(
      (item) => item.id == definitionId,
    );
    await tester.tap(find.text(term.text).first);
    await tester.pump();
    await tester.tap(find.text(definition.text).first);
    await _pumpMatchScreen(tester);
  }
}

Future<void> _pumpMatchScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}
