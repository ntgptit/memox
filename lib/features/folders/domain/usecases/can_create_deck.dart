import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class CanCreateDeckUseCase {
  const CanCreateDeckUseCase(this._repository);

  final FolderRepository _repository;

  Future<bool> call(int folderId) async {
    return !(await _repository.hasSubfolders(folderId));
  }
}
