import 'package:memox/core/database/app_database.dart';

abstract interface class FlashcardLocalDataSource {
  Stream<List<CardsTableData>> watchAll();

  Stream<List<CardsTableData>> watchByDeck(int deckId);

  Future<List<CardsTableData>> getAll();

  Future<List<CardsTableData>> getByDeck(int deckId);

  Future<CardsTableData?> getById(int id);

  Future<List<CardsTableData>> getDueCards({int? deckId});

  Future<List<int>> getIdsByDeckIds(List<int> deckIds);

  Future<void> deleteByDeckIds(List<int> deckIds);

  Future<CardsTableData> save(CardsTableCompanion companion);

  Future<List<CardsTableData>> saveAll(List<CardsTableCompanion> companions);

  Future<void> delete(int id);
}

final class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  const FlashcardLocalDataSourceImpl(this._cardDao);

  final CardDao _cardDao;

  @override
  Future<void> delete(int id) => _cardDao.deleteById(id);

  @override
  Future<void> deleteByDeckIds(List<int> deckIds) {
    return _cardDao.deleteByDeckIds(deckIds);
  }

  @override
  Future<List<CardsTableData>> getAll() => _cardDao.getAll();

  @override
  Future<List<CardsTableData>> getByDeck(int deckId) =>
      _cardDao.getByDeck(deckId);

  @override
  Future<CardsTableData?> getById(int id) => _cardDao.getById(id);

  @override
  Future<List<CardsTableData>> getDueCards({int? deckId}) {
    return _cardDao.getDueCards(deckId: deckId);
  }

  @override
  Future<List<int>> getIdsByDeckIds(List<int> deckIds) {
    return _cardDao.getIdsByDeckIds(deckIds);
  }

  @override
  Future<CardsTableData> save(CardsTableCompanion companion) async {
    final insertedId = await _cardDao.insertCard(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _cardDao.getById(targetId);
    return saved!;
  }

  @override
  Stream<List<CardsTableData>> watchAll() => _cardDao.watchAll();

  @override
  Stream<List<CardsTableData>> watchByDeck(int deckId) {
    return _cardDao.watchByDeck(deckId);
  }

  @override
  Future<List<CardsTableData>> saveAll(
    List<CardsTableCompanion> companions,
  ) async {
    if (companions.isEmpty) {
      return const <CardsTableData>[];
    }

    await _cardDao.insertBatch(companions);
    return _cardDao.getByDeck(companions.first.deckId.value);
  }
}
