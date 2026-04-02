import 'package:memox/features/decks/domain/entities/deck_entity.dart';

abstract interface class DeckRepository {
  Stream<List<DeckEntity>> watchAll();

  Future<List<DeckEntity>> getAll();

  Future<DeckEntity> save(DeckEntity entity);

  Future<void> delete(int id);
}
