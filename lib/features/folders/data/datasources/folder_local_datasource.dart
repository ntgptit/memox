import 'package:memox/core/database/app_database.dart';

abstract interface class FolderLocalDataSource {
  Stream<List<FoldersTableData>> watchAll();

  Future<List<FoldersTableData>> getAll();

  Stream<List<FoldersTableData>> watchByParent(int? parentId);

  Future<List<FoldersTableData>> getByParent(int? parentId);

  Future<FoldersTableData?> getById(int id);

  Future<FoldersTableData> save(FoldersTableCompanion companion);

  Future<FoldersTableData> update({
    required int id,
    required String name,
    required int colorValue,
  });

  Future<int> getNextSortOrder(int? parentId);

  Future<void> reorder(int? parentId, List<int> folderIds);

  Future<bool> hasSubfolders(int folderId);

  Future<bool> hasDecks(int folderId);

  Future<List<int>> getDescendantIds(int folderId);

  Future<
    ({int subfolderCount, int deckCount, int totalCards, int masteredCards})
  >
  getRecursiveStats(int folderId);

  Future<({int subfolderCount, int deckCount, int cardCount})> getDeleteCounts(
    int folderId,
  );

  Future<void> deleteByIds(List<int> folderIds);

  Future<void> delete(int id);
}

final class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  const FolderLocalDataSourceImpl(this._folderDao);

  final FolderDao _folderDao;

  @override
  Future<void> delete(int id) => _folderDao.deleteById(id);

  @override
  Future<void> deleteByIds(List<int> folderIds) async {
    await _folderDao.deleteByIds(folderIds);
  }

  @override
  Future<List<FoldersTableData>> getAll() => _folderDao.getAll();

  @override
  Future<List<FoldersTableData>> getByParent(int? parentId) => _folderDao.getByParent(parentId);

  @override
  Future<FoldersTableData?> getById(int id) => _folderDao.getById(id);

  @override
  Future<({int subfolderCount, int deckCount, int cardCount})> getDeleteCounts(
    int folderId,
  ) => _folderDao.getDeleteCounts(folderId);

  @override
  Future<List<int>> getDescendantIds(int folderId) => _folderDao.getDescendantIds(folderId);

  @override
  Future<int> getNextSortOrder(int? parentId) => _folderDao.getNextSortOrder(parentId);

  @override
  Future<
    ({int subfolderCount, int deckCount, int totalCards, int masteredCards})
  >
  getRecursiveStats(int folderId) => _folderDao.getRecursiveStats(folderId);

  @override
  Future<bool> hasDecks(int folderId) => _folderDao.hasDecks(folderId);

  @override
  Future<bool> hasSubfolders(int folderId) =>
      _folderDao.hasSubfolders(folderId);

  @override
  Future<void> reorder(int? parentId, List<int> folderIds) => _folderDao.reorderByParent(parentId, folderIds);

  @override
  Future<FoldersTableData> save(FoldersTableCompanion companion) async {
    final insertedId = await _folderDao.insertFolder(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _folderDao.getById(targetId);
    return saved!;
  }

  @override
  Future<FoldersTableData> update({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    await _folderDao.updateFolderPresentation(
      id: id,
      name: name,
      colorValue: colorValue,
    );
    final saved = await _folderDao.getById(id);
    return saved!;
  }

  @override
  Stream<List<FoldersTableData>> watchAll() => _folderDao.watchAllFolders();

  @override
  Stream<List<FoldersTableData>> watchByParent(int? parentId) {
    if (parentId == null) {
      return _folderDao.watchRootFolders();
    }

    return _folderDao.watchByParent(parentId);
  }
}
