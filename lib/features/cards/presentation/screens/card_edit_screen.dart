import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/presentation/providers/cards_by_deck_provider.dart';
import 'package:memox/features/cards/presentation/widgets/card_editor_view.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

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
      onData: (cards) {
        FlashcardEntity? card;

        for (final item in cards) {
          if (item.id == cardId) {
            card = item;
            break;
          }
        }

        if (card == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.editCardTitle)),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leadingWidth: 88,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: TextLinkButton(
          label: context.l10n.cancelAction,
          onTap: () => context.pop<void>(),
        ),
      ),
      title: Text(context.l10n.editCardTitle),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: SpacingTokens.md),
          child: Center(
            child: TextLinkButton(
              label: context.l10n.saveAction,
              onTap: () => _editorKey.currentState?.save(),
            ),
          ),
        ),
      ],
    ),
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
