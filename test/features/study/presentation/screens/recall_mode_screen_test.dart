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
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/screens/recall_mode_screen.dart';
import 'package:memox/features/study/presentation/widgets/recall_prompt_card.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';
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

  testWidgets('RecallModeScreen can reveal without typing', (tester) async {
    await _setCompactSurface(tester);
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(1)),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(4).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
      ),
    );
    await _pumpRecallScreen(tester);

    expect(find.text('Recall'), findsOneWidget);
    expect(find.text('Show answer'), findsOneWidget);
    expect(find.text('Definition 1'), findsOneWidget);
    expect(find.text('Term 1'), findsNothing);
    expect(find.text('What do you know about:'), findsOneWidget);
    expect(find.text('WHAT DO YOU KNOW ABOUT:'), findsNothing);
    expect(
      tester.getSize(find.byType(RecallPromptCard)).height,
      lessThanOrEqualTo(800 * 0.4),
    );
    expect(find.widgetWithText(SecondaryButton, 'Show answer'), findsOneWidget);
    final promptRect = tester.getRect(find.byType(RecallPromptCard));
    final textFieldRect = tester.getRect(find.byType(TextField));
    expect(
      textFieldRect.top - promptRect.bottom,
      closeTo(SpacingTokens.lg, 0.01),
    );

    await tester.tap(find.text('Show answer'));
    await _pumpRecallScreen(tester);

    expect(find.text('Complete answer'), findsOneWidget);
    expect(find.text('Term 1'), findsOneWidget);
    expect(find.byType(IconActionButton), findsOneWidget);
    expect(find.text('How well did you recall?'), findsOneWidget);
    expect(find.text('Completely wrong or blank'), findsOneWidget);
    expect(find.text('All key points covered'), findsOneWidget);
    expect(
      find.text(
        'Green highlights match. Red highlights show missing or extra details.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'RecallModeScreen lets the learner mark a card as missed immediately',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: _cards(1)),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            recallRandomProvider(4).overrideWithValue(Random(1)),
            recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
          ],
          child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
        ),
      );
      await _pumpRecallScreen(tester);

      await tester.tap(find.text("I don't know"));
      await _pumpRecallScreen(tester);

      expect(find.text('1 cards recalled'), findsNothing);
      expect(find.text('Review difficult cards'), findsNothing);
      expect(find.text('Show answer'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'RecallModeScreen shows a retry hint before completing after a second miss',
    (tester) async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              FakeFlashcardRepository(cards: _cards(1)),
            ),
            deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
            studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
            cardReviewDaoProvider.overrideWithValue(cardReviewDao),
            recallRandomProvider(4).overrideWithValue(Random(1)),
            recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
          ],
          child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
        ),
      );
      await _pumpRecallScreen(tester);

      await tester.tap(find.text("I don't know"));
      await _pumpRecallScreen(tester);

      expect(
        find.text(
          'Retry round: revisit the cards that still need one more pass.',
        ),
        findsOneWidget,
      );
      expect(find.text('Done'), findsNothing);

      await tester.tap(find.text("I don't know"));
      await _pumpRecallScreen(tester);

      expect(find.text('Done'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('RecallModeScreen keeps long prompts under the writing-area cap', (
    tester,
  ) async {
    await _setCompactSurface(tester);
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: _cards(
                1,
                back:
                    'A long explanation that should wrap across several lines '
                    'without letting the prompt card dominate the full screen '
                    'height in recall mode.',
              ),
            ),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(4).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
      ),
    );
    await _pumpRecallScreen(tester);

    expect(
      tester.getSize(find.byType(RecallPromptCard)).height,
      lessThanOrEqualTo(800 * 0.4),
    );
    expect(find.widgetWithText(SecondaryButton, 'Show answer'), findsOneWidget);
  });

  testWidgets('RecallModeScreen keeps the saved snapshot after exit', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(1)),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(4).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
      ),
    );
    await _pumpRecallScreen(tester);
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

List<FlashcardEntity> _cards(int count, {String? back}) =>
    List<FlashcardEntity>.generate(
      count,
      (index) => FlashcardEntity(
        id: index + 1,
        deckId: 4,
        front: 'Term ${index + 1}',
        back: back ?? 'Definition ${index + 1}',
      ),
    );

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

Future<void> _pumpRecallScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
