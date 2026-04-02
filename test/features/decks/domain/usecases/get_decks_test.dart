import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';
import 'package:memox/features/decks/domain/usecases/get_decks.dart';

void main() {
  test('get decks use case watches repository decks', () async {
    final expected = <DeckEntity>[const DeckEntity(id: 1, name: 'Deck')];
    final useCase = GetDecksUseCase(_FakeDeckRepository(expected));

    final result = await useCase.call().first;

    expect(result, expected);
  });
}

final class _FakeDeckRepository implements DeckRepository {
  const _FakeDeckRepository(this._decks);

  final List<DeckEntity> _decks;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<DeckEntity>> getAll() async => _decks;

  @override
  Future<DeckEntity> save(DeckEntity entity) async => entity;

  @override
  Stream<List<DeckEntity>> watchAll() async* {
    yield _decks;
  }
}
