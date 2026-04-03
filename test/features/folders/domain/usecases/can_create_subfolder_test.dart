import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/usecases/can_create_subfolder.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('returns true when folder has no decks', () async {
    final useCase = CanCreateSubfolderUseCase(FakeFolderRepository());

    final result = await useCase.call(1);

    expect(result, isTrue);
  });

  test('returns false when folder already has decks', () async {
    final useCase = CanCreateSubfolderUseCase(
      FakeFolderRepository(foldersWithDecks: <int>{1}),
    );

    final result = await useCase.call(1);

    expect(result, isFalse);
  });
}
