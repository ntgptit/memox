import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

class FakeDeckRepository implements DeckRepository {
  FakeDeckRepository({List<DeckEntity>? decks}) : _decks = [...?decks];

  final List<DeckEntity> _decks;
  List<int> reorderedDeckIds = <int>[];
  int? reorderedFolderId;

  @override
  Future<void> delete(int id) async {
    _decks.removeWhere((deck) => deck.id == id);
  }

  @override
  Future<List<DeckEntity>> getAll() async => [..._decks];

  @override
  Future<List<DeckEntity>> getByFolder(int folderId) async {
    return _decks.where((deck) => deck.folderId == folderId).toList();
  }

  @override
  Future<DeckEntity?> getById(int id) async {
    for (final deck in _decks) {
      if (deck.id == id) {
        return deck;
      }
    }

    return null;
  }

  @override
  Future<int> getNextSortOrder(int folderId) async {
    return _decks.where((deck) => deck.folderId == folderId).length;
  }

  @override
  Future<void> reorder({required int folderId, required List<int> deckIds}) async {
    reorderedFolderId = folderId;
    reorderedDeckIds = [...deckIds];
  }

  @override
  Future<DeckEntity> save(DeckEntity entity) async {
    final nextId = _decks.fold<int>(0, (maxId, deck) {
          return deck.id > maxId ? deck.id : maxId;
        }) +
        1;
    final saved = entity.id == 0 ? entity.copyWith(id: nextId) : entity;
    _decks.add(saved);
    return saved;
  }

  @override
  Stream<List<DeckEntity>> watchAll() async* {
    yield [..._decks];
  }
}
