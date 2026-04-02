import 'package:memox/core/database/app_database.dart';

abstract interface class FlashcardLocalDataSource {
  Stream<List<CardsTableData>> watchAll();

  Future<List<CardsTableData>> getAll();

  Future<List<CardsTableData>> getDueCards();

  Future<CardsTableData> save(CardsTableCompanion companion);

  Future<void> delete(int id);
}

final class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  const FlashcardLocalDataSourceImpl(this._cardDao);

  final CardDao _cardDao;

  @override
  Future<void> delete(int id) => _cardDao.deleteById(id);

  @override
  Future<List<CardsTableData>> getAll() => _cardDao.getAll();

  @override
  Future<List<CardsTableData>> getDueCards() => _cardDao.getDueCards();

  @override
  Future<CardsTableData> save(CardsTableCompanion companion) async {
    final insertedId = await _cardDao.insertCard(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _cardDao.getById(targetId);
    return saved!;
  }

  @override
  Stream<List<CardsTableData>> watchAll() => _cardDao.watchAll();
}
