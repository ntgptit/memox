import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/usecases/create_cards_batch.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  test('batch parser handles empty lines and missing separator', () {
    final useCase = CreateCardsBatchUseCase(FakeFlashcardRepository());

    final result = useCase.preview(
      rawText: 'hello|xin chao\n\ninvalid line\nbye|tam biet',
      separator: '|',
      deckId: 1,
    );

    expect(result.parsed, hasLength(2));
    expect(result.parsed.first.front, 'hello');
    expect(result.parsed.first.back, 'xin chao');
    expect(result.errors, hasLength(1));
    expect(result.errors.single, contains('Line 3'));
  });
}
