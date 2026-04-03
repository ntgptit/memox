import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/cards/domain/usecases/get_due_cards.dart';

void main() {
  test('get due cards use case returns repository due cards', () async {
    final expected = <FlashcardEntity>[
      const FlashcardEntity(id: 1, front: 'Front', back: 'Back'),
    ];
    final useCase = GetDueCardsUseCase(_FakeFlashcardRepository(expected));

    final result = await useCase.call();

    expect(result, expected);
  });
}

final class _FakeFlashcardRepository implements FlashcardRepository {
  const _FakeFlashcardRepository(this._cards);

  final List<FlashcardEntity> _cards;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<FlashcardEntity>> getAll() async => _cards;

  @override
  Future<List<FlashcardEntity>> getByDeck(int deckId) async => _cards;

  @override
  Future<FlashcardEntity?> getById(int id) async => null;

  @override
  Future<List<FlashcardEntity>> getDueCards({
    int? deckId,
    int limit = 20,
  }) async => _cards.take(limit).toList();

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async => entity;

  @override
  Future<List<FlashcardEntity>> saveAll(List<FlashcardEntity> entities) async {
    return entities;
  }

  @override
  Stream<List<FlashcardEntity>> watchAll() async* {
    yield _cards;
  }

  @override
  Stream<List<FlashcardEntity>> watchByDeck(int deckId) async* {
    yield _cards;
  }
}
