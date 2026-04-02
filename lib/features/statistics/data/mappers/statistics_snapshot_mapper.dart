import 'package:isar/isar.dart';
import 'package:memox/features/statistics/data/models/statistics_snapshot_model.dart';
import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';

abstract final class StatisticsSnapshotMapper {
  static StatisticsSnapshot toEntity(StatisticsSnapshotModel model) {
    return StatisticsSnapshot(
      id: model.id,
      totalReviews: model.totalReviews,
    );
  }

  static StatisticsSnapshotModel toModel(StatisticsSnapshot entity) {
    return StatisticsSnapshotModel(
      id: entity.id > 0 ? entity.id : Isar.autoIncrement,
      totalReviews: entity.totalReviews,
    );
  }
}
