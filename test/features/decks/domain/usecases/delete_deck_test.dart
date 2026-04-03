import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/usecases/delete_deck.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';

void main() {
  test('deletes deck cascade from repository', () async {
    final repository = FakeDeckRepository(
      decks: const [DeckEntity(id: 1, name: 'Core', folderId: 1)],
    );
    final useCase = DeleteDeckUseCase(repository);

    final result = await useCase.call(1);

    expect(result.isSuccess, isTrue);
    expect(await repository.getAll(), isEmpty);
  });
}
