import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/screens/fill_mode_screen.dart';
import 'package:memox/features/study/presentation/widgets/fill_feedback_panel.dart';
import 'package:memox/features/study/presentation/widgets/fill_prompt_card.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('FillModeScreen shows close feedback actions', (tester) async {
    await _setCompactSurface(tester);
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards()),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          fillRandomProvider(5).overrideWithValue(Random(1)),
          fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
          fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const FillModeScreen(deckId: 5)),
      ),
    );
    await _pumpFillScreen(tester);

    expect(find.text('Fill'), findsOneWidget);
    expect(find.text('Show hint'), findsOneWidget);
    expect(find.textContaining('I ate a'), findsOneWidget);
    expect(find.textContaining('for breakfast.'), findsOneWidget);
    expect(find.text('Fruit 1'), findsNothing);
    expect(
      tester.getSize(find.byType(FillPromptCard)).height,
      lessThanOrEqualTo(800 * 0.35),
    );

    await tester.enterText(find.byType(TextField), 'banan');
    await _pumpFillScreen(tester);
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await _pumpFillScreen(tester);

    expect(find.text('Almost! Correct spelling:'), findsOneWidget);
    expect(
      find.text(
        'Your answer was close. Count it as correct, or retry to practice the exact spelling.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(SecondaryButton, 'Close enough'),
      findsOneWidget,
    );
    expect(find.text('Practice spelling'), findsOneWidget);
    expect(
      _feedbackTop(tester) - _inputBottom(tester),
      closeTo(SpacingTokens.lg, 1),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('FillModeScreen completes after a correct answer', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards()),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          fillRandomProvider(5).overrideWithValue(Random(1)),
          fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
          fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const FillModeScreen(deckId: 5)),
      ),
    );
    await _pumpFillScreen(tester);
    expect(find.textContaining('I ate a'), findsOneWidget);
    expect(find.textContaining('for breakfast.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'banana');
    await _pumpFillScreen(tester);
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await _pumpFillScreen(tester);

    expect(find.text('1 cards completed'), findsOneWidget);
    expect(find.text('1 correct first try (100%)'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'FillModeScreen shows hint and skip after the first wrong answer',
    (tester) async {
      await _setCompactSurface(tester);
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: _cards()),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            fillRandomProvider(5).overrideWithValue(Random(1)),
            fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
            fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
          ],
          child: buildTestApp(home: const FillModeScreen(deckId: 5)),
        ),
      );
      await _pumpFillScreen(tester);

      await tester.enterText(find.byType(TextField), 'apple');
      await _pumpFillScreen(tester);
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await _pumpFillScreen(tester);

      expect(
        find.text(
          'Retry round: revisit the cards that still need one more pass.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Hint:'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    },
  );

  testWidgets(
    'FillModeScreen completes retry remediation without a practice-only action',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: _cards()),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            fillRandomProvider(5).overrideWithValue(Random(1)),
            fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
            fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
          ],
          child: buildTestApp(home: const FillModeScreen(deckId: 5)),
        ),
      );
      await _pumpFillScreen(tester);

      await tester.enterText(find.byType(TextField), 'apple');
      await _pumpFillScreen(tester);
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await _pumpFillScreen(tester);
      await tester.tap(find.text('Skip for now'));
      await _pumpFillScreen(tester);

      expect(find.text('1 cards completed'), findsOneWidget);
      expect(find.text('Practice mistakes'), findsNothing);
    },
  );

  testWidgets('FillModeScreen warns when cards are missing example sentences', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cardsWithoutExamples()),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          fillRandomProvider(5).overrideWithValue(Random(1)),
          fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
          fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const FillModeScreen(deckId: 5)),
      ),
    );
    await _pumpFillScreen(tester);

    expect(
      find.text(
        'Fill mode works best with example sentences. 1 of 1 cards are missing one.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('FillModeScreen keeps the saved snapshot after exit', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards()),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          fillRandomProvider(5).overrideWithValue(Random(1)),
          fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
          fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const FillModeScreen(deckId: 5)),
      ),
    );
    await _pumpFillScreen(tester);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('active_study_session_v1'), isNotNull);

    await tester.tap(find.byTooltip('Exit'));
    await tester.pump();
    await tester.tap(find.text('Exit').last);
    await tester.pumpAndSettle();

    expect(preferences.getString('active_study_session_v1'), isNotNull);
  });
}

Future<void> _setCompactSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(360, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _pumpFillScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

double _feedbackTop(WidgetTester tester) =>
    tester.getTopLeft(find.byType(FillFeedbackPanel)).dy;

double _inputBottom(WidgetTester tester) =>
    tester.getBottomLeft(find.byType(TextField)).dy;

List<FlashcardEntity> _cards() => const [
  FlashcardEntity(
    id: 1,
    deckId: 5,
    front: 'banana',
    back: 'Fruit 1',
    example: 'I ate a banana for breakfast.',
  ),
];

List<FlashcardEntity> _cardsWithoutExamples() => const [
  FlashcardEntity(id: 1, deckId: 5, front: 'banana', back: 'Fruit 1'),
];

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
