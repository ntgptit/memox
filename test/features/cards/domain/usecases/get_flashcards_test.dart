import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/cards/domain/usecases/get_flashcards.dart';

void main() {
  test('get flashcards use case watches repository cards', () async {
    final cards = <FlashcardEntity>[
      const FlashcardEntity(id: 1, front: 'Hello', back: 'Xin chao'),
    ];
    final useCase = GetFlashcardsUseCase(_FakeFlashcardRepository(cards));

    await expectLater(useCase.call(), emits(cards));
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
  Future<List<FlashcardEntity>> getDueCards() async => _cards;

  @override
  Future<FlashcardEntity> save(FlashcardEntity entity) async => entity;

  @override
  Stream<List<FlashcardEntity>> watchAll() async* {
    yield _cards;
  }
}
