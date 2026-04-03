import 'package:memox/core/database/app_database.dart';

abstract interface class DeckLocalDataSource {
  Stream<List<DecksTableData>> watchAll();

  Stream<List<DecksTableData>> watchByFolder(int folderId);

  Future<List<DecksTableData>> getAll();

  Future<List<DecksTableData>> getByFolder(int folderId);

  Future<DecksTableData?> getById(int id);

  Future<List<int>> getIdsByFolderIds(List<int> folderIds);

  Future<int> getNextSortOrder(int folderId);

  Future<void> reorder(int folderId, List<int> deckIds);

  Future<void> deleteByFolderIds(List<int> folderIds);

  Future<DecksTableData> save(DecksTableCompanion companion);

  Future<void> delete(int id);
}

final class DeckLocalDataSourceImpl implements DeckLocalDataSource {
  const DeckLocalDataSourceImpl(this._deckDao);

  final DeckDao _deckDao;

  @override
  Future<void> delete(int id) => _deckDao.deleteById(id);

  @override
  Future<void> deleteByFolderIds(List<int> folderIds) => _deckDao.deleteByFolderIds(folderIds);

  @override
  Future<List<DecksTableData>> getAll() => _deckDao.getAll();

  @override
  Future<List<DecksTableData>> getByFolder(int folderId) => _deckDao.getByFolder(folderId);

  @override
  Future<DecksTableData?> getById(int id) => _deckDao.getById(id);

  @override
  Future<List<int>> getIdsByFolderIds(List<int> folderIds) => _deckDao.getIdsByFolderIds(folderIds);

  @override
  Future<int> getNextSortOrder(int folderId) => _deckDao.getNextSortOrder(folderId);

  @override
  Future<void> reorder(int folderId, List<int> deckIds) => _deckDao.reorder(folderId, deckIds);

  @override
  Future<DecksTableData> save(DecksTableCompanion companion) async {
    final insertedId = await _deckDao.insertDeck(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _deckDao.getById(targetId);
    return saved!;
  }

  @override
  Stream<List<DecksTableData>> watchAll() => _deckDao.watchAll();

  @override
  Stream<List<DecksTableData>> watchByFolder(int folderId) => _deckDao.watchByFolder(folderId);
}
