import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/features/statistics/domain/entities/mastery_breakdown.dart';

typedef StudyStats = ({
  int streak,
  int cardsToday,
  int minutesToday,
  List<DailyActivity> weeklyActivity,
  MasteryBreakdown mastery,
  Map<StudyMode, double> modeUsage,
  List<DifficultCard> difficultCards,
});
