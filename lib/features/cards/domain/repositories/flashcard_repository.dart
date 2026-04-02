import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

abstract interface class FlashcardRepository {
  Stream<List<FlashcardEntity>> watchAll();

  Future<List<FlashcardEntity>> getAll();

  Future<List<FlashcardEntity>> getDueCards();

  Future<FlashcardEntity> save(FlashcardEntity entity);

  Future<void> delete(int id);
}
