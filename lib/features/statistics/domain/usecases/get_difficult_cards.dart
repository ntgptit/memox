import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';

final class GetDifficultCardsUseCase {
  const GetDifficultCardsUseCase(this._repository);

  final StatisticsRepository _repository;

  Future<List<DifficultCard>> call({
    DateRange range = DateRange.allTime,
    int limit = 5,
  }) => _repository.getDifficultCards(range: range, limit: limit);
}
