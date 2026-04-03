import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/usecases/update_card.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  test('updates an existing card with trimmed values', () async {
    final repository = FakeFlashcardRepository(
      cards: const [
        FlashcardEntity(id: 1, deckId: 1, front: 'Old', back: 'Value'),
      ],
    );
    final useCase = UpdateCardUseCase(repository);

    final result = await useCase.call(
      id: 1,
      front: '  New front  ',
      back: '  New back  ',
      hint: '  Hint  ',
      example: '  Example  ',
      tags: const ['updated'],
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.front, 'New front');
    expect(result.dataOrNull?.back, 'New back');
    expect(result.dataOrNull?.hint, 'Hint');
    expect(result.dataOrNull?.example, 'Example');
    expect(result.dataOrNull?.tags, const ['updated']);
  });

  test('returns not found failure when card does not exist', () async {
    final useCase = UpdateCardUseCase(FakeFlashcardRepository());

    final result = await useCase.call(id: 99, front: 'Front', back: 'Back');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('not found'));
  });
}
