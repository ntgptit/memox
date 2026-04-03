import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class GetFolderBreadcrumbUseCase {
  const GetFolderBreadcrumbUseCase(this._repository);

  final FolderRepository _repository;

  Future<List<FolderEntity>> call(int folderId) async {
    final folders = await _repository.getAll();
    final byId = <int, FolderEntity>{
      for (final folder in folders) folder.id: folder,
    };
    final breadcrumb = <FolderEntity>[];
    var currentId = folderId;

    while (true) {
      final current = byId[currentId];
      if (current == null) {
        return breadcrumb.reversed.toList();
      }

      breadcrumb.add(current);
      if (current.parentId == null) {
        return breadcrumb.reversed.toList();
      }

      currentId = current.parentId!;
    }
  }
}
