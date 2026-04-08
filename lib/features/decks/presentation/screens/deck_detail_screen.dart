import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/responsive/responsive_padding.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/features/cards/presentation/providers/cards_by_deck_provider.dart';
import 'package:memox/features/cards/presentation/screens/card_create_screen.dart';
import 'package:memox/features/cards/presentation/screens/card_edit_screen.dart';
import 'package:memox/features/cards/presentation/widgets/card_list_tile.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/presentation/models/deck_card_sort.dart';
import 'package:memox/features/decks/presentation/models/deck_detail_view_state.dart';
import 'package:memox/features/decks/presentation/providers/deck_detail_provider.dart';
import 'package:memox/features/decks/presentation/widgets/create_deck_dialog.dart';
import 'package:memox/features/decks/presentation/widgets/deck_cards_toolbar.dart';
import 'package:memox/features/decks/presentation/widgets/deck_cards_toolbar_delegate.dart';
import 'package:memox/features/decks/presentation/widgets/deck_detail_header.dart';
import 'package:memox/features/decks/presentation/widgets/deck_detail_overview.dart';
import 'package:memox/features/decks/presentation/widgets/study_mode_sheet.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/buttons/app_fab.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/app_refresh_indicator.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';
import 'package:memox/shared/widgets/feedback/skeleton_parts.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';
import 'package:memox/shared/widgets/navigation/top_bar_back_button.dart';

class DeckDetailScreen extends ConsumerStatefulWidget {
  const DeckDetailScreen({required this.deckId, super.key});

  static const String routeName = 'deck-detail';
  static const String routePath = '/decks/:deckId';

  final int deckId;

  static String routeLocation(int deckId) => '/decks/$deckId';

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  static const int _cardsPageSize = 20;
  var _query = '';
  var _sort = DeckCardSort.date;
  var _showCollapsedTitle = false;
  var _visibleCardCount = _cardsPageSize;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(deckDetailProvider(widget.deckId));
    return AppAsyncBuilder<DeckDetailData>(
      value: detailAsync,
      loadingStyle: LoadingStyle.skeleton,
      onRetry: () {
        unawaited(_refreshDeckDetail());
      },
      onLoading: () => const SafeArea(
        child: Column(
          children: [
            SkeletonHeader(showProgressBar: true),
            Expanded(child: SkeletonList()),
          ],
        ),
      ),
      onData: (detail) => _buildScaffold(context, detail),
    );
  }

  // ignore: unused_element
  PreferredSizeWidget _buildLoadingAppBar(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    leadingWidth: TopBarBackButton.balancedSlotWidth,
    leading: TopBarBackButton(
      onPressed: () => Navigator.of(context).pop(),
      startPadding: context.screenType.screenPadding,
    ),
  );

  Widget _buildScaffold(BuildContext context, DeckDetailData detail) {
    final allCards = _sortedCards(_filteredCards(detail.cards));
    final cards = _visibleCards(allCards);
    final viewState = _viewState(detail);
    return AppScaffold(
      fab: AppFab(
        icon: Icons.add_outlined,
        tooltip: context.l10n.createCardAction,
        onTap: () =>
            context.push(CardCreateScreen.routeLocation(detail.deck.id)),
      ),
      applyHorizontalPadding: false,
      body: AppRefreshIndicator(
        onRefresh: _refreshDeckDetail,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) => _handleScrollNotification(
            context,
            notification,
            allCards.length,
            detail.stats.total > 0,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              DeckDetailHeader(
                deckName: detail.deck.name,
                summary: _headerSummary(context, detail, viewState),
                breadcrumb: _breadcrumbSegments(context, detail),
                masteryPercentage: detail.stats.mastery,
                showMasteryBar: detail.stats.total > 0,
                showCollapsedTitle: _showCollapsedTitle,
                onEdit: () {
                  unawaited(_editDeck(detail.deck));
                },
                onDelete: () {
                  unawaited(_deleteDeck(detail.deck.id));
                },
              ),
              DeckDetailOverview(
                stats: detail.stats,
                viewState: viewState,
                onStudyDueCards: () {
                  unawaited(_openStudy(detail.deck.id));
                },
                onChooseStudyMode: () {
                  unawaited(_openStudy(detail.deck.id));
                },
                onAddFirstCard: () {
                  unawaited(
                    context.push(
                      CardCreateScreen.routeLocation(detail.deck.id),
                    ),
                  );
                },
                onImportBatch: () {
                  unawaited(
                    context.push(
                      CardCreateScreen.batchRouteLocation(detail.deck.id),
                    ),
                  );
                },
              ),
              if (viewState != DeckDetailViewState.empty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: SpacingTokens.sm),
                ),
              if (viewState != DeckDetailViewState.empty)
                _buildToolbar(context),
              if (viewState != DeckDetailViewState.empty)
                _buildCardsSliver(context, detail, cards),
              if (cards.length < allCards.length)
                _buildLoadingMoreSliver(context),
              if (viewState != DeckDetailViewState.empty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: SpacingTokens.lg),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(
    BuildContext context,
    ScrollNotification notification,
    int totalCards,
    bool showMasteryBar,
  ) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    _maybeLoadMoreCards(notification, totalCards);

    final nextValue =
        notification.metrics.pixels >=
        _collapsedTitleThreshold(context, showMasteryBar);

    if (nextValue == _showCollapsedTitle) {
      return false;
    }

    setState(() => _showCollapsedTitle = nextValue);
    return false;
  }

  void _maybeLoadMoreCards(ScrollNotification notification, int totalCards) {
    if (_visibleCardCount >= totalCards) {
      return;
    }

    if (notification.metrics.extentAfter > SizeTokens.listItemTall * 4) {
      return;
    }

    final nextCount = math.min(_visibleCardCount + _cardsPageSize, totalCards);

    if (nextCount == _visibleCardCount) {
      return;
    }

    setState(() => _visibleCardCount = nextCount);
  }

  double _collapsedTitleThreshold(BuildContext context, bool showMasteryBar) {
    final expandedHeight = deckDetailHeaderExpandedHeight(
      context,
      showMasteryBar: showMasteryBar,
    );
    return expandedHeight - SizeTokens.appBarHeight - SpacingTokens.xl;
  }

  List<BreadcrumbSegment> _breadcrumbSegments(
    BuildContext context,
    DeckDetailData detail,
  ) => [
    BreadcrumbSegment(
      label: context.l10n.navHome,
      onTap: () => context.go(HomeScreen.routePath),
    ),
    ...detail.breadcrumb.map(
      (folder) => BreadcrumbSegment(
        label: folder.name,
        onTap: () => context.push(FolderDetailScreen.routeLocation(folder.id)),
      ),
    ),
  ];

  Widget _buildToolbar(BuildContext context) => SliverPersistentHeader(
    pinned: true,
    delegate: DeckCardsToolbarDelegate(
      height: DeckCardsToolbar.height,
      child: Padding(
        padding: ResponsivePadding.horizontal(context),
        child: DeckCardsToolbar(
          sort: _sort,
          onQueryChanged: (value) => setState(() {
            _query = value;
            _visibleCardCount = _cardsPageSize;
          }),
          onSortChanged: (value) => setState(() {
            _sort = value;
            _visibleCardCount = _cardsPageSize;
          }),
        ),
      ),
    ),
  );

  Widget _buildLoadingMoreSliver(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: ResponsivePadding.horizontal(context).add(
        const EdgeInsets.only(top: SpacingTokens.md),
      ),
      child: const LoadingIndicator(size: SizeTokens.iconSm),
    ),
  );

  Widget _buildCardsSliver(
    BuildContext context,
    DeckDetailData detail,
    List<FlashcardEntity> cards,
  ) => SliverPadding(
    padding: ResponsivePadding.horizontal(
      context,
    ).add(const EdgeInsets.only(top: SpacingTokens.md)),
    sliver: SliverList.separated(
      itemBuilder: (context, index) => CardListTile(
        card: cards[index],
        onEdit: () => context.push(
          CardEditScreen.routeLocation(detail.deck.id, cards[index].id),
        ),
        onDelete: () {
          unawaited(_deleteCard(cards[index].id));
        },
      ),
      separatorBuilder: (context, index) =>
          const SizedBox(height: SpacingTokens.md),
      itemCount: cards.length,
    ),
  );

  DeckDetailViewState _viewState(DeckDetailData detail) {
    if (detail.cards.isEmpty) {
      return DeckDetailViewState.empty;
    }

    if (detail.stats.due == 0) {
      return DeckDetailViewState.caughtUp;
    }

    return DeckDetailViewState.ready;
  }

  String _headerSummary(
    BuildContext context,
    DeckDetailData detail,
    DeckDetailViewState viewState,
  ) {
    if (viewState == DeckDetailViewState.empty) {
      return context.l10n.deckEmptySummary;
    }

    if (viewState == DeckDetailViewState.caughtUp) {
      return context.l10n.deckCaughtUpSubtitle(detail.stats.total);
    }

    return context.l10n.deckCardsDueSubtitle(
      detail.stats.total,
      detail.stats.due,
    );
  }

  List<FlashcardEntity> _filteredCards(List<FlashcardEntity> cards) {
    final normalized = _query.trim().toLowerCase();

    return cards.where((card) {
      if (normalized.isEmpty) {
        return true;
      }

      final haystack = [
        card.front,
        card.back,
        card.hint,
        card.example,
        ...card.visibleTags,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }

  List<FlashcardEntity> _visibleCards(List<FlashcardEntity> cards) {
    final clampedCount = math.min(_visibleCardCount, cards.length);
    return cards.take(clampedCount).toList();
  }

  List<FlashcardEntity> _sortedCards(List<FlashcardEntity> cards) {
    final sorted = [...cards];

    if (_sort == DeckCardSort.alpha) {
      sorted.sort((left, right) => left.front.compareTo(right.front));
      return sorted;
    }

    if (_sort == DeckCardSort.status) {
      sorted.sort(
        (left, right) => left.status.index.compareTo(right.status.index),
      );
      return sorted;
    }

    sorted.sort((left, right) {
      final now = DateTime.now();
      final leftDate = left.updatedAt ?? left.createdAt ?? now;
      final rightDate = right.updatedAt ?? right.createdAt ?? now;
      return rightDate.compareTo(leftDate);
    });
    return sorted;
  }

  Future<void> _deleteDeck(int deckId) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.deleteDeckAction,
      message: context.l10n.deleteDeckMessage,
      confirmText: context.l10n.deleteAction,
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result = await ref.read(deleteDeckUseCaseProvider).call(deckId);

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      Navigator.of(context).pop();
      return;
    }

    context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
  }

  Future<void> _editDeck(DeckEntity deck) async {
    final draft = await showCreateDeckDialog(
      context,
      initialName: deck.name,
      initialDescription: deck.description,
      initialColorValue: deck.colorValue,
      initialTags: deck.tags,
      title: context.l10n.editAction,
      submitLabel: context.l10n.saveAction,
    );

    if (draft == null || !mounted) {
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

    if (!mounted || result.isSuccess) {
      return;
    }

    context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
  }

  Future<void> _deleteCard(int cardId) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.deleteCardAction,
      message: context.l10n.deleteCardMessage,
      confirmText: context.l10n.deleteAction,
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result = await ref.read(deleteCardUseCaseProvider).call(cardId);

    if (!mounted || result.isSuccess) {
      return;
    }

    context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
  }

  Future<void> _openStudy(int deckId) async {
    final selectedMode = await showStudyModeSheet(context);

    if (selectedMode == null || !mounted) {
      return;
    }

    await context.push(StudyScreen.routeLocation(deckId, selectedMode.name));
  }

  Future<void> _refreshDeckDetail() async {
    if (mounted) {
      setState(() => _visibleCardCount = _cardsPageSize);
    }

    ref
      ..invalidate(deckByIdProvider(widget.deckId))
      ..invalidate(cardsByDeckProvider(widget.deckId))
      ..invalidate(deckDetailProvider(widget.deckId));
    final deck = await ref.read(deckByIdProvider(widget.deckId).future);
    await ref.read(cardsByDeckProvider(widget.deckId).future);

    if (deck != null) {
      ref.invalidate(folderBreadcrumbProvider(deck.folderId));
      await ref.read(folderBreadcrumbProvider(deck.folderId).future);
    }
  }
}
