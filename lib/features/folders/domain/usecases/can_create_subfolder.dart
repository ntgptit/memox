import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class CanCreateSubfolderUseCase {
  const CanCreateSubfolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<bool> call() async {
    final folders = await _repository.getRootFolders();
    return folders.length < 100;
  }
}
