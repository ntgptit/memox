import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/screens/review_mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

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
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Tap the card to reveal the answer'), findsOneWidget);
    expect(find.text('Term 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await _pumpReviewScreen(tester);

    expect(find.text('Definition 1'), findsOneWidget);
    expect(find.text('How well did you remember it?'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text("Didn't know"), findsOneWidget);
    expect(find.text('Instant'), findsOneWidget);
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
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await _pumpReviewScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.good)),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('1 cards reviewed'), findsOneWidget);
    expect(find.text('Again: 0 · Hard: 0 · Good: 1 · Easy: 0'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets(
    'ReviewModeScreen supports keyboard reveal and rating shortcuts',
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
          ],
          child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
        ),
      );
      await _pumpReviewScreen(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await _pumpReviewScreen(tester);
      expect(find.text('Definition 1'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await _pumpReviewScreen(tester);
      expect(find.text('1 cards reviewed'), findsOneWidget);
      expect(find.text('Review difficult cards'), findsOneWidget);
    },
  );

  testWidgets('ReviewModeScreen supports swipe-to-rate shortcuts', (
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
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await _pumpReviewScreen(tester);
    await tester.drag(
      find.byKey(const ValueKey<String>('review-back-1')),
      const Offset(200, 0),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('1 cards reviewed'), findsOneWidget);
    expect(find.text('Again: 0 · Hard: 0 · Good: 1 · Easy: 0'), findsOneWidget);
  });

  testWidgets('ReviewModeScreen shows undo after rating a card', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: _cards(2)),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await _pumpReviewScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.good)),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Term 2'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Undo'));
    await _pumpReviewScreen(tester);

    expect(find.text('Term 1'), findsOneWidget);
    expect(find.text('Definition 1'), findsOneWidget);
  });

  testWidgets('ReviewModeScreen toggles the flag action for the current card', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    final repository = FakeFlashcardRepository(cards: _cards(1));
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(repository),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

    expect(find.byTooltip('Flag card'), findsOneWidget);
    await tester.tap(find.byTooltip('Flag card'));
    await _pumpReviewScreen(tester);

    expect(find.text('Card flagged for later'), findsOneWidget);
    expect(find.byTooltip('Remove flag'), findsOneWidget);
    expect((await repository.getById(1))?.tags, contains(flaggedCardTag));
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
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

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
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(home: const ReviewModeScreen(deckId: 6)),
      ),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('Term 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-1')));
    await _pumpReviewScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.good)),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('Term 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-2')));
    await _pumpReviewScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.again)),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('Term 3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('review-front-3')));
    await _pumpReviewScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey<ReviewRating>(ReviewRating.easy)),
    );
    await _pumpReviewScreen(tester);

    expect(find.text('3 cards reviewed'), findsOneWidget);
    expect(find.text('Again: 1 · Hard: 0 · Good: 1 · Easy: 1'), findsOneWidget);
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

Future<void> _pumpReviewScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
