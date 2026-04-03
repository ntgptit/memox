import 'package:memox/core/guards/preconditions.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class UpdateFolderUseCase {
  const UpdateFolderUseCase({
    required FolderRepository folderRepo,
    required AppLogger logger,
  }) : _folderRepo = folderRepo,
       _logger = logger;

  final FolderRepository _folderRepo;
  final AppLogger _logger;

  Future<Result<FolderEntity>> call({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return const Result.failure(
        Failure.validation('Folder name must not be empty'),
      );
    }

    Preconditions.requireNotEmpty(trimmedName, name: 'name');
    final existingFolder = await _folderRepo.getById(id);

    if (existingFolder == null) {
      return const Result.failure(Failure.notFound('Folder not found'));
    }

    final siblings = existingFolder.parentId == null
        ? await _folderRepo.getRootFolders()
        : await _folderRepo.getSubfolders(existingFolder.parentId!);
    final duplicateExists = siblings.any(
      (FolderEntity folder) =>
          folder.id != id &&
          folder.name.trim().toLowerCase() == trimmedName.toLowerCase(),
    );

    if (duplicateExists) {
      return const Result.failure(
        Failure.conflict('A folder with this name already exists here'),
      );
    }

    final saved = await _folderRepo.update(
      id: id,
      name: trimmedName,
      colorValue: colorValue,
    );
    _logger.info('Folder updated: ${saved.id}');
    return Result.success(saved);
  }
}
