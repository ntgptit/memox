import 'package:memox/features/search/domain/entities/search_query.dart';
import 'package:memox/features/search/domain/repositories/search_repository.dart';

final class SearchItemsUseCase {
  const SearchItemsUseCase(this._repository);

  final SearchRepository _repository;

  Future<List<String>> call(String value) {
    final query = SearchQuery(value: value.trim());

    if (query.isEmpty) {
      return Future.value(const <String>[]);
    }

    return _repository.search(query);
  }
}
