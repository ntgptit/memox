import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/usecases/update_deck.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';

void main() {
  test('returns success when updating an existing deck', () async {
    final repository = FakeDeckRepository(
      decks: const [
        DeckEntity(
          id: 3,
          name: 'Korean Core',
          folderId: 2,
          description: 'Starter words',
          tags: <String>['basics'],
        ),
      ],
    );
    final useCase = UpdateDeckUseCase(
      repository: repository,
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(
      id: 3,
      name: 'Korean Essentials',
      description: 'Everyday phrases',
      colorValue: 0xFF26A69A,
      tags: const <String>['phrases', 'daily'],
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.name, 'Korean Essentials');
    expect(result.dataOrNull?.description, 'Everyday phrases');
    expect(result.dataOrNull?.tags, const <String>['phrases', 'daily']);
    expect(await repository.getById(3), result.dataOrNull);
  });

  test('returns conflict when name already exists inside folder', () async {
    final useCase = UpdateDeckUseCase(
      repository: FakeDeckRepository(
        decks: const [
          DeckEntity(id: 3, name: 'Korean Core', folderId: 2),
          DeckEntity(id: 4, name: 'Korean Travel', folderId: 2),
        ],
      ),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(
      id: 4,
      name: 'korean core',
      description: '',
      colorValue: 0xFF5C6BC0,
      tags: const <String>[],
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message, contains('already exists'));
  });
}
