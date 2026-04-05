import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/presentation/screens/deck_detail_screen.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';
import 'package:memox/features/search/presentation/widgets/search_result_tile.dart';

class SearchResultList extends StatelessWidget {
  const SearchResultList({required this.results, super.key});

  final List<SearchResultItem> results;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.xl,
    ),
    itemCount: results.length,
    itemBuilder: (context, index) {
      final item = results[index];
      return SearchResultTile(
        item: item,
        onTap: () => _navigateTo(context, item),
        showDivider: index < results.length - 1,
      );
    },
  );

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
