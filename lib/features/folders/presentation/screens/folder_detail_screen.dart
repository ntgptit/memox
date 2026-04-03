import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/presentation/screens/deck_detail_screen.dart';
import 'package:memox/features/decks/presentation/widgets/create_deck_dialog.dart';
import 'package:memox/features/decks/presentation/widgets/deck_list_view.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/features/folders/presentation/widgets/create_folder_dialog.dart';
import 'package:memox/features/folders/presentation/widgets/delete_folder_confirm_dialog.dart';
import 'package:memox/features/folders/presentation/widgets/folder_constraint_footer.dart';
import 'package:memox/features/folders/presentation/widgets/folder_detail_app_bar_title.dart';
import 'package:memox/features/folders/presentation/widgets/folder_list_view.dart';
import 'package:memox/features/folders/presentation/widgets/folder_status_bar.dart';
import 'package:memox/features/folders/presentation/widgets/folder_type_chooser_sheet.dart';
import 'package:memox/shared/widgets/buttons/app_fab.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/lists/reorder_mode_banner.dart';
import 'package:memox/shared/widgets/navigation/top_bar_action_row.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';

class FolderDetailScreen extends ConsumerStatefulWidget {
  const FolderDetailScreen({
    required this.folderId,
    this.focusDeckId,
    super.key,
  });

  static const String routeName = 'folder-detail';
  static const String routePath = '/folders/:folderId';

  final int folderId;
  final int? focusDeckId;

  static String routeLocation(int folderId, {int? focusDeckId}) {
    final query = focusDeckId == null ? null : {'deck': '$focusDeckId'};
    return Uri(path: '/folders/$folderId', queryParameters: query).toString();
  }

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  var _isSortMode = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(folderDetailProvider(widget.folderId));
    final breadcrumbAsync = ref.watch(
      folderBreadcrumbProvider(widget.folderId),
    );
    final breadcrumb =
        _asyncValueOrNull(breadcrumbAsync) ?? const <FolderEntity>[];

    return AppAsyncBuilder<FolderDetailData>(
      value: detailAsync,
      onData: (detail) => AppScaffold(
        appBar: _buildAppBar(context, breadcrumb, detail),
        fab: AppFab(
          icon: Icons.add_outlined,
          tooltip: _folderFabLabel(context, detail.contentType),
          onTap: () {
            unawaited(_handleFab(context, ref, detail));
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FolderStatusBar(detail: detail),
            const SizedBox(height: SpacingTokens.lg),
            if (_isSortMode) ...[
              ReorderModeBanner(onDone: _toggleSortMode),
              const SizedBox(height: SpacingTokens.lg),
            ],
            Expanded(
              child: _FolderContent(
                detail: detail,
                focusDeckId: widget.focusDeckId,
                isSortMode: _isSortMode,
              ),
            ),
            FolderConstraintFooter(
              contentType: detail.contentType,
              depth: breadcrumb.length,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSortMode() {
    setState(() {
      _isSortMode = !_isSortMode;
    });
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    List<FolderEntity> breadcrumb,
    FolderDetailData detail,
  ) => AppBar(
    title: FolderDetailAppBarTitle(
      title: detail.folder.name,
      breadcrumb: breadcrumb,
    ),
    actionsPadding: EdgeInsets.zero,
    actions: [
      TopBarActionRow(
        children: [
          if (_canSort(detail))
            TopBarIconButton(
              tooltip: _isSortMode
                  ? context.l10n.doneAction
                  : context.l10n.reorderAction,
              onPressed: _toggleSortMode,
              icon: _isSortMode
                  ? Icons.done_outline
                  : Icons.drag_indicator_outlined,
              alignment: Alignment.centerRight,
            ),
          TopBarIconButton(
            tooltip: context.l10n.editFolder,
            onPressed: () {
              unawaited(_editFolder(context, ref, detail.folder));
            },
            icon: Icons.edit_outlined,
            alignment: Alignment.centerRight,
          ),
          TopBarIconButton(
            tooltip: context.l10n.deleteFolder,
            onPressed: () {
              unawaited(_deleteCurrentFolder(context, ref, widget.folderId));
            },
            icon: Icons.delete_outline,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    ],
  );
}

class _FolderContent extends ConsumerWidget {
  const _FolderContent({
    required this.detail,
    required this.focusDeckId,
    required this.isSortMode,
  });

  final FolderDetailData detail;
  final int? focusDeckId;
  final bool isSortMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (detail.contentType == ContentType.empty) {
      return EmptyStateView(
        icon: Icons.folder_open_outlined,
        title: context.l10n.folderEmptyTitle,
        subtitle: context.l10n.folderEmptySubtitle,
      );
    }

    if (detail.contentType == ContentType.subfolders) {
      return FolderListView(
        folders: detail.subfolders,
        isSortMode: isSortMode,
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
            _reorderSubfolders(
              ref,
              detail.subfolders,
              detail.folder.id,
              oldIndex,
              newIndex,
            ),
          );
        },
      );
    }

    return DeckListView(
      decks: detail.decks,
      isSortMode: isSortMode,
      highlightedDeckId: focusDeckId,
      onTap: (deck) => context.push(DeckDetailScreen.routeLocation(deck.id)),
      onEdit: (deck) {
        unawaited(_editDeck(context, ref, deck));
      },
      onDelete: (deck) {
        unawaited(_deleteDeck(context, ref, deck.id));
      },
      onReorder: (oldIndex, newIndex) {
        unawaited(
          _reorderDecks(
            ref,
            detail.decks,
            detail.folder.id,
            oldIndex,
            newIndex,
          ),
        );
      },
    );
  }
}

Future<void> _handleFab(
  BuildContext context,
  WidgetRef ref,
  FolderDetailData detail,
) async {
  final choice = await _resolveCreationKind(context, detail.contentType);

  if (choice == null || !context.mounted) {
    return;
  }

  if (choice == FolderCreationKind.subfolder) {
    final draft = await showCreateFolderDialog(
      context,
      initialColorValue: detail.folder.colorValue,
    );

    if (draft == null || !context.mounted) {
      return;
    }

    final result = await ref
        .read(createFolderUseCaseProvider)
        .call(
          name: draft.name,
          parentId: detail.folder.id,
          colorValue: draft.colorValue,
        );

    if (!context.mounted || result.isSuccess) {
      return;
    }

    context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
    return;
  }

  final draft = await showCreateDeckDialog(
    context,
    initialColorValue: detail.folder.colorValue,
  );

  if (draft == null || !context.mounted) {
    return;
  }

  final result = await ref
      .read(createDeckUseCaseProvider)
      .call(
        name: draft.name,
        folderId: detail.folder.id,
        description: draft.description,
        colorValue: draft.colorValue,
        tags: draft.tags,
      );

  if (!context.mounted || result.isSuccess) {
    return;
  }

  context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
}

Future<void> _editDeck(
  BuildContext context,
  WidgetRef ref,
  DeckEntity deck,
) async {
  final draft = await showCreateDeckDialog(
    context,
    initialName: deck.name,
    initialDescription: deck.description,
    initialColorValue: deck.colorValue,
    initialTags: deck.tags,
    title: context.l10n.editAction,
    submitLabel: context.l10n.saveAction,
  );

  if (draft == null || !context.mounted) {
    return;
  }

  final result = await ref
      .read(updateDeckUseCaseProvider)
      .call(
        id: deck.id,
        name: draft.name,
        description: draft.description,
        colorValue: draft.colorValue,
        tags: draft.tags,
      );

  if (!context.mounted || result.isSuccess) {
    return;
  }

  context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
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

Future<void> _deleteDeck(
  BuildContext context,
  WidgetRef ref,
  int deckId,
) async {
  final confirmed = await context.showConfirmDialog(
    title: context.l10n.deleteDeckAction,
    message: context.l10n.deleteDeckMessage,
    confirmText: context.l10n.deleteAction,
    isDestructive: true,
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  final result = await ref.read(deleteDeckUseCaseProvider).call(deckId);

  if (!context.mounted || result.isSuccess) {
    return;
  }

  context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
}

Future<FolderCreationKind?> _resolveCreationKind(
  BuildContext context,
  ContentType contentType,
) async {
  if (contentType == ContentType.subfolders) {
    return FolderCreationKind.subfolder;
  }

  if (contentType == ContentType.decks) {
    return FolderCreationKind.deck;
  }

  return showFolderTypeChooserSheet(context);
}

Future<void> _deleteCurrentFolder(
  BuildContext context,
  WidgetRef ref,
  int folderId,
) async {
  final deleted = await _deleteFolder(context, ref, folderId);

  if (!context.mounted || !deleted) {
    return;
  }

  Navigator.of(context).pop();
}

Future<bool> _deleteFolder(
  BuildContext context,
  WidgetRef ref,
  int folderId,
) async {
  ref.invalidate(folderDeleteSummaryProvider(folderId));
  final summary = await ref.read(folderDeleteSummaryProvider(folderId).future);

  if (!context.mounted) {
    return false;
  }

  final confirmed = await showDeleteFolderConfirmDialog(
    context,
    summary: summary,
  );

  if (confirmed != true || !context.mounted) {
    return false;
  }

  final result = await ref.read(deleteFolderUseCaseProvider).call(folderId);

  if (!context.mounted || result.isSuccess) {
    return result.isSuccess;
  }

  context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
  return false;
}

Future<void> _reorderSubfolders(
  WidgetRef ref,
  List<FolderEntity> folders,
  int parentId,
  int oldIndex,
  int newIndex,
) async {
  final reordered = [...folders];
  final moved = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, moved);
  await ref
      .read(reorderFoldersUseCaseProvider)
      .call(
        parentId: parentId,
        folderIds: reordered.map((folder) => folder.id).toList(),
      );
}

Future<void> _reorderDecks(
  WidgetRef ref,
  List<DeckEntity> decks,
  int folderId,
  int oldIndex,
  int newIndex,
) async {
  final reordered = [...decks];
  final moved = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, moved);
  await ref
      .read(reorderDecksUseCaseProvider)
      .call(
        folderId: folderId,
        deckIds: reordered.map((deck) => deck.id).toList(),
      );
}

T? _asyncValueOrNull<T>(AsyncValue<T> value) => switch (value) {
  AsyncData<T>(:final value) => value,
  _ => null,
};

String _folderFabLabel(BuildContext context, ContentType contentType) =>
    switch (contentType) {
      ContentType.subfolders => context.l10n.createSubfolder,
      ContentType.decks => context.l10n.createDeck,
      ContentType.empty => context.l10n.createAction,
    };

bool _canSort(FolderDetailData detail) {
  if (detail.contentType == ContentType.subfolders) {
    return detail.subfolders.isNotEmpty;
  }

  if (detail.contentType == ContentType.decks) {
    return detail.decks.isNotEmpty;
  }

  return false;
}
