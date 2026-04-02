import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/logging/log_level.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';
import 'package:memox/features/folders/domain/usecases/delete_folder.dart';

void main() {
  test('delete folder returns success when repository deletes', () async {
    final repository = _MutableFolderRepository();
    final useCase = DeleteFolderUseCase(
      folderRepo: repository,
      logger: const _FakeLogger(),
    );

    final result = await useCase.call(1);

    expect(result.isSuccess, isTrue);
    expect(repository.deletedIds, <int>[1]);
  });

  test('delete folder returns failure when repository throws', () async {
    final useCase = DeleteFolderUseCase(
      folderRepo: _ThrowingFolderRepository(),
      logger: const _FakeLogger(),
    );

    final result = await useCase.call(1);

    expect(result.isFailure, isTrue);
  });
}

final class _MutableFolderRepository implements FolderRepository {
  final List<int> deletedIds = <int>[];

  @override
  Future<void> delete(int id) async {
    deletedIds.add(id);
  }

  @override
  Future<FolderEntity?> getById(int id) async => null;

  @override
  Future<List<FolderEntity>> getRootFolders() async => const <FolderEntity>[];

  @override
  Future<FolderEntity> save(FolderEntity entity) async => entity;

  @override
  Stream<List<FolderEntity>> watchRootFolders() async* {
    yield const <FolderEntity>[];
  }
}

final class _ThrowingFolderRepository implements FolderRepository {
  @override
  Future<void> delete(int id) async {
    throw StateError('boom');
  }

  @override
  Future<FolderEntity?> getById(int id) async => null;

  @override
  Future<List<FolderEntity>> getRootFolders() async => const <FolderEntity>[];

  @override
  Future<FolderEntity> save(FolderEntity entity) async => entity;

  @override
  Stream<List<FolderEntity>> watchRootFolders() async* {
    yield const <FolderEntity>[];
  }
}

final class _FakeLogger implements AppLogger {
  const _FakeLogger();

  @override
  void debug(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message) {}

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
}
