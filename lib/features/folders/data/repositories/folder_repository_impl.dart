import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/cards/data/datasources/flashcard_local_datasource.dart';
import 'package:memox/features/decks/data/datasources/deck_local_datasource.dart';
import 'package:memox/features/folders/data/datasources/folder_local_datasource.dart';
import 'package:memox/features/folders/data/mappers/folder_mapper.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_recursive_stats.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class FolderRepositoryImpl implements FolderRepository {
  const FolderRepositoryImpl({
    required AppDatabase database,
    required FolderLocalDataSource localDataSource,
    required DeckLocalDataSource deckLocalDataSource,
    required FlashcardLocalDataSource flashcardLocalDataSource,
    required CardReviewDao cardReviewDao,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _database = database,
       _deckLocalDataSource = deckLocalDataSource,
       _flashcardLocalDataSource = flashcardLocalDataSource,
       _cardReviewDao = cardReviewDao,
       _logger = logger;

  final AppDatabase _database;
  final FolderLocalDataSource _localDataSource;
  final DeckLocalDataSource _deckLocalDataSource;
  final FlashcardLocalDataSource _flashcardLocalDataSource;
  final CardReviewDao _cardReviewDao;
  final AppLogger _logger;

  @override
  Future<FolderEntity> create({
    required String name,
    int? parentId,
    required int colorValue,
  }) async {
    final savedRow = await _localDataSource.save(
      FoldersTableCompanion(
        name: Value<String>(name),
        parentId: Value<int?>(parentId),
        colorValue: Value<int>(colorValue),
        sortOrder: Value<int>(
          await _localDataSource.getNextSortOrder(parentId),
        ),
      ),
    );
    final savedEntity = FolderMapper.toEntity(savedRow);
    _logger.info('Saved folder ${savedEntity.id}');
    return savedEntity;
  }

  @override
  Future<FolderDeleteSummary> deleteCascade(int id) async {
    final summary = await getDeleteSummary(id);
    final descendantIds = await _localDataSource.getDescendantIds(id);
    final folderIds = <int>[id, ...descendantIds];
    final deckIds = await _deckLocalDataSource.getIdsByFolderIds(folderIds);
    final cardIds = await _flashcardLocalDataSource.getIdsByDeckIds(deckIds);

    await _database.transaction(() async {
      await _cardReviewDao.deleteByCardIds(cardIds);
      await _flashcardLocalDataSource.deleteByDeckIds(deckIds);
      await _deckLocalDataSource.deleteByFolderIds(folderIds);

      for (final folderId in descendantIds.reversed) {
        await _localDataSource.delete(folderId);
      }

      await _localDataSource.delete(id);
    });

    _logger.info('Deleted folder tree $id');
    return summary;
  }

  @override
  Future<List<FolderEntity>> getAll() async {
    final rows = await _localDataSource.getAll();
    return rows.map(FolderMapper.toEntity).toList();
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
  Future<FolderDeleteSummary> getDeleteSummary(int folderId) async {
    final counts = await _localDataSource.getDeleteCounts(folderId);
    final descendantIds = await _localDataSource.getDescendantIds(folderId);
    final folderIds = <int>[folderId, ...descendantIds];
    final deckIds = await _deckLocalDataSource.getIdsByFolderIds(folderIds);
    final cardIds = await _flashcardLocalDataSource.getIdsByDeckIds(deckIds);
    final reviewCount = await _cardReviewDao.countByCardIds(cardIds);

    return FolderDeleteSummary(
      subfolderCount: counts.subfolderCount,
      deckCount: counts.deckCount,
      cardCount: counts.cardCount,
      reviewCount: reviewCount,
    );
  }

  @override
  Future<int> getNextSortOrder(int? parentId) {
    return _localDataSource.getNextSortOrder(parentId);
  }

  @override
  Future<FolderEntity> update({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final savedRow = await _localDataSource.update(
      id: id,
      name: name,
      colorValue: colorValue,
    );
    final savedEntity = FolderMapper.toEntity(savedRow);
    _logger.info('Updated folder ${savedEntity.id}');
    return savedEntity;
  }

  @override
  Future<FolderRecursiveStats> getRecursiveStats(int folderId) async {
    final stats = await _localDataSource.getRecursiveStats(folderId);
    return FolderRecursiveStats(
      subfolderCount: stats.subfolderCount,
      deckCount: stats.deckCount,
      totalCards: stats.totalCards,
      masteredCards: stats.masteredCards,
    );
  }

  @override
  Future<List<FolderEntity>> getRootFolders() async {
    final rows = await _localDataSource.getByParent(null);
    return rows.map(FolderMapper.toEntity).toList();
  }

  @override
  Future<List<FolderEntity>> getSubfolders(int parentId) async {
    final rows = await _localDataSource.getByParent(parentId);
    return rows.map(FolderMapper.toEntity).toList();
  }

  @override
  Future<bool> hasDecks(int folderId) => _localDataSource.hasDecks(folderId);

  @override
  Future<bool> hasSubfolders(int folderId) {
    return _localDataSource.hasSubfolders(folderId);
  }

  @override
  Future<void> reorder({int? parentId, required List<int> folderIds}) {
    return _localDataSource.reorder(parentId, folderIds);
  }

  @override
  Stream<List<FolderEntity>> watchAll() {
    return _localDataSource.watchAll().map(
      (rows) => rows.map(FolderMapper.toEntity).toList(),
    );
  }

  @override
  Stream<List<FolderEntity>> watchRootFolders() {
    return _localDataSource
        .watchByParent(null)
        .map((rows) => rows.map(FolderMapper.toEntity).toList());
  }

  @override
  Stream<List<FolderEntity>> watchSubfolders(int parentId) {
    return _localDataSource
        .watchByParent(parentId)
        .map((rows) => rows.map(FolderMapper.toEntity).toList());
  }
}
