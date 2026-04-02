import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/decks/data/datasources/deck_local_datasource.dart';
import 'package:memox/features/decks/data/mappers/deck_mapper.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class DeckRepositoryImpl implements DeckRepository {
  const DeckRepositoryImpl({
    required DeckLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
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
    final models = await _localDataSource.getAll();
    return models.map(DeckMapper.toEntity).toList();
  }

  @override
  Future<DeckEntity> save(DeckEntity entity) async {
    final savedModel = await _localDataSource.save(DeckMapper.toModel(entity));
    return DeckMapper.toEntity(savedModel);
  }

  @override
  Stream<List<DeckEntity>> watchAll() {
    return _localDataSource.watchAll().map(
      (models) => models.map(DeckMapper.toEntity).toList(),
    );
  }
}
