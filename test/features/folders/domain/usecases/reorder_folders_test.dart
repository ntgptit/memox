import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/reorder_folders.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('persists new folder order', () async {
    final repository = FakeFolderRepository(
      folders: const [
        FolderEntity(id: 1, name: 'A'),
        FolderEntity(id: 2, name: 'B'),
      ],
    );
    final useCase = ReorderFoldersUseCase(repository);

    final result = await useCase.call(folderIds: const [2, 1]);

    expect(result.isSuccess, isTrue);
    expect(repository.reorderedFolderIds, <int>[2, 1]);
  });
}
