import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class GetDecksByFolderUseCase {
  const GetDecksByFolderUseCase(this._repository);

  final DeckRepository _repository;

  Stream<List<DeckEntity>> call(int folderId) =>
      _repository.watchByFolder(folderId);
}
