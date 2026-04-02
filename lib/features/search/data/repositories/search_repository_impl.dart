import 'package:memox/features/search/domain/entities/search_query.dart';
import 'package:memox/features/search/domain/repositories/search_repository.dart';

final class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl();

  @override
  Future<List<String>> search(SearchQuery query) async => const <String>[];
}
