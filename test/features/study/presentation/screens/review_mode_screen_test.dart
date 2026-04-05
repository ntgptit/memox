import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/screens/review_mode_screen.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('ReviewModeScreen reveals the answer and shows ratings', (
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
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Tap the card to reveal the answer'), findsOneWidget);
    expect(find.text('Term 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await tester.pumpAndSettle();

    expect(find.text('Definition 1'), findsOneWidget);
    expect(find.text('How well did you remember it?'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
  });

  testWidgets('ReviewModeScreen shows completion after rating the card', (
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
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<ReviewRating>(ReviewRating.good)));
    await tester.pumpAndSettle();

    expect(find.text('1 cards reviewed'), findsOneWidget);
    expect(find.text('Again: 0 · Hard: 0 · Good: 1 · Easy: 0'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('ReviewModeScreen shows empty state when no cards are due', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No cards are due in this deck right now.'),
      findsOneWidget,
    );
  });

  testWidgets('ReviewModeScreen advances through multiple cards', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(3)),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Term 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.good)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Term 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-2')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.again)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Term 3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-3')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.easy)),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 cards reviewed'), findsOneWidget);
    expect(
      find.text('Again: 1 · Hard: 0 · Good: 1 · Easy: 1'),
      findsOneWidget,
    );
  });
}

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 6,
    front: 'Term ${index + 1}',
    back: 'Definition ${index + 1}',
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
    id: 41,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 5, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
