import 'package:memox/core/database/app_database.dart';

abstract interface class DeckLocalDataSource {
  Stream<List<DecksTableData>> watchAll();

  Future<List<DecksTableData>> getAll();

  Future<DecksTableData> save(DecksTableCompanion companion);

  Future<void> delete(int id);
}

final class DeckLocalDataSourceImpl implements DeckLocalDataSource {
  const DeckLocalDataSourceImpl(this._deckDao);

  final DeckDao _deckDao;

  @override
  Future<void> delete(int id) => _deckDao.deleteById(id);

  @override
  Future<List<DecksTableData>> getAll() => _deckDao.getAll();

  @override
  Future<DecksTableData> save(DecksTableCompanion companion) async {
    final insertedId = await _deckDao.insertDeck(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _deckDao.getById(targetId);
    return saved!;
  }

  @override
  Stream<List<DecksTableData>> watchAll() => _deckDao.watchAll();
}
