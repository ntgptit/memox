import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/update_folder.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('returns success when updating an existing folder', () async {
    final repository = FakeFolderRepository(
      folders: const [FolderEntity(id: 1, name: 'Inbox')],
    );
    final useCase = UpdateFolderUseCase(
      folderRepo: repository,
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(
      id: 1,
      name: 'Advanced Inbox',
      colorValue: 0xFF90A4AE,
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.name, 'Advanced Inbox');
    expect(result.dataOrNull?.colorValue, 0xFF90A4AE);
    expect(repository.updatedFolderIds, [1]);
  });

  test('returns conflict failure for duplicate sibling name', () async {
    final useCase = UpdateFolderUseCase(
      folderRepo: FakeFolderRepository(
        folders: const [
          FolderEntity(id: 1, name: 'Inbox'),
          FolderEntity(id: 2, name: 'Archive'),
        ],
      ),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(
      id: 2,
      name: 'inbox',
      colorValue: 0xFF5C6BC0,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('already exists'));
  });
}
