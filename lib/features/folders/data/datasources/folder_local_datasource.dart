import 'package:isar/isar.dart';
import 'package:memox/features/folders/data/models/folder_model.dart';

abstract interface class FolderLocalDataSource {
  Stream<List<FolderModel>> watchAll();

  Future<List<FolderModel>> getAll();

  Future<FolderModel?> getById(int id);

  Future<FolderModel> save(FolderModel model);

  Future<void> delete(int id);
}

final class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  const FolderLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.folderModels.delete(id);
    });
  }

  @override
  Future<List<FolderModel>> getAll() {
    return _isar.folderModels.where().findAll();
  }

  @override
  Future<FolderModel?> getById(int id) {
    return _isar.folderModels.get(id);
  }

  @override
  Future<FolderModel> save(FolderModel model) async {
    return _isar.writeTxn(() async {
      final savedId = await _isar.folderModels.put(model);
      model.id = savedId;
      return model;
    });
  }

  @override
  Stream<List<FolderModel>> watchAll() {
    return _isar.folderModels.where().watch(fireImmediately: true);
  }
}
