import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class DeleteFolderUseCase {
  const DeleteFolderUseCase({
    required FolderRepository folderRepo,
    required AppLogger logger,
  }) : _folderRepo = folderRepo,
       _logger = logger;

  final FolderRepository _folderRepo;
  final AppLogger _logger;

  Future<Result<FolderDeleteSummary>> call(int folderId) async {
    try {
      final deletedSummary = await _folderRepo.deleteCascade(folderId);
      _logger.info('Folder deleted: $folderId');
      return Result<FolderDeleteSummary>.success(deletedSummary);
    } catch (_) {
      return const Result.failure(
        Failure.unknown('Unable to delete folder'),
      );
    }
  }
}
