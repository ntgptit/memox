import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/statistics/domain/usecases/get_mastery_breakdown.dart';
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

  test('counts current card mastery buckets', () async {
    final repository = harness.createRepository();
    final useCase = GetMasteryBreakdownUseCase(repository);
    await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'Known',
      back: 'A',
      status: CardStatus.mastered,
    );
    await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'Learning',
      back: 'B',
      status: CardStatus.reviewing,
    );
    await harness.insertCard(
      deckId: harness.primaryDeckId,
      front: 'New',
      back: 'C',
    );

    final mastery = await useCase.call();

    expect(mastery.known, 1);
    expect(mastery.learning, 1);
    expect(mastery.newCards, 1);
    expect(mastery.total, 3);
  });
}
