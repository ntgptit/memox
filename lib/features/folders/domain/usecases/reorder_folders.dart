import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class ReorderFoldersUseCase {
  const ReorderFoldersUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> call({
    int? parentId,
    required List<int> folderIds,
  }) async {
    if (folderIds.isEmpty) {
      return const Result<void>.success(null);
    }

    try {
      await _repository.reorder(parentId: parentId, folderIds: folderIds);
      return const Result<void>.success(null);
    } catch (_) {
      return const Result.failure(
        Failure.unknown('Unable to reorder folders'),
      );
    }
  }
}
