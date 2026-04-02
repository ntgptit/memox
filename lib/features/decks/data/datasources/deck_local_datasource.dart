import 'package:isar/isar.dart';
import 'package:memox/features/decks/data/models/deck_model.dart';

abstract interface class DeckLocalDataSource {
  Stream<List<DeckModel>> watchAll();

  Future<List<DeckModel>> getAll();

  Future<DeckModel> save(DeckModel model);

  Future<void> delete(int id);
}

final class DeckLocalDataSourceImpl implements DeckLocalDataSource {
  const DeckLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.deckModels.delete(id);
    });
  }

  @override
  Future<List<DeckModel>> getAll() {
    return _isar.deckModels.where().findAll();
  }

  @override
  Future<DeckModel> save(DeckModel model) async {
    return _isar.writeTxn(() async {
      final savedId = await _isar.deckModels.put(model);
      model.id = savedId;
      return model;
    });
  }

  @override
  Stream<List<DeckModel>> watchAll() {
    return _isar.deckModels.where().watch(fireImmediately: true);
  }
}
