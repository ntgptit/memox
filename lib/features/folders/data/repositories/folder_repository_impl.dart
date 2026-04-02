import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/folders/data/datasources/folder_local_datasource.dart';
import 'package:memox/features/folders/data/mappers/folder_mapper.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class FolderRepositoryImpl implements FolderRepository {
  const FolderRepositoryImpl({
    required FolderLocalDataSource localDataSource,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _logger = logger;

  final FolderLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<void> delete(int id) async {
    _logger.info('Deleting folder $id');
    await _localDataSource.delete(id);
  }

  @override
  Future<FolderEntity?> getById(int id) async {
    final model = await _localDataSource.getById(id);

    if (model == null) {
      return null;
    }

    return FolderMapper.toEntity(model);
  }

  @override
  Future<List<FolderEntity>> getRootFolders() async {
    final rows = await _localDataSource.getAll();
    return rows.map(FolderMapper.toEntity).toList();
  }

  @override
  Future<FolderEntity> save(FolderEntity entity) async {
    final savedRow = await _localDataSource.save(
      FolderMapper.toCompanion(entity),
    );
    final savedEntity = FolderMapper.toEntity(savedRow);
    _logger.info('Saved folder ${savedEntity.id}');
    return savedEntity;
  }

  @override
  Stream<List<FolderEntity>> watchRootFolders() {
    return _localDataSource.watchAll().map(
      (rows) => rows.map(FolderMapper.toEntity).toList(),
    );
  }
}
