import 'package:isar/isar.dart';

part 'statistics_snapshot_model.g.dart';

@collection
class StatisticsSnapshotModel {
  StatisticsSnapshotModel({
    this.id = Isar.autoIncrement,
    this.totalReviews = 0,
  });

  Id id;
  int totalReviews;
}
