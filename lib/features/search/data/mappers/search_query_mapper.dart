import 'package:memox/features/search/domain/entities/search_query.dart';

abstract final class SearchQueryMapper {
  const SearchQueryMapper._();

  static SearchQuery fromText(String value) => SearchQuery(value: value.trim());
}
