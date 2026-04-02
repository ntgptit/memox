import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';

abstract final class StatisticsSnapshotMapper {
  static StatisticsSnapshot fromTotalReviews(int totalReviews) {
    return StatisticsSnapshot(id: 1, totalReviews: totalReviews);
  }
}
