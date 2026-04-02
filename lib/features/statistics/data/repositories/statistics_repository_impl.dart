import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:memox/features/statistics/data/mappers/statistics_snapshot_mapper.dart';
import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({
    required StatisticsLocalDataSource localDataSource,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _logger = logger;

  final StatisticsLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<StatisticsSnapshot> save(StatisticsSnapshot snapshot) async {
    _logger.info('Statistics snapshot is derived from review history');
    return snapshot;
  }

  @override
  Stream<StatisticsSnapshot> watchOverview() {
    return _localDataSource.watchTotalReviews().map(
      StatisticsSnapshotMapper.fromTotalReviews,
    );
  }
}
