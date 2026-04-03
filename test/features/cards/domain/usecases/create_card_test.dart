import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/usecases/create_card.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  test('creates card with trimmed content', () async {
    final useCase = CreateCardUseCase(FakeFlashcardRepository());

    final result = await useCase.call(
      deckId: 1,
      front: '  Front  ',
      back: '  Back  ',
      hint: '  Hint  ',
      example: '  Example  ',
      tags: const ['tag'],
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.front, 'Front');
    expect(result.dataOrNull?.back, 'Back');
    expect(result.dataOrNull?.hint, 'Hint');
    expect(result.dataOrNull?.example, 'Example');
    expect(result.dataOrNull?.tags, const ['tag']);
  });

  test('returns validation failure when front is empty', () async {
    final useCase = CreateCardUseCase(FakeFlashcardRepository());

    final result = await useCase.call(deckId: 1, front: ' ', back: 'Back');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('Front'));
  });
}
