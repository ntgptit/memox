import 'package:memox/features/search/domain/entities/search_query.dart';
import 'package:memox/features/search/domain/repositories/search_repository.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';

final class SearchItemsUseCase {
  const SearchItemsUseCase(this._repository);

  final SearchRepository _repository;

  Future<List<SearchResultItem>> call(String value) {
    final query = SearchQuery(value: value.trim());

    if (query.isEmpty) {
      return Future.value(const <SearchResultItem>[]);
    }

    return _repository.search(query);
  }
}
