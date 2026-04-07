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
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
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
      find.widgetWithText(SecondaryButton, 'Accept anyway'),
      findsOneWidget,
    );
    expect(find.text('Mark as wrong'), findsOneWidget);
    expect(
      _feedbackTop(tester) - _inputBottom(tester),
      closeTo(SpacingTokens.lg, 1),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('FillModeScreen completes after a correct answer', (tester) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards()),
          ),
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
