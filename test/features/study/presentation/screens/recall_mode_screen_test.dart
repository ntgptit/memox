import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/screens/recall_mode_screen.dart';
import 'package:memox/features/study/presentation/widgets/recall_prompt_card.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('RecallModeScreen cannot reveal without typing', (tester) async {
    await _setCompactSurface(tester);
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(1)),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(4).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

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
    expect(
      find.widgetWithText(SecondaryButton, 'Show answer'),
      findsOneWidget,
    );
    expect(tester.getTopLeft(find.byType(TextField)).dy, lessThan(800 * 0.7));

    await tester.tap(find.text('Show answer'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Complete answer'), findsNothing);

    await tester.enterText(find.byType(TextField), 'I remember this');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show answer'));
    await tester.pumpAndSettle();

    expect(find.text('Complete answer'), findsOneWidget);
    expect(find.text('Term 1'), findsOneWidget);
    expect(find.text('How well did you recall?'), findsOneWidget);
  });

  testWidgets('RecallModeScreen can restart with missed cards', (tester) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(1)),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(4).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Wrong answer');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Missed'));
    await tester.pumpAndSettle();

    expect(find.text('1 cards recalled'), findsOneWidget);
    expect(find.text('Review missed cards'), findsOneWidget);

    await tester.tap(find.text('Review missed cards'));
    await tester.pumpAndSettle();

    expect(find.text('Definition 1'), findsOneWidget);
    expect(find.text('Review missed cards'), findsNothing);
  });

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
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(4).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const RecallModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(RecallPromptCard)).height,
      lessThanOrEqualTo(800 * 0.4),
    );
    expect(
      find.widgetWithText(SecondaryButton, 'Show answer'),
      findsOneWidget,
    );
  });
}

Future<void> _setCompactSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(360, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

List<FlashcardEntity> _cards(
  int count, {
  String? back,
}) => List<FlashcardEntity>.generate(
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
