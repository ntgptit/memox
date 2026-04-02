import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';
import 'package:memox/features/folders/domain/usecases/create_folder.dart';

void main() {
  test('create folder use case returns success for valid name', () async {
    final useCase = CreateFolderUseCase(
      folderRepo: _InMemoryFolderRepository(),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call('Inbox');

    expect(result, isA<Success<FolderEntity>>());
    expect(result.dataOrNull?.name, 'Inbox');
  });

  test('create folder use case returns validation failure for empty name', () async {
    final useCase = CreateFolderUseCase(
      folderRepo: _InMemoryFolderRepository(),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call('   ');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('must not be empty'));
  });
}

final class _InMemoryFolderRepository implements FolderRepository {
  final List<FolderEntity> _folders = <FolderEntity>[];

  @override
  Future<void> delete(int id) async {
    _folders.removeWhere((folder) => folder.id == id);
  }

  @override
  Future<FolderEntity?> getById(int id) async {
    for (final folder in _folders) {
      if (folder.id == id) {
        return folder;
      }
    }

    return null;
  }

  @override
  Future<List<FolderEntity>> getRootFolders() async => _folders;

  @override
  Future<FolderEntity> save(FolderEntity entity) async {
    final saved = entity.copyWith(id: _folders.length + 1);
    _folders.add(saved);
    return saved;
  }

  @override
  Stream<List<FolderEntity>> watchRootFolders() async* {
    yield _folders;
  }
}
