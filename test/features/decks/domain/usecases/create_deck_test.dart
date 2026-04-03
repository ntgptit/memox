import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/usecases/create_deck.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';

void main() {
  test('creates deck when name is unique inside folder', () async {
    final useCase = CreateDeckUseCase(FakeDeckRepository());

    final result = await useCase.call(
      name: 'Core Vocabulary',
      folderId: 1,
      colorValue: const DeckEntity(id: 0, name: 'tmp').colorValue,
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.name, 'Core Vocabulary');
  });

  test('returns conflict when name already exists inside folder', () async {
    final useCase = CreateDeckUseCase(
      FakeDeckRepository(
        decks: const [DeckEntity(id: 1, name: 'Core Vocabulary', folderId: 1)],
      ),
    );

    final result = await useCase.call(
      name: 'core vocabulary',
      folderId: 1,
      colorValue: 0xFF5C6BC0,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('already exists'));
  });
}
