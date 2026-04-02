import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/search/domain/entities/search_query.dart';
import 'package:memox/features/search/domain/repositories/search_repository.dart';
import 'package:memox/features/search/domain/usecases/search_items.dart';

void main() {
  test(
    'search items use case trims query and delegates to repository',
    () async {
      final repository = _FakeSearchRepository();
      final useCase = SearchItemsUseCase(repository);

      final result = await useCase.call('  memo  ');

      expect(result, ['memo']);
      expect(repository.lastQuery, const SearchQuery(value: 'memo'));
    },
  );

  test('search items use case returns empty list for blank query', () async {
    final repository = _FakeSearchRepository();
    final useCase = SearchItemsUseCase(repository);

    final result = await useCase.call('   ');

    expect(result, isEmpty);
    expect(repository.lastQuery, isNull);
  });
}

final class _FakeSearchRepository implements SearchRepository {
  SearchQuery? lastQuery;

  @override
  Future<List<String>> search(SearchQuery query) async {
    lastQuery = query;
    return [query.value];
  }
}
