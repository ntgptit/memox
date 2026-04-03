import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/cards/data/datasources/flashcard_local_datasource.dart';
import 'package:memox/features/decks/data/datasources/deck_local_datasource.dart';
import 'package:memox/features/decks/data/mappers/deck_mapper.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class DeckRepositoryImpl implements DeckRepository {
  const DeckRepositoryImpl({
    required AppDatabase database,
    required DeckLocalDataSource localDataSource,
    required FlashcardLocalDataSource flashcardLocalDataSource,
    required CardReviewDao cardReviewDao,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _database = database,
       _flashcardLocalDataSource = flashcardLocalDataSource,
       _cardReviewDao = cardReviewDao,
       _logger = logger;

  final AppDatabase _database;
  final DeckLocalDataSource _localDataSource;
  final FlashcardLocalDataSource _flashcardLocalDataSource;
  final CardReviewDao _cardReviewDao;
  final AppLogger _logger;

  @override
  Future<void> delete(int id) async {
    _logger.info('Deleting deck $id');
    await _localDataSource.delete(id);
  }

  @override
  Future<void> deleteCascade(int id) async {
    final cardIds = await _flashcardLocalDataSource.getIdsByDeckIds(<int>[id]);
    await _database.transaction(() async {
      await _cardReviewDao.deleteByCardIds(cardIds);
      await _flashcardLocalDataSource.deleteByDeckIds(<int>[id]);
      await _localDataSource.delete(id);
    });
    _logger.info('Deleted deck $id');
  }

  @override
  Future<List<DeckEntity>> getAll() async {
    final rows = await _localDataSource.getAll();
    return rows.map((row) => row.toEntity()).toList();
  }

  @override
  Future<List<DeckEntity>> getByFolder(int folderId) async {
    final rows = await _localDataSource.getByFolder(folderId);
    return rows.map((row) => row.toEntity()).toList();
  }

  @override
  Future<DeckEntity?> getById(int id) async {
    final row = await _localDataSource.getById(id);

    if (row == null) {
      return null;
    }

    return row.toEntity();
  }

  @override
  Future<int> getNextSortOrder(int folderId) =>
      _localDataSource.getNextSortOrder(folderId);

  @override
  Future<void> reorder({required int folderId, required List<int> deckIds}) =>
      _localDataSource.reorder(folderId, deckIds);

  @override
  Future<DeckEntity> save(DeckEntity entity) async {
    final savedRow = await _localDataSource.save(entity.toCompanion());
    return savedRow.toEntity();
  }

  @override
  Stream<List<DeckEntity>> watchAll() => _localDataSource.watchAll().map(
    (rows) => rows.map((row) => row.toEntity()).toList(),
  );

  @override
  Stream<List<DeckEntity>> watchByFolder(int folderId) => _localDataSource
      .watchByFolder(folderId)
      .map((rows) => rows.map((row) => row.toEntity()).toList());
}
