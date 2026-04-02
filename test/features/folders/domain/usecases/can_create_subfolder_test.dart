import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';
import 'package:memox/features/folders/domain/usecases/can_create_subfolder.dart';

void main() {
  test('can create subfolder returns true below limit', () async {
    final useCase = CanCreateSubfolderUseCase(_FakeFolderRepository(count: 3));

    final result = await useCase.call();

    expect(result, isTrue);
  });

  test('can create subfolder returns false at limit', () async {
    final useCase = CanCreateSubfolderUseCase(
      _FakeFolderRepository(count: 100),
    );

    final result = await useCase.call();

    expect(result, isFalse);
  });
}

final class _FakeFolderRepository implements FolderRepository {
  _FakeFolderRepository({required int count})
    : _folders = List<FolderEntity>.generate(
        count,
        (index) => FolderEntity(id: index + 1, name: 'Folder ${index + 1}'),
      );

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
