import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:memox/features/statistics/data/mappers/statistics_snapshot_mapper.dart';
import 'package:memox/features/statistics/data/models/statistics_snapshot_model.dart';
import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({
    required StatisticsLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _logger = logger;

  final StatisticsLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<StatisticsSnapshot> save(StatisticsSnapshot snapshot) async {
    _logger.info('Saving statistics snapshot ${snapshot.id}');
    final savedModel = await _localDataSource.save(
      StatisticsSnapshotMapper.toModel(snapshot),
    );
    return StatisticsSnapshotMapper.toEntity(savedModel);
  }

  @override
  Stream<StatisticsSnapshot> watchOverview() {
    return _localDataSource.watchAll().map((models) {
      if (models.isEmpty) {
        return StatisticsSnapshotMapper.toEntity(StatisticsSnapshotModel());
      }

      return StatisticsSnapshotMapper.toEntity(models.last);
    });
  }
}
