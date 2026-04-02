import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';

abstract interface class StatisticsRepository {
  Stream<StatisticsSnapshot> watchOverview();

  Future<StatisticsSnapshot> save(StatisticsSnapshot snapshot);
}
