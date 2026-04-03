import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/statistics/domain/entities/study_stats.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_stats_provider.g.dart';

typedef StatisticsScreenData = ({bool hasHistory, StudyStats stats});

@riverpod
Future<StatisticsScreenData> statisticsScreenData(
  Ref ref,
  DateRange range,
) async {
  final useCase = ref.watch(getStudyStatsUseCaseProvider);
  final stats = await useCase.call(range);

  if (range == DateRange.allTime) {
    return (hasHistory: _hasHistory(stats), stats: stats);
  }

  final allTimeStats = await useCase.call(DateRange.allTime);
  return (hasHistory: _hasHistory(allTimeStats), stats: stats);
}

bool _hasHistory(StudyStats stats) =>
    stats.modeUsage.values.any((value) => value > 0);
