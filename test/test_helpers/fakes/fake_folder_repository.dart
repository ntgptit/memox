import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_recursive_stats.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

class FakeFolderRepository implements FolderRepository {
  FakeFolderRepository({
    List<FolderEntity>? folders,
    Map<int, FolderDeleteSummary>? deleteSummaries,
    Map<int, FolderRecursiveStats>? recursiveStats,
    Set<int>? foldersWithDecks,
    this.throwOnDelete = false,
  }) : _folders = [...?folders],
       _deleteSummaries = deleteSummaries ?? <int, FolderDeleteSummary>{},
       _recursiveStats = recursiveStats ?? <int, FolderRecursiveStats>{},
       _foldersWithDecks = foldersWithDecks ?? <int>{};

  final List<FolderEntity> _folders;
  final Map<int, FolderDeleteSummary> _deleteSummaries;
  final Map<int, FolderRecursiveStats> _recursiveStats;
  final Set<int> _foldersWithDecks;
  final bool throwOnDelete;

  final List<int> deletedFolderIds = <int>[];
  final List<int> updatedFolderIds = <int>[];
  List<int> reorderedFolderIds = <int>[];
  int? reorderedParentId;

  @override
  Future<FolderEntity> create({
    required String name,
    int? parentId,
    required int colorValue,
  }) async {
    final nextId =
        _folders.fold<int>(
          0,
          (maxId, folder) => folder.id > maxId ? folder.id : maxId,
        ) +
        1;
    final entity = FolderEntity(
      id: nextId,
      name: name,
      parentId: parentId,
      colorValue: colorValue,
      sortOrder: await getNextSortOrder(parentId),
    );
    _folders.add(entity);
    return entity;
  }

  @override
  Future<FolderDeleteSummary> deleteCascade(int id) async {
    if (throwOnDelete) {
      throw StateError('delete failed');
    }

    deletedFolderIds.add(id);
    _folders.removeWhere((folder) => folder.id == id || folder.parentId == id);
    return getDeleteSummary(id);
  }

  @override
  Future<List<FolderEntity>> getAll() async => [..._folders];

  @override
  Future<FolderEntity?> getById(int id) async {
    for (final folder in _folders) {
      if (folder.id == id) {
        return folder;
      }
    }

    return null;
  }

  @override
  Future<FolderDeleteSummary> getDeleteSummary(int folderId) async {
    return _deleteSummaries[folderId] ?? const FolderDeleteSummary();
  }

  @override
  Future<int> getNextSortOrder(int? parentId) async {
    return _folders.where((folder) => folder.parentId == parentId).length;
  }

  @override
  Future<FolderEntity> update({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final index = _folders.indexWhere((folder) => folder.id == id);
    final current = _folders[index];
    final updated = current.copyWith(
      name: name,
      colorValue: colorValue,
      updatedAt: DateTime.now(),
    );
    _folders[index] = updated;
    updatedFolderIds.add(id);
    return updated;
  }

  @override
  Future<FolderRecursiveStats> getRecursiveStats(int folderId) async {
    return _recursiveStats[folderId] ?? const FolderRecursiveStats();
  }

  @override
  Future<List<FolderEntity>> getRootFolders() async {
    return _folders.where((folder) => folder.parentId == null).toList();
  }

  @override
  Future<List<FolderEntity>> getSubfolders(int parentId) async {
    return _folders.where((folder) => folder.parentId == parentId).toList();
  }

  @override
  Future<bool> hasDecks(int folderId) async =>
      _foldersWithDecks.contains(folderId);

  @override
  Future<bool> hasSubfolders(int folderId) async =>
      _folders.any((folder) => folder.parentId == folderId);

  @override
  Future<void> reorder({int? parentId, required List<int> folderIds}) async {
    reorderedParentId = parentId;
    reorderedFolderIds = [...folderIds];
  }

  @override
  Stream<List<FolderEntity>> watchAll() async* {
    yield [..._folders];
  }

  @override
  Stream<List<FolderEntity>> watchRootFolders() async* {
    yield _folders.where((folder) => folder.parentId == null).toList();
  }

  @override
  Stream<List<FolderEntity>> watchSubfolders(int parentId) async* {
    yield _folders.where((folder) => folder.parentId == parentId).toList();
  }
}
