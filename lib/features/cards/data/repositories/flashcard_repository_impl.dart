import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/cards/data/datasources/flashcard_local_datasource.dart';
import 'package:memox/features/cards/data/mappers/flashcard_mapper.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class FlashcardRepositoryImpl implements FlashcardRepository {
  const FlashcardRepositoryImpl({
    required AppDatabase database,
    required FlashcardLocalDataSource localDataSource,
    required CardReviewDao cardReviewDao,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _database = database,
       _cardReviewDao = cardReviewDao,
       _logger = logger;

  final AppDatabase _database;
  final FlashcardLocalDataSource _localDataSource;
  final CardReviewDao _cardReviewDao;
  final AppLogger _logger;

  @override
  Future<void> delete(int id) async {
    _logger.info('Deleting flashcard $id');
    await _database.transaction(() async {
      await _cardReviewDao.deleteByCardIds(<int>[id]);
      await _localDataSource.delete(id);
    });
  }

  @override
  Future<List<FlashcardEntity>> getAll() async {
    final rows = await _localDataSource.getAll();
    return rows.map(FlashcardMapper.toEntity).toList();
  }

  @override
  Future<List<FlashcardEntity>> getByDeck(int deckId) async {
    final rows = await _localDataSource.getByDeck(deckId);
    return rows.map(FlashcardMapper.toEntity).toList();
  }

  @override
  Future<FlashcardEntity?> getById(int id) async {
    final row = await _localDataSource.getById(id);

    if (row == null) {
      return null;
    }

    return FlashcardMapper.toEntity(row);
  }

  @override
  Future<List<FlashcardEntity>> getDueCards({
    int? deckId,
    int limit = 20,
  }) async {
    final rows = await _localDataSource.getDueCards(deckId: deckId);
    final cards = rows.map(FlashcardMapper.toEntity).toList()
      ..sort(_compareDueCards);
    return cards.take(limit).toList();
  }

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async {
    final savedRow = await _localDataSource.save(
      FlashcardMapper.toCompanion(entity),
    );
    return FlashcardMapper.toEntity(savedRow);
  }

  @override
  Stream<List<FlashcardEntity>> watchAll() {
    return _localDataSource.watchAll().map(
      (rows) => rows.map(FlashcardMapper.toEntity).toList(),
    );
  }

  @override
  Stream<List<FlashcardEntity>> watchByDeck(int deckId) {
    return _localDataSource
        .watchByDeck(deckId)
        .map((rows) => rows.map(FlashcardMapper.toEntity).toList());
  }

  @override
  Future<List<FlashcardEntity>> saveAll(List<FlashcardEntity> entities) async {
    if (entities.isEmpty) {
      return const <FlashcardEntity>[];
    }

    final existingIds = (await _localDataSource.getByDeck(
      entities.first.deckId,
    )).map((row) => row.id).toSet();
    final rows = await _localDataSource.saveAll(
      entities.map(FlashcardMapper.toCompanion).toList(),
    );
    return rows
        .where((row) => !existingIds.contains(row.id))
        .map(FlashcardMapper.toEntity)
        .toList();
  }

  int _compareDueCards(FlashcardEntity left, FlashcardEntity right) {
    final leftIsNew = left.status == CardStatus.newCard;
    final rightIsNew = right.status == CardStatus.newCard;

    if (leftIsNew != rightIsNew) {
      return leftIsNew ? 1 : -1;
    }

    if (!leftIsNew) {
      final leftDue = left.nextReviewDate ?? DateTime.now();
      final rightDue = right.nextReviewDate ?? DateTime.now();
      final dueComparison = leftDue.compareTo(rightDue);

      if (dueComparison != 0) {
        return dueComparison;
      }
    }

    final leftCreatedAt = left.createdAt ?? DateTime.now();
    final rightCreatedAt = right.createdAt ?? DateTime.now();
    return leftCreatedAt.compareTo(rightCreatedAt);
  }
}
