import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

class FakeFlashcardRepository implements FlashcardRepository {
  FakeFlashcardRepository({List<FlashcardEntity>? cards}) : _cards = [...?cards];

  final List<FlashcardEntity> _cards;

  @override
  Future<void> delete(int id) async {
    _cards.removeWhere((card) => card.id == id);
  }

  @override
  Future<List<FlashcardEntity>> getAll() async => [..._cards];

  @override
  Future<List<FlashcardEntity>> getDueCards() async => [..._cards];

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async {
    _cards.add(entity);
    return entity;
  }

  @override
  Stream<List<FlashcardEntity>> watchAll() async* {
    yield [..._cards];
  }
}
