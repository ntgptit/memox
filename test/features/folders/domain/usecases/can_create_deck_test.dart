import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/usecases/can_create_deck.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('returns true when folder has no subfolders', () async {
    final useCase = CanCreateDeckUseCase(FakeFolderRepository());

    final result = await useCase.call(1);

    expect(result, isTrue);
  });

  test('returns false when folder already has subfolders', () async {
    final useCase = CanCreateDeckUseCase(
      FakeFolderRepository(
        folders: const [FolderEntity(id: 2, name: 'Child', parentId: 1)],
      ),
    );

    final result = await useCase.call(1);

    expect(result, isFalse);
  });
}
