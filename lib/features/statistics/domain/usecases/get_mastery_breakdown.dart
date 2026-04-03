import 'package:memox/features/statistics/domain/entities/mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class GetMasteryBreakdownUseCase {
  const GetMasteryBreakdownUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<MasteryBreakdown> call() => _repository.getMasteryBreakdown();
}
