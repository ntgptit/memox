import 'package:memox/features/search/domain/entities/search_query.dart';

abstract interface class SearchRepository {
  Future<List<String>> search(SearchQuery query);
}
