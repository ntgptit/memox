abstract interface class StatisticsLocalDataSource {
  Stream<int> watchTotalReviews();
}

final class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  const StatisticsLocalDataSourceImpl(this._watcher);

  final Stream<int> Function() _watcher;

  @override
  Stream<int> watchTotalReviews() => _watcher();
}
