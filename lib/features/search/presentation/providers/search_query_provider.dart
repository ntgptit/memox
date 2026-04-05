import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_query_provider.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void update(String value) {
    state = value;
  }
}

@riverpod
Future<List<SearchResultItem>> searchResults(Ref ref) {
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return Future.value(const <SearchResultItem>[]);
  }

  return ref.watch(searchItemsUseCaseProvider).call(query);
}
