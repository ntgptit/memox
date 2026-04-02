import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folders_provider.g.dart';

@riverpod
String foldersScreenTitle(Ref ref) => AppStrings.foldersTitle;

@riverpod
Stream<List<FolderEntity>> rootFolders(Ref ref) {
  return ref.watch(getFoldersUseCaseProvider).call();
}
