import 'package:isar/isar.dart';
import 'package:memox/features/statistics/data/models/statistics_snapshot_model.dart';

abstract interface class StatisticsLocalDataSource {
  Stream<List<StatisticsSnapshotModel>> watchAll();

  Future<StatisticsSnapshotModel> save(StatisticsSnapshotModel model);
}

final class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  const StatisticsLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<StatisticsSnapshotModel> save(StatisticsSnapshotModel model) async {
    return _isar.writeTxn(() async {
      final savedId = await _isar.statisticsSnapshotModels.put(model);
      model.id = savedId;
      return model;
    });
  }

  @override
  Stream<List<StatisticsSnapshotModel>> watchAll() {
    return _isar.statisticsSnapshotModels.where().watch(fireImmediately: true);
  }
}
