import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/get_folder_breadcrumb.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('builds breadcrumb by walking parent chain', () async {
    final useCase = GetFolderBreadcrumbUseCase(
      FakeFolderRepository(
        folders: const [
          FolderEntity(id: 1, name: 'Root'),
          FolderEntity(id: 2, name: 'Child', parentId: 1),
          FolderEntity(id: 3, name: 'Leaf', parentId: 2),
        ],
      ),
    );

    final result = await useCase.call(3);

    expect(result.map((folder) => folder.name), ['Root', 'Child', 'Leaf']);
  });
}
