import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/presentation/screens/deck_detail_screen.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';
import 'package:memox/features/search/presentation/widgets/search_result_tile.dart';

class SearchResultList extends StatelessWidget {
  const SearchResultList({required this.results, super.key});

  final List<SearchResultItem> results;

  @override
  Widget build(BuildContext context) {
    final folders = results.whereType<FolderResult>().toList();
    final decks = results.whereType<DeckResult>().toList();
    final cards = results.whereType<CardResult>().toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xxxl),
      children: [
        if (folders.isNotEmpty)
          _SearchSection(
            title: context.l10n.foldersTitle,
            items: folders,
            onTap: (item) => _navigateTo(context, item),
          ),
        if (decks.isNotEmpty)
          _SearchSection(
            title: context.l10n.decksTitle,
            items: decks,
            onTap: (item) => _navigateTo(context, item),
          ),
        if (cards.isNotEmpty)
          _SearchSection(
            title: context.l10n.cardsTitle,
            items: cards,
            onTap: (item) => _navigateTo(context, item),
          ),
      ],
    );
  }

  void _navigateTo(BuildContext context, SearchResultItem item) {
    switch (item) {
      case FolderResult(:final id):
        unawaited(context.push(FolderDetailScreen.routeLocation(id)));
      case DeckResult(:final id):
        unawaited(context.push(DeckDetailScreen.routeLocation(id)));
      case CardResult(:final deckId):
        unawaited(context.push(DeckDetailScreen.routeLocation(deckId)));
    }
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<SearchResultItem> items;
  final ValueChanged<SearchResultItem> onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Text(title, style: context.textTheme.titleMedium),
        ),
        ...List<Widget>.generate(
          items.length,
          (index) => SearchResultTile(
            item: items[index],
            onTap: () => onTap(items[index]),
            showDivider: index < items.length - 1,
          ),
        ),
      ],
    ),
  );
}
