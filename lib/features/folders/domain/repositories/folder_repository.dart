import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_recursive_stats.dart';

abstract interface class FolderRepository {
  Stream<List<FolderEntity>> watchAll();

  Stream<List<FolderEntity>> watchRootFolders();

  Stream<List<FolderEntity>> watchSubfolders(int parentId);

  Future<List<FolderEntity>> getAll();

  Future<FolderEntity?> getById(int id);

  Future<List<FolderEntity>> getRootFolders();

  Future<List<FolderEntity>> getSubfolders(int parentId);

  Future<FolderEntity> create({
    required String name,
    int? parentId,
    required int colorValue,
  });

  Future<FolderEntity> update({
    required int id,
    required String name,
    required int colorValue,
  });

  Future<int> getNextSortOrder(int? parentId);

  Future<void> reorder({int? parentId, required List<int> folderIds});

  Future<bool> hasSubfolders(int folderId);

  Future<bool> hasDecks(int folderId);

  Future<FolderRecursiveStats> getRecursiveStats(int folderId);

  Future<FolderDeleteSummary> getDeleteSummary(int folderId);

  Future<FolderDeleteSummary> deleteCascade(int folderId);
}
