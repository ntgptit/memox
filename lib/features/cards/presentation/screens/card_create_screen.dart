import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/cards/presentation/widgets/card_editor_view.dart';
import 'package:memox/shared/widgets/navigation/editor_top_bar.dart';

class CardCreateScreen extends StatefulWidget {
  const CardCreateScreen({
    required this.deckId,
    this.initialMode = CardEditorMode.single,
    super.key,
  });

  static const String routeName = 'card-create';
  static const String routePath = '/decks/:deckId/cards/new';

  final int deckId;
  final CardEditorMode initialMode;

  static String routeLocation(
    int deckId, {
    CardEditorMode initialMode = CardEditorMode.single,
  }) {
    final query = initialMode == CardEditorMode.single
        ? null
        : {'mode': initialMode.name};
    return Uri(
      path: '/decks/$deckId/cards/new',
      queryParameters: query,
    ).toString();
  }

  static String batchRouteLocation(int deckId) =>
      routeLocation(deckId, initialMode: CardEditorMode.batch);

  @override
  State<CardCreateScreen> createState() => _CardCreateScreenState();
}

class _CardCreateScreenState extends State<CardCreateScreen> {
  final _editorKey = GlobalKey<_CardCreateScreenBodyState>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: EditorTopBar(
      title: context.l10n.newCardTitle,
      onClose: () => context.pop<void>(),
      onSave: () => _editorKey.currentState?.save(),
    ),
    body: CardCreateScreenBody(
      key: _editorKey,
      deckId: widget.deckId,
      initialMode: widget.initialMode,
    ),
  );
}

class CardCreateScreenBody extends StatefulWidget {
  const CardCreateScreenBody({
    required this.deckId,
    required this.initialMode,
    super.key,
  });

  final int deckId;
  final CardEditorMode initialMode;

  @override
  State<CardCreateScreenBody> createState() => _CardCreateScreenBodyState();
}

class _CardCreateScreenBodyState extends State<CardCreateScreenBody> {
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
    initialMode: widget.initialMode,
  );
}
