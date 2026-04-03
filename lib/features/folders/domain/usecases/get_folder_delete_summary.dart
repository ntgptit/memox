import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';

final class GetFolderDeleteSummaryUseCase {
  const GetFolderDeleteSummaryUseCase(this._repository);

  final FolderRepository _repository;

  Future<FolderDeleteSummary> call(int folderId) {
    return _repository.getDeleteSummary(folderId);
  }
}
