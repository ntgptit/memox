import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class GetSubfoldersUseCase {
  const GetSubfoldersUseCase(this._repository);

  final FolderRepository _repository;

  Stream<List<FolderEntity>> call(int parentId) {
    return _repository.watchSubfolders(parentId);
  }
}
