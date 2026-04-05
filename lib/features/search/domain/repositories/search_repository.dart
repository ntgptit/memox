import 'package:memox/features/search/domain/entities/search_query.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';

abstract interface class SearchRepository {
  Future<List<SearchResultItem>> search(SearchQuery query);
}
