import 'package:memox/features/decks/domain/entities/deck_entity.dart';

abstract interface class DeckRepository {
  Stream<List<DeckEntity>> watchAll();

  Stream<List<DeckEntity>> watchByFolder(int folderId);

  Future<List<DeckEntity>> getAll();

  Future<List<DeckEntity>> getByFolder(int folderId);

  Future<DeckEntity?> getById(int id);

  Future<int> getNextSortOrder(int folderId);

  Future<void> reorder({required int folderId, required List<int> deckIds});

  Future<DeckEntity> save(DeckEntity entity);

  Future<void> delete(int id);

  Future<void> deleteCascade(int id);
}
