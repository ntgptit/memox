import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/get_subfolders.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('watches subfolders for parent id', () async {
    final useCase = GetSubfoldersUseCase(
      FakeFolderRepository(
        folders: const [
          FolderEntity(id: 1, name: 'Inbox'),
          FolderEntity(id: 2, name: 'Child A', parentId: 1),
          FolderEntity(id: 3, name: 'Child B', parentId: 1),
        ],
      ),
    );

    final result = await useCase.call(1).first;

    expect(result.length, 2);
    expect(result.map((folder) => folder.name), ['Child A', 'Child B']);
  });
}
