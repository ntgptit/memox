import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/cards/data/datasources/flashcard_local_datasource.dart';
import 'package:memox/features/cards/data/mappers/flashcard_mapper.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class FlashcardRepositoryImpl implements FlashcardRepository {
  const FlashcardRepositoryImpl({
    required FlashcardLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _logger = logger;

  final FlashcardLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<void> delete(int id) async {
    _logger.info('Deleting flashcard $id');
    await _localDataSource.delete(id);
  }

  @override
  Future<List<FlashcardEntity>> getAll() async {
    final models = await _localDataSource.getAll();
    return models.map(FlashcardMapper.toEntity).toList();
  }

  @override
  Future<List<FlashcardEntity>> getDueCards() {
    return getAll();
  }

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async {
    final savedModel =
        await _localDataSource.save(FlashcardMapper.toModel(entity));
    return FlashcardMapper.toEntity(savedModel);
  }

  @override
  Stream<List<FlashcardEntity>> watchAll() {
    return _localDataSource.watchAll().map(
      (models) => models.map(FlashcardMapper.toEntity).toList(),
    );
  }
}
