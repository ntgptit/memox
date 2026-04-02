import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';
import 'package:memox/features/folders/domain/usecases/get_folders.dart';

void main() {
  test('get folders use case watches root folders from repository', () async {
    final folders = <FolderEntity>[const FolderEntity(id: 1, name: 'Inbox')];
    final useCase = GetFoldersUseCase(_FakeFolderRepository(folders));

    await expectLater(useCase.call(), emits(folders));
  });
}

final class _FakeFolderRepository implements FolderRepository {
  const _FakeFolderRepository(this._folders);

  final List<FolderEntity> _folders;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<FolderEntity?> getById(int id) async => null;

  @override
  Future<List<FolderEntity>> getRootFolders() async => _folders;

  @override
  Future<FolderEntity> save(FolderEntity entity) async => entity;

  @override
  Stream<List<FolderEntity>> watchRootFolders() async* {
    yield _folders;
  }
}
