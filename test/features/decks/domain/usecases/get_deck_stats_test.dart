import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/decks/domain/usecases/get_deck_stats.dart';

void main() {
  test('computes deck stats from repository cards', () async {
    const useCase = GetDeckStatsUseCase(
      _FakeFlashcardRepository(
        cards: [
          FlashcardEntity(id: 1, deckId: 4, front: 'A', back: 'a'),
          FlashcardEntity(
            id: 2,
            deckId: 4,
            front: 'B',
            back: 'b',
            status: CardStatus.learning,
          ),
          FlashcardEntity(
            id: 3,
            deckId: 4,
            front: 'C',
            back: 'c',
            status: CardStatus.reviewing,
          ),
          FlashcardEntity(
            id: 4,
            deckId: 4,
            front: 'D',
            back: 'd',
            status: CardStatus.mastered,
          ),
        ],
        dueCards: [
          FlashcardEntity(id: 1, deckId: 4, front: 'A', back: 'a'),
          FlashcardEntity(
            id: 2,
            deckId: 4,
            front: 'B',
            back: 'b',
            status: CardStatus.learning,
          ),
        ],
      ),
    );

    final stats = await useCase.call(4);

    expect(stats.total, 4);
    expect(stats.due, 2);
    expect(stats.known, 1);
    expect(stats.learning, 2);
    expect(stats.newCards, 1);
    expect(stats.mastery, 0.25);
  });
}

final class _FakeFlashcardRepository implements FlashcardRepository {
  const _FakeFlashcardRepository({required this.cards, required this.dueCards});

  final List<FlashcardEntity> cards;
  final List<FlashcardEntity> dueCards;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<FlashcardEntity>> getAll() async => cards;

  @override
  Future<List<FlashcardEntity>> getByDeck(int deckId) async =>
      cards.where((card) => card.deckId == deckId).toList();

  @override
  Future<FlashcardEntity?> getById(int id) async => null;

  @override
  Future<List<FlashcardEntity>> getDueCards({
    int? deckId,
    int limit = 20,
  }) async {
    final filtered = dueCards.where((card) {
      if (deckId == null) {
        return true;
      }

      return card.deckId == deckId;
    }).toList();
    return filtered.take(limit).toList();
  }

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async => entity;

  @override
  Future<List<FlashcardEntity>> saveAll(List<FlashcardEntity> entities) async =>
      entities;

  @override
  Stream<List<FlashcardEntity>> watchAll() async* {
    yield cards;
  }

  @override
  Stream<List<FlashcardEntity>> watchByDeck(int deckId) async* {
    yield cards.where((card) => card.deckId == deckId).toList();
  }
}
