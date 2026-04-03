import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class CanCreateDeckUseCase {
  const CanCreateDeckUseCase(this._repository);

  final FolderRepository _repository;

  Future<bool> call(int folderId) async => !(await _repository.hasSubfolders(folderId));
}
