import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/folders/presentation/widgets/create_folder_dialog.dart';
import 'package:memox/features/folders/presentation/widgets/delete_folder_confirm_dialog.dart';
import 'package:memox/features/folders/presentation/widgets/folder_list_view.dart';
import 'package:memox/features/folders/presentation/widgets/home_greeting_card.dart';
import 'package:memox/features/search/presentation/screens/search_screen.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:memox/shared/widgets/buttons/app_fab.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/app_refresh_indicator.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/lists/reorder_mode_banner.dart';
import 'package:memox/shared/widgets/navigation/app_root_bottom_nav.dart';
import 'package:memox/shared/widgets/navigation/top_bar_action_row.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = 'home';
  static const String routePath = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _isSortMode = false;

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(foldersProvider);
    final dueSummary = ref.watch(homeDueSummaryProvider);
    final folders = _asyncValueOrNull(foldersAsync) ?? const <FolderEntity>[];
    final showSortAction = folders.isNotEmpty;

    return AppScaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actionsPadding: EdgeInsets.zero,
        actions: _buildAppBarActions(context, showSortAction),
      ),
      fab: AppFab(
        icon: Icons.add_outlined,
        tooltip: context.l10n.createFolder,
        onTap: () {
          unawaited(_createRootFolder(context, ref));
        },
      ),
      bottomNavigationBar: const AppRootBottomNav(currentIndex: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeGreetingCard(
            summary: dueSummary,
            onRetry: () {
              unawaited(_refreshHomeData(ref));
            },
            onReviewNow: (deck) => context.push(
              FolderDetailScreen.routeLocation(
                deck.folderId,
                focusDeckId: deck.id,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sectionGap),
          Expanded(
            child: AppAsyncBuilder<List<FolderEntity>>(
              value: foldersAsync,
              onRetry: () {
                unawaited(_refreshHomeData(ref));
              },
              onData: (folders) => _HomeFolderSection(
                folders: folders,
                isSortMode: _isSortMode,
                onRefresh: () => _refreshHomeData(ref),
                onTap: (folder) =>
                    context.push(FolderDetailScreen.routeLocation(folder.id)),
                onEdit: (folder) {
                  unawaited(_editFolder(context, ref, folder));
                },
                onDelete: (folder) {
                  unawaited(_deleteFolder(context, ref, folder.id));
                },
                onReorder: (oldIndex, newIndex) {
                  unawaited(
                    _reorderRootFolders(ref, folders, oldIndex, newIndex),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSortMode() {
    setState(() {
      _isSortMode = !_isSortMode;
    });
  }

  List<Widget> _buildAppBarActions(BuildContext context, bool showSortAction) =>
      [
        TopBarActionRow(
          children: [
            if (showSortAction)
              TopBarIconButton(
                tooltip: _isSortMode
                    ? context.l10n.doneAction
                    : context.l10n.reorderAction,
                onPressed: _toggleSortMode,
                icon: _isSortMode
                    ? Icons.check_outlined
                    : Icons.drag_indicator_outlined,
                alignment: Alignment.centerRight,
              ),
            TopBarIconButton(
              tooltip: context.l10n.searchAction,
              onPressed: () => context.push(SearchScreen.routePath),
              icon: Icons.search_outlined,
              alignment: Alignment.centerRight,
            ),
            TopBarIconButton(
              tooltip: context.l10n.profileAction,
              onPressed: () => context.go(SettingsScreen.routePath),
              icon: Icons.account_circle_outlined,
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ];
}

class _HomeFolderSection extends StatelessWidget {
  const _HomeFolderSection({
    required this.folders,
    required this.isSortMode,
    required this.onRefresh,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final List<FolderEntity> folders;
  final bool isSortMode;
  final RefreshCallback onRefresh;
  final ValueChanged<FolderEntity> onTap;
  final ValueChanged<FolderEntity> onEdit;
  final ValueChanged<FolderEntity> onDelete;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return AppRefreshScrollView(
        onRefresh: onRefresh,
        child: EmptyStateView(
          icon: Icons.folder_open_outlined,
          title: context.l10n.homeFoldersEmptyTitle,
          subtitle: context.l10n.homeFoldersEmptySubtitle,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.folderSectionTitle.toUpperCase(),
                style: context.appTextStyles.sectionLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        if (isSortMode) ...[
          const ReorderModeBanner(),
          const SizedBox(height: SpacingTokens.md),
        ],
        Expanded(
          child: FolderListView(
            folders: folders,
            isSortMode: isSortMode,
            onRefresh: onRefresh,
            onTap: onTap,
            onEdit: onEdit,
            onDelete: onDelete,
            onReorder: onReorder,
          ),
        ),
      ],
    );
  }
}

Future<void> _createRootFolder(BuildContext context, WidgetRef ref) async {
  final draft = await showCreateFolderDialog(context);

  if (draft == null || !context.mounted) {
    return;
  }

  final result = await ref
      .read(createFolderUseCaseProvider)
      .call(name: draft.name, colorValue: draft.colorValue);

  if (!context.mounted) {
    return;
  }

  if (result.isFailure) {
    context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
  }
}

Future<void> _editFolder(
  BuildContext context,
  WidgetRef ref,
  FolderEntity folder,
) async {
  final draft = await showCreateFolderDialog(
    context,
    initialName: folder.name,
    initialColorValue: folder.colorValue,
    title: context.l10n.editFolder,
    submitLabel: context.l10n.saveAction,
  );

  if (draft == null || !context.mounted) {
    return;
  }

  final result = await ref
      .read(updateFolderUseCaseProvider)
      .call(id: folder.id, name: draft.name, colorValue: draft.colorValue);

  if (!context.mounted || result.isSuccess) {
    return;
  }

  context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
}

Future<void> _deleteFolder(
  BuildContext context,
  WidgetRef ref,
  int folderId,
) async {
  ref.invalidate(folderDeleteSummaryProvider(folderId));
  final summary = await ref.read(folderDeleteSummaryProvider(folderId).future);

  if (!context.mounted) {
    return;
  }

  final confirmed = await showDeleteFolderConfirmDialog(
    context,
    summary: summary,
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  final result = await ref.read(deleteFolderUseCaseProvider).call(folderId);

  if (!context.mounted || result.isSuccess) {
    return;
  }

  context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
}

Future<void> _reorderRootFolders(
  WidgetRef ref,
  List<FolderEntity> folders,
  int oldIndex,
  int newIndex,
) async {
  final reordered = [...folders];
  final moved = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, moved);
  await ref
      .read(reorderFoldersUseCaseProvider)
      .call(folderIds: reordered.map((folder) => folder.id).toList());
}

T? _asyncValueOrNull<T>(AsyncValue<T> value) => switch (value) {
  AsyncData<T>(:final value) => value,
  _ => null,
};

Future<void> _refreshHomeData(WidgetRef ref) async {
  ref
    ..invalidate(foldersProvider)
    ..invalidate(allDecksProvider)
    ..invalidate(allFlashcardsProvider)
    ..invalidate(homeDueSummaryProvider);
  await Future.wait<Object?>([
    ref.read(foldersProvider.future),
    ref.read(allDecksProvider.future),
    ref.read(allFlashcardsProvider.future),
  ]);
}
