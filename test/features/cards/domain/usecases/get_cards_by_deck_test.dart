import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/usecases/get_cards_by_deck.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  test('streams cards for the requested deck only', () async {
    final useCase = GetCardsByDeckUseCase(
      FakeFlashcardRepository(
        cards: const [
          FlashcardEntity(id: 1, deckId: 1, front: 'A', back: 'a'),
          FlashcardEntity(id: 2, deckId: 2, front: 'B', back: 'b'),
        ],
      ),
    );

    final result = await useCase.call(1).first;

    expect(result.map((card) => card.id), [1]);
  });
}
