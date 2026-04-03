import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deck_stats_provider.g.dart';

@riverpod
Future<DeckStats> deckStats(Ref ref, int deckId) {
  return ref.watch(getDeckStatsUseCaseProvider).call(deckId);
}
