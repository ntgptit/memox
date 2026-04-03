import 'package:memox/core/utils/date_utils.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/domain/entities/study_stats.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/statistics/domain/usecases/get_difficult_cards.dart';
import 'package:memox/features/statistics/domain/usecases/get_mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/usecases/get_streak.dart';
import 'package:memox/features/statistics/domain/usecases/get_weekly_activity.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';

final class GetStudyStatsUseCase {
  const GetStudyStatsUseCase({
    required StatisticsRepository repository,
    required GetStreakUseCase getStreakUseCase,
    required GetWeeklyActivityUseCase getWeeklyActivityUseCase,
    required GetMasteryBreakdownUseCase getMasteryBreakdownUseCase,
    required GetDifficultCardsUseCase getDifficultCardsUseCase,
    DateTime Function()? now,
  }) : _repository = repository,
       _getStreakUseCase = getStreakUseCase,
       _getWeeklyActivityUseCase = getWeeklyActivityUseCase,
       _getMasteryBreakdownUseCase = getMasteryBreakdownUseCase,
       _getDifficultCardsUseCase = getDifficultCardsUseCase,
       _now = now ?? DateTime.now;

  final StatisticsRepository _repository;
  final GetStreakUseCase _getStreakUseCase;
  final GetWeeklyActivityUseCase _getWeeklyActivityUseCase;
  final GetMasteryBreakdownUseCase _getMasteryBreakdownUseCase;
  final GetDifficultCardsUseCase _getDifficultCardsUseCase;
  final DateTime Function() _now;

  Future<StudyStats> call(DateRange range) async {
    final streakFuture = _getStreakUseCase.call();
    final weeklyActivityFuture = _getWeeklyActivityUseCase.call();
    final masteryFuture = _getMasteryBreakdownUseCase.call();
    final modeUsageFuture = _repository.getModeUsage(range);
    final difficultCardsFuture = _getDifficultCardsUseCase.call(range: range);
    final weeklyActivity = await weeklyActivityFuture;
    final todayActivity = _todayActivity(weeklyActivity);

    return (
      streak: await streakFuture,
      cardsToday: todayActivity.cardsStudied,
      minutesToday: todayActivity.minutes,
      weeklyActivity: weeklyActivity,
      mastery: await masteryFuture,
      modeUsage: await modeUsageFuture,
      difficultCards: await difficultCardsFuture,
    );
  }

  DailyActivity _todayActivity(List<DailyActivity> weeklyActivity) {
    final today = AppDateUtils.startOfDay(_now());

    for (final activity in weeklyActivity) {
      if (AppDateUtils.isSameDay(activity.date, today)) {
        return activity;
      }
    }

    return (date: today, cardsStudied: 0, minutes: 0);
  }
}
