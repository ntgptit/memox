import 'package:memox/features/folders/domain/entities/folder_entity.dart';

abstract interface class FolderRepository {
  Stream<List<FolderEntity>> watchRootFolders();

  Future<List<FolderEntity>> getRootFolders();

  Future<FolderEntity?> getById(int id);

  Future<FolderEntity> save(FolderEntity entity);

  Future<void> delete(int id);
}
