import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/create_folder.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('returns success for valid root folder', () async {
    final useCase = CreateFolderUseCase(
      folderRepo: FakeFolderRepository(),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(
      name: 'Inbox',
      colorValue: const FolderEntity(id: 0, name: 'x').colorValue,
    );

    expect(result, isA<Success<FolderEntity>>());
    expect(result.dataOrNull?.name, 'Inbox');
  });

  test('returns validation failure for empty name', () async {
    final useCase = CreateFolderUseCase(
      folderRepo: FakeFolderRepository(),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(name: '   ', colorValue: 0xFF5C6BC0);

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('must not be empty'));
  });

  test('returns conflict failure for duplicate sibling name', () async {
    final useCase = CreateFolderUseCase(
      folderRepo: FakeFolderRepository(
        folders: const [FolderEntity(id: 1, name: 'Inbox')],
      ),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(name: 'inbox', colorValue: 0xFF5C6BC0);

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('already exists'));
  });
}
