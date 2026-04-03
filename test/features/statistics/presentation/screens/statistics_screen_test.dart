import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/features/statistics/domain/entities/mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/entities/study_stats.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:memox/features/statistics/presentation/screens/statistics_screen.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('shows empty state when there is no study history', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsRepositoryProvider.overrideWithValue(
            _FakeStatisticsRepository(),
          ),
        ],
        child: buildTestApp(home: const StatisticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No study history yet'), findsOneWidget);
  });

  testWidgets('renders progress sections when stats exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsRepositoryProvider.overrideWithValue(
            _FakeStatisticsRepository(
              monthStats: _sampleStats(),
              allTimeStats: _sampleStats(),
            ),
          ),
        ],
        child: buildTestApp(home: const StatisticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Progress'), findsOneWidget);
    expect(find.text('Weekly activity'), findsOneWidget);
    expect(find.text('Mode usage'), findsOneWidget);
    expect(find.text('Cards to focus on'), findsOneWidget);
  });
}

StudyStats _sampleStats() => (
  streak: 5,
  cardsToday: 23,
  minutesToday: 18,
  weeklyActivity: List<DailyActivity>.generate(
    7,
    (index) => (
      date: DateTime(2026, 3, 30 + index),
      cardsStudied: index + 1,
      minutes: index + 2,
    ),
  ),
  mastery: (known: 12, learning: 4, newCards: 3, total: 19),
  modeUsage: {for (final mode in StudyMode.values) mode: 20},
  difficultCards: const <DifficultCard>[],
);

final class _FakeStatisticsRepository implements StatisticsRepository {
  _FakeStatisticsRepository({StudyStats? monthStats, StudyStats? allTimeStats})
    : _monthStats = monthStats ?? _emptyStats(),
      _allTimeStats = allTimeStats ?? _emptyStats();

  final StudyStats _monthStats;
  final StudyStats _allTimeStats;

  @override
  Future<List<DifficultCard>> getDifficultCards({
    required DateRange range,
    int limit = 5,
  }) async => _statsFor(range).difficultCards;

  @override
  Future<MasteryBreakdown> getMasteryBreakdown() async => _allTimeStats.mastery;

  @override
  Future<Map<StudyMode, double>> getModeUsage(DateRange range) async =>
      _statsFor(range).modeUsage;

  @override
  Future<int> getStreak() async => _allTimeStats.streak;

  @override
  Future<List<DailyActivity>> getWeeklyActivity() async =>
      _monthStats.weeklyActivity;

  StudyStats _statsFor(DateRange range) =>
      range == DateRange.allTime ? _allTimeStats : _monthStats;
}

StudyStats _emptyStats() => (
  streak: 0,
  cardsToday: 0,
  minutesToday: 0,
  weeklyActivity: List<DailyActivity>.generate(
    7,
    (index) =>
        (date: DateTime(2026, 3, 30 + index), cardsStudied: 0, minutes: 0),
  ),
  mastery: (known: 0, learning: 0, newCards: 0, total: 0),
  modeUsage: {for (final mode in StudyMode.values) mode: 0},
  difficultCards: const <DifficultCard>[],
);
