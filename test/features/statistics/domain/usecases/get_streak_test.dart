import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/statistics/domain/usecases/get_streak.dart';
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

  test(
    'counts consecutive completed study days backwards from today',
    () async {
      final repository = harness.createRepository();
      final useCase = GetStreakUseCase(repository);
      await harness.insertSession(
        deckId: harness.primaryDeckId,
        mode: StudyMode.guess,
        completedAt: harness.now,
        totalCards: 8,
        durationSeconds: 600,
      );
      await harness.insertSession(
        deckId: harness.primaryDeckId,
        mode: StudyMode.recall,
        completedAt: harness.now.subtract(const Duration(days: 1)),
        totalCards: 6,
        durationSeconds: 480,
      );
      await harness.insertSession(
        deckId: harness.primaryDeckId,
        mode: StudyMode.fill,
        completedAt: harness.now.subtract(const Duration(days: 2)),
        totalCards: 4,
        durationSeconds: 360,
      );

      expect(await useCase.call(), 3);
    },
  );

  test('returns zero when there is a gap before today', () async {
    final repository = harness.createRepository();
    final useCase = GetStreakUseCase(repository);
    await harness.insertSession(
      deckId: harness.primaryDeckId,
      mode: StudyMode.guess,
      completedAt: harness.now.subtract(const Duration(days: 1)),
      totalCards: 8,
      durationSeconds: 600,
    );

    expect(await useCase.call(), 0);
  });
}
