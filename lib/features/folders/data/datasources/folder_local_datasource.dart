import 'package:memox/core/database/app_database.dart';

abstract interface class FolderLocalDataSource {
  Stream<List<FoldersTableData>> watchAll();

  Future<List<FoldersTableData>> getAll();

  Future<FoldersTableData?> getById(int id);

  Future<FoldersTableData> save(FoldersTableCompanion companion);

  Future<void> delete(int id);
}

final class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  const FolderLocalDataSourceImpl(this._folderDao);

  final FolderDao _folderDao;

  @override
  Future<void> delete(int id) => _folderDao.deleteById(id);

  @override
  Future<List<FoldersTableData>> getAll() => _folderDao.getAll();

  @override
  Future<FoldersTableData?> getById(int id) => _folderDao.getById(id);

  @override
  Future<FoldersTableData> save(FoldersTableCompanion companion) async {
    final insertedId = await _folderDao.insertFolder(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _folderDao.getById(targetId);
    return saved!;
  }

  @override
  Stream<List<FoldersTableData>> watchAll() => _folderDao.watchRootFolders();
}
