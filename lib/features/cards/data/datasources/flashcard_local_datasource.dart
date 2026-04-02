import 'package:isar/isar.dart';
import 'package:memox/features/cards/data/models/flashcard_model.dart';

abstract interface class FlashcardLocalDataSource {
  Stream<List<FlashcardModel>> watchAll();

  Future<List<FlashcardModel>> getAll();

  Future<FlashcardModel> save(FlashcardModel model);

  Future<void> delete(int id);
}

final class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  const FlashcardLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.flashcardModels.delete(id);
    });
  }

  @override
  Future<List<FlashcardModel>> getAll() {
    return _isar.flashcardModels.where().findAll();
  }

  @override
  Future<FlashcardModel> save(FlashcardModel model) async {
    return _isar.writeTxn(() async {
      final savedId = await _isar.flashcardModels.put(model);
      model.id = savedId;
      return model;
    });
  }

  @override
  Stream<List<FlashcardModel>> watchAll() {
    return _isar.flashcardModels.where().watch(fireImmediately: true);
  }
}
