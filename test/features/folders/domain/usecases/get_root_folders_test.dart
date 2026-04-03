import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/get_root_folders.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('watches only root folders from repository', () async {
    final useCase = GetRootFoldersUseCase(
      FakeFolderRepository(
        folders: const [
          FolderEntity(id: 1, name: 'Inbox'),
          FolderEntity(id: 2, name: 'Child', parentId: 1),
        ],
      ),
    );

    final result = await useCase.call().first;

    expect(result, const [FolderEntity(id: 1, name: 'Inbox')]);
  });
}
