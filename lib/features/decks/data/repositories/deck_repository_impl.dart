import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/decks/data/datasources/deck_local_datasource.dart';
import 'package:memox/features/decks/data/mappers/deck_mapper.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class DeckRepositoryImpl implements DeckRepository {
  const DeckRepositoryImpl({
    required DeckLocalDataSource localDataSource,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _logger = logger;

  final DeckLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<void> delete(int id) async {
    _logger.info('Deleting deck $id');
    await _localDataSource.delete(id);
  }

  @override
  Future<List<DeckEntity>> getAll() async {
    final rows = await _localDataSource.getAll();
    return rows.map(DeckMapper.toEntity).toList();
  }

  @override
  Future<List<DeckEntity>> getByFolder(int folderId) async {
    final rows = await _localDataSource.getByFolder(folderId);
    return rows.map(DeckMapper.toEntity).toList();
  }

  @override
  Future<DeckEntity?> getById(int id) async {
    final row = await _localDataSource.getById(id);

    if (row == null) {
      return null;
    }

    return DeckMapper.toEntity(row);
  }

  @override
  Future<int> getNextSortOrder(int folderId) {
    return _localDataSource.getNextSortOrder(folderId);
  }

  @override
  Future<void> reorder({required int folderId, required List<int> deckIds}) {
    return _localDataSource.reorder(folderId, deckIds);
  }

  @override
  Future<DeckEntity> save(DeckEntity entity) async {
    final savedRow = await _localDataSource.save(
      DeckMapper.toCompanion(entity),
    );
    return DeckMapper.toEntity(savedRow);
  }

  @override
  Stream<List<DeckEntity>> watchAll() {
    return _localDataSource.watchAll().map(
      (rows) => rows.map(DeckMapper.toEntity).toList(),
    );
  }
}
