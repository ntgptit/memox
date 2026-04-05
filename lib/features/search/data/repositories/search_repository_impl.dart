import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/search/domain/entities/search_query.dart';
import 'package:memox/features/search/domain/repositories/search_repository.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';

final class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._searchDao);

  final SearchDao _searchDao;

  @override
  Future<List<SearchResultItem>> search(SearchQuery query) async {
    final term = query.value;
    final results = await Future.wait([
      _searchDao.searchFolders(term),
      _searchDao.searchDecks(term),
      _searchDao.searchCards(term),
    ]);

    return [
      ...results[0].map(
        (row) => FolderResult(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          parentName: row.readNullable<String>('parent_name'),
        ),
      ),
      ...results[1].map(
        (row) => DeckResult(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          folderName: row.readNullable<String>('folder_name'),
        ),
      ),
      ...results[2].map(
        (row) => CardResult(
          id: row.read<int>('id'),
          name: row.read<String>('front'),
          deckId: row.read<int>('deck_id'),
          back: row.read<String>('back'),
          deckName: row.readNullable<String>('deck_name'),
        ),
      ),
    ];
  }
}
