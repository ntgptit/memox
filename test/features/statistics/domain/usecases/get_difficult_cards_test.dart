import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/statistics/domain/usecases/get_difficult_cards.dart';
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

  test('returns cards ordered by lowest accuracy first', () async {
    final repository = harness.createRepository();
    final useCase = GetDifficultCardsUseCase(repository);
    final hardCard = await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'Hard',
      back: 'Answer',
    );
    final easyCard = await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'Easy',
      back: 'Answer',
    );
    final sessionId = await harness.insertSession(
      deckId: harness.primaryDeckId,
      mode: StudyMode.guess,
      completedAt: harness.now,
      totalCards: 4,
      durationSeconds: 300,
    );
    await harness.insertReview(
      cardId: hardCard,
      sessionId: sessionId,
      mode: StudyMode.guess,
      isCorrect: false,
      rating: ReviewRating.again.index,
    );
    await harness.insertReview(
      cardId: easyCard,
      sessionId: sessionId,
      mode: StudyMode.guess,
      isCorrect: true,
      rating: ReviewRating.good.index,
    );

    final cards = await useCase.call(range: DateRange.week);

    expect(cards.first.card.id, hardCard);
  });
}
