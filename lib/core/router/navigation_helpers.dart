import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/features/cards/presentation/providers/cards_by_deck_provider.dart';
import 'package:memox/features/decks/presentation/providers/deck_stats_provider.dart';
import 'package:memox/features/decks/presentation/screens/deck_detail_screen.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';

/// Extension on BuildContext to navigate while prefetching data.
///
/// Data starts loading immediately on tap and runs in parallel with
/// the route transition animation.
extension PrefetchNavigation on BuildContext {
  /// Navigate to DeckDetailScreen and prefetch cards plus stats.
  void pushDeckDetail(WidgetRef ref, int deckId) {
    ref
      ..read(cardsByDeckProvider(deckId))
      ..read(deckStatsProvider(deckId));
    unawaited(push(DeckDetailScreen.routeLocation(deckId)));
  }

  /// Navigate to FolderDetailScreen and prefetch folder detail.
  void pushFolderDetail(WidgetRef ref, int folderId, {int? focusDeckId}) {
    ref.read(folderDetailProvider(folderId));
    unawaited(
      push(
        FolderDetailScreen.routeLocation(folderId, focusDeckId: focusDeckId),
      ),
    );
  }
}
