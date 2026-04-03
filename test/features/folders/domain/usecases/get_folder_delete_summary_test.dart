import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/usecases/get_folder_delete_summary.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('returns delete summary from repository', () async {
    final useCase = GetFolderDeleteSummaryUseCase(
      FakeFolderRepository(
        deleteSummaries: {
          1: const FolderDeleteSummary(
            subfolderCount: 2,
            deckCount: 3,
            cardCount: 12,
            reviewCount: 25,
          ),
        },
      ),
    );

    final result = await useCase.call(1);

    expect(result.totalItemCount, 42);
  });
}
