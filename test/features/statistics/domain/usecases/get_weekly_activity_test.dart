import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/statistics/domain/usecases/get_weekly_activity.dart';
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

  test('returns current week activity from monday to sunday', () async {
    final repository = harness.createRepository();
    final useCase = GetWeeklyActivityUseCase(repository);
    await harness.insertSession(
      deckId: harness.primaryDeckId,
      mode: StudyMode.guess,
      completedAt: DateTime(2026, 3, 30, 11),
      totalCards: 4,
      durationSeconds: 240,
    );
    await harness.insertSession(
      deckId: harness.primaryDeckId,
      mode: StudyMode.fill,
      completedAt: DateTime(2026, 4, 3, 11),
      totalCards: 8,
      durationSeconds: 600,
    );

    final activity = await useCase.call();

    expect(activity, hasLength(7));
    expect(activity.first.cardsStudied, 4);
    expect(activity[4].cardsStudied, 8);
    expect(activity[4].minutes, 10);
  });
}
