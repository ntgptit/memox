import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class GetStreakUseCase {
  const GetStreakUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<int> call() => _repository.getStreak();
}
