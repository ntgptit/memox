import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/features/statistics/domain/entities/mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';

abstract interface class StatisticsRepository {
  Future<List<DifficultCard>> getDifficultCards({
    required DateRange range,
    int limit = 5,
  });

  Future<MasteryBreakdown> getMasteryBreakdown();

  Future<Map<StudyMode, double>> getModeUsage(DateRange range);

  Future<int> getStreak();

  Future<List<DailyActivity>> getWeeklyActivity();
}
