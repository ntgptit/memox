import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class CanCreateSubfolderUseCase {
  const CanCreateSubfolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<bool> call(int folderId) async {
    return !(await _repository.hasDecks(folderId));
  }
}
