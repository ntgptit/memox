import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

abstract interface class FlashcardRepository {
  Stream<List<FlashcardEntity>> watchAll();

  Stream<List<FlashcardEntity>> watchByDeck(int deckId);

  Future<List<FlashcardEntity>> getAll();

  Future<List<FlashcardEntity>> getByDeck(int deckId);

  Future<FlashcardEntity?> getById(int id);

  Future<List<FlashcardEntity>> getDueCards({int? deckId, int limit = 20});

  Future<FlashcardEntity> save(FlashcardEntity entity);

  Future<List<FlashcardEntity>> saveAll(List<FlashcardEntity> entities);

  Future<void> delete(int id);
}
