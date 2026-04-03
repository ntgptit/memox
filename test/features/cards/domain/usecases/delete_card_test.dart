import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/usecases/delete_card.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  test('deletes card from repository', () async {
    final repository = FakeFlashcardRepository(
      cards: const [
        FlashcardEntity(id: 1, deckId: 1, front: 'Front', back: 'Back'),
      ],
    );
    final useCase = DeleteCardUseCase(repository);

    final result = await useCase.call(1);

    expect(result.isSuccess, isTrue);
    expect(await repository.getAll(), isEmpty);
  });
}
