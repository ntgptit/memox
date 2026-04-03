import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/usecases/get_decks_by_folder.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';

void main() {
  test('streams decks for the requested folder only', () async {
    final useCase = GetDecksByFolderUseCase(
      FakeDeckRepository(
        decks: const [
          DeckEntity(id: 1, name: 'Core', folderId: 1),
          DeckEntity(id: 2, name: 'Travel', folderId: 2),
        ],
      ),
    );

    final result = await useCase.call(1).first;

    expect(result.map((deck) => deck.id), [1]);
  });
}
