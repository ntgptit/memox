import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class DeleteFolderUseCase {
  const DeleteFolderUseCase({
    required FolderRepository folderRepo,
    required AppLogger logger,
  })  : _folderRepo = folderRepo,
        _logger = logger;

  final FolderRepository _folderRepo;
  final AppLogger _logger;

  Future<Result<void>> call(int folderId) async {
    try {
      await _folderRepo.delete(folderId);
      _logger.info('Folder deleted: $folderId');
      return const Result<void>.success(null);
    } catch (_) {
      return const Result.failure(Failure.unknown('Unable to delete folder'));
    }
  }
}
