import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class GetWeeklyActivityUseCase {
  const GetWeeklyActivityUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<List<DailyActivity>> call() => _repository.getWeeklyActivity();
}
