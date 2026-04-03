import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/statistics/domain/usecases/get_difficult_cards.dart';
import 'package:memox/features/statistics/domain/usecases/get_mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/usecases/get_streak.dart';
import 'package:memox/features/statistics/domain/usecases/get_study_stats.dart';
import 'package:memox/features/statistics/domain/usecases/get_weekly_activity.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import '../../statistics_test_harness.dart';

void main() {
  late StatisticsTestHarness harness;

  setUp(() async {
    harness = StatisticsTestHarness(DateTime(2026, 4, 3, 9));
    await harness.seedBase();
  });

  tearDown(() async {
    await harness.dispose();
  });

  test('aggregates study stats from sessions, cards, and reviews', () async {
    final repository = harness.createRepository();
    final masteredCard = await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'Known',
      back: 'Answer',
      status: CardStatus.mastered,
    );
    final learningCard = await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'Learning',
      back: 'Answer',
      status: CardStatus.learning,
    );
    await harness.insertCard(
      deckId: harness.secondaryDeckId,
      front: 'New',
      back: 'Answer',
    );
    final guessSessionId = await harness.insertSession(
      deckId: harness.primaryDeckId,
      mode: StudyMode.guess,
      completedAt: harness.now,
      totalCards: 8,
      durationSeconds: 1080,
      correctCount: 6,
      wrongCount: 2,
    );
    final recallSessionId = await harness.insertSession(
      deckId: harness.primaryDeckId,
      mode: StudyMode.recall,
      completedAt: harness.now.subtract(const Duration(days: 1)),
      totalCards: 5,
      durationSeconds: 600,
      correctCount: 3,
      wrongCount: 2,
    );
    await harness.insertSession(
      deckId: harness.secondaryDeckId,
      mode: StudyMode.fill,
      completedAt: harness.now.subtract(const Duration(days: 20)),
      totalCards: 3,
      durationSeconds: 300,
      correctCount: 2,
      wrongCount: 1,
    );
    await harness.insertReview(
      cardId: masteredCard,
      sessionId: guessSessionId,
      mode: StudyMode.guess,
      isCorrect: false,
      rating: ReviewRating.again.index,
      reviewedAt: harness.now,
    );
    await harness.insertReview(
      cardId: masteredCard,
      sessionId: recallSessionId,
      mode: StudyMode.recall,
      isCorrect: false,
      rating: ReviewRating.again.index,
      reviewedAt: harness.now.subtract(const Duration(days: 1)),
    );
    await harness.insertReview(
      cardId: learningCard,
      sessionId: guessSessionId,
      mode: StudyMode.guess,
      isCorrect: true,
      rating: ReviewRating.good.index,
      reviewedAt: harness.now,
    );

    final useCase = GetStudyStatsUseCase(
      repository: repository,
      getStreakUseCase: GetStreakUseCase(repository),
      getWeeklyActivityUseCase: GetWeeklyActivityUseCase(repository),
      getMasteryBreakdownUseCase: GetMasteryBreakdownUseCase(repository),
      getDifficultCardsUseCase: GetDifficultCardsUseCase(repository),
      now: () => harness.now,
    );
    final stats = await useCase.call(DateRange.month);

    expect(stats.streak, 2);
    expect(stats.cardsToday, 8);
    expect(stats.minutesToday, 18);
    expect(stats.weeklyActivity, hasLength(7));
    expect(stats.mastery.total, 3);
    expect(stats.mastery.known, 1);
    expect(stats.mastery.learning, 1);
    expect(stats.mastery.newCards, 1);
    expect(stats.modeUsage[StudyMode.guess], closeTo(33.3, 0.2));
    expect(stats.modeUsage[StudyMode.recall], closeTo(33.3, 0.2));
    expect(stats.modeUsage[StudyMode.fill], closeTo(33.3, 0.2));
    expect(stats.difficultCards.first.card.id, masteredCard);
    expect(stats.difficultCards.first.accuracy, 0);
  });
}
