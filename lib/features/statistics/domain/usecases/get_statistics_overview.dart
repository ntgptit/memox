import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class GetStatisticsOverviewUseCase {
  const GetStatisticsOverviewUseCase(this._repository);

  final StatisticsRepository _repository;

  Stream<StatisticsSnapshot> call() => _repository.watchOverview();
}
