import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/usecases/reorder_decks.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';

void main() {
  test('persists new deck order', () async {
    final repository = FakeDeckRepository(
      decks: const [
        DeckEntity(id: 1, name: 'A', folderId: 10),
        DeckEntity(id: 2, name: 'B', folderId: 10),
      ],
    );
    final useCase = ReorderDecksUseCase(repository);

    final result = await useCase.call(folderId: 10, deckIds: const [2, 1]);

    expect(result.isSuccess, isTrue);
    expect(repository.reorderedDeckIds, <int>[2, 1]);
    expect(repository.reorderedFolderId, 10);
  });
}
