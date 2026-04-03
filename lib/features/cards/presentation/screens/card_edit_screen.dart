import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/presentation/providers/cards_by_deck_provider.dart';
import 'package:memox/features/cards/presentation/widgets/card_editor_view.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/editor_top_bar.dart';

class CardEditScreen extends ConsumerWidget {
  const CardEditScreen({required this.deckId, required this.cardId, super.key});

  static const String routeName = 'card-edit';
  static const String routePath = '/decks/:deckId/cards/:cardId/edit';

  final int deckId;
  final int cardId;

  static String routeLocation(int deckId, int cardId) =>
      '/decks/$deckId/cards/$cardId/edit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsByDeckProvider(deckId));
    return AppAsyncBuilder<List<FlashcardEntity>>(
      value: cardsAsync,
      onRetry: () {
        unawaited(_refreshCards(ref, deckId));
      },
      onData: (cards) {
        FlashcardEntity? card;

        for (final item in cards) {
          if (item.id == cardId) {
            card = item;
            break;
          }
        }

        if (card == null) {
          return AppScaffold(
            appBar: EditorTopBar(
              title: context.l10n.editCardTitle,
              onClose: () => context.pop<void>(),
            ),
            applyHorizontalPadding: false,
            body: EmptyStateView(
              icon: Icons.style_outlined,
              title: context.l10n.cardMissingTitle,
              subtitle: context.l10n.cardMissingSubtitle,
            ),
          );
        }

        return _CardEditScaffold(deckId: deckId, card: card);
      },
    );
  }
}

class _CardEditScaffold extends StatefulWidget {
  const _CardEditScaffold({required this.deckId, required this.card});

  final int deckId;
  final FlashcardEntity card;

  @override
  State<_CardEditScaffold> createState() => _CardEditScaffoldState();
}

class _CardEditScaffoldState extends State<_CardEditScaffold> {
  final _editorKey = GlobalKey<_CardEditBodyState>();

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: EditorTopBar(
      title: context.l10n.editCardTitle,
      onClose: () => context.pop<void>(),
      onSave: () => _editorKey.currentState?.save(),
    ),
    applyHorizontalPadding: false,
    body: CardEditBody(
      key: _editorKey,
      deckId: widget.deckId,
      card: widget.card,
    ),
  );
}

class CardEditBody extends StatefulWidget {
  const CardEditBody({required this.deckId, required this.card, super.key});

  final int deckId;
  final FlashcardEntity card;

  @override
  State<CardEditBody> createState() => _CardEditBodyState();
}

class _CardEditBodyState extends State<CardEditBody> {
  final _editorViewKey = GlobalKey<CardEditorViewState>();

  Future<void> save() async {
    final shouldPop = await _editorViewKey.currentState?.save() ?? false;

    if (shouldPop && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => CardEditorView(
    key: _editorViewKey,
    deckId: widget.deckId,
    initialCard: widget.card,
  );
}

Future<void> _refreshCards(WidgetRef ref, int deckId) async {
  ref.invalidate(cardsByDeckProvider(deckId));
  await ref.read(cardsByDeckProvider(deckId).future);
}
