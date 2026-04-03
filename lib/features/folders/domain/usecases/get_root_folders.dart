import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class GetRootFoldersUseCase {
  const GetRootFoldersUseCase(this._repository);

  final FolderRepository _repository;

  Stream<List<FolderEntity>> call() => _repository.watchRootFolders();
}
