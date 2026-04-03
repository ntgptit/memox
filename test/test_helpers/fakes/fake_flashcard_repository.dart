import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

class FakeFlashcardRepository implements FlashcardRepository {
  FakeFlashcardRepository({List<FlashcardEntity>? cards})
    : _cards = [...?cards];

  final List<FlashcardEntity> _cards;

  @override
  Future<void> delete(int id) async {
    _cards.removeWhere((card) => card.id == id);
  }

  @override
  Future<List<FlashcardEntity>> getAll() async => [..._cards];

  @override
  Future<List<FlashcardEntity>> getByDeck(int deckId) async {
    return _cards.where((card) => card.deckId == deckId).toList();
  }

  @override
  Future<FlashcardEntity?> getById(int id) async {
    for (final card in _cards) {
      if (card.id == id) {
        return card;
      }
    }

    return null;
  }

  @override
  Future<List<FlashcardEntity>> getDueCards({
    int? deckId,
    int limit = 20,
  }) async {
    final now = DateTime.now();
    final cards = _cards.where((card) {
      if (deckId != null && card.deckId != deckId) {
        return false;
      }

      if (card.status == CardStatus.newCard) {
        return true;
      }

      final nextReviewDate = card.nextReviewDate;
      if (nextReviewDate == null) {
        return false;
      }

      return !nextReviewDate.isAfter(now);
    }).toList();
    return cards.take(limit).toList();
  }

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async {
    _cards.removeWhere((card) => card.id == entity.id && entity.id != 0);
    _cards.add(entity);
    return entity;
  }

  @override
  Future<List<FlashcardEntity>> saveAll(List<FlashcardEntity> entities) async {
    _cards.addAll(entities);
    return entities;
  }

  @override
  Stream<List<FlashcardEntity>> watchAll() async* {
    yield [..._cards];
  }

  @override
  Stream<List<FlashcardEntity>> watchByDeck(int deckId) async* {
    yield _cards.where((card) => card.deckId == deckId).toList();
  }
}
