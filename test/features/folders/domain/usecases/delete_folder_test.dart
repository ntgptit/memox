import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/usecases/delete_folder.dart';
import '../../../../test_helpers/fakes/fake_folder_repository.dart';

void main() {
  test('returns success and delete summary when repository deletes', () async {
    final repository = FakeFolderRepository(
      deleteSummaries: {
        1: const FolderDeleteSummary(
          subfolderCount: 1,
          deckCount: 2,
          cardCount: 8,
          reviewCount: 13,
        ),
      },
    );
    final useCase = DeleteFolderUseCase(
      folderRepo: repository,
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(1);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.deckCount, 2);
    expect(repository.deletedFolderIds, <int>[1]);
  });

  test('returns failure when repository throws', () async {
    final useCase = DeleteFolderUseCase(
      folderRepo: FakeFolderRepository(throwOnDelete: true),
      logger: const LoggerImpl(),
    );

    final result = await useCase.call(1);

    expect(result.isFailure, isTrue);
  });
}
