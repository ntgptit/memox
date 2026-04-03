import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/screens/match_mode_screen.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
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
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('1 pair left'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
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
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('안녕하세요'));
    await tester.tap(find.text('Hello'));
    await tester.pumpAndSettle();

    expect(find.text('All matched!'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
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
