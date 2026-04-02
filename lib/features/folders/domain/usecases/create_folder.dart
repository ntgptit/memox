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

  Future<Result<FolderEntity>> call(String name) async {
    if (name.trim().isEmpty) {
      return const Result.failure(Failure.validation('name must not be empty'));
    }

    Preconditions.requireNotEmpty(name, name: 'name');
    final saved = await _folderRepo.save(FolderEntity(id: 0, name: name));
    _logger.info('Folder created: ${saved.id}');
    return Result.success(saved);
  }
}
