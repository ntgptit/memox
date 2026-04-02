import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/statistics/domain/entities/statistics_snapshot.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/statistics/domain/usecases/get_statistics_overview.dart';

void main() {
  test(
    'get statistics overview use case streams repository overview',
    () async {
      const expected = StatisticsSnapshot(id: 1, totalReviews: 42);
      final useCase = GetStatisticsOverviewUseCase(
        _FakeStatisticsRepository(expected),
      );

      final result = await useCase.call().first;

      expect(result, expected);
    },
  );
}

final class _FakeStatisticsRepository implements StatisticsRepository {
  const _FakeStatisticsRepository(this._snapshot);

  final StatisticsSnapshot _snapshot;

  @override
  Future<StatisticsSnapshot> save(StatisticsSnapshot snapshot) async =>
      snapshot;

  @override
  Stream<StatisticsSnapshot> watchOverview() async* {
    yield _snapshot;
  }
}
