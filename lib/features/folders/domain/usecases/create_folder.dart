import 'package:memox/core/guards/preconditions.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class CreateFolderUseCase {
  const CreateFolderUseCase({
    required FolderRepository folderRepo,
    required AppLogger logger,
  }) : _folderRepo = folderRepo,
       _logger = logger;

  final FolderRepository _folderRepo;
  final AppLogger _logger;

  Future<Result<FolderEntity>> call({
    required String name,
    int? parentId,
    required int colorValue,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return const Result.failure(
        Failure.validation('Folder name must not be empty'),
      );
    }

    Preconditions.requireNotEmpty(trimmedName, name: 'name');
    final siblings = parentId == null
        ? await _folderRepo.getRootFolders()
        : await _folderRepo.getSubfolders(parentId);
    final duplicateExists = siblings.any((FolderEntity folder) {
      return folder.name.trim().toLowerCase() == trimmedName.toLowerCase();
    });

    if (duplicateExists) {
      return const Result.failure(
        Failure.conflict('A folder with this name already exists here'),
      );
    }

    final saved = await _folderRepo.create(
      name: trimmedName,
      parentId: parentId,
      colorValue: colorValue,
    );
    _logger.info('Folder created: ${saved.id}');
    return Result.success(saved);
  }
}
