import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/usecases/get_decks.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';

void main() {
  test('watches repository decks', () async {
    final expected = <DeckEntity>[const DeckEntity(id: 1, name: 'Deck')];
    final useCase = GetDecksUseCase(FakeDeckRepository(decks: expected));

    final result = await useCase.call().first;

    expect(result, expected);
  });
}
