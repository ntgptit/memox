import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/card_batch_parse_result.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/inputs/app_text_field.dart';
import 'package:memox/shared/widgets/inputs/tag_input_field.dart';

enum CardEditorMode { single, batch }

class CardEditorView extends ConsumerStatefulWidget {
  const CardEditorView({
    required this.deckId,
    this.initialCard,
    this.initialMode = CardEditorMode.single,
    super.key,
  });

  final int deckId;
  final FlashcardEntity? initialCard;
  final CardEditorMode initialMode;

  bool get isEditing => initialCard != null;

  @override
  ConsumerState<CardEditorView> createState() => CardEditorViewState();
}

class CardEditorViewState extends ConsumerState<CardEditorView> {
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  late final TextEditingController _hintController;
  late final TextEditingController _exampleController;
  late final TextEditingController _batchController;
  late List<String> _tags;
  late CardEditorMode _mode;
  var _showDetails = false;
  var _addAnother = false;
  var _separator = '\t';
  String? _frontError;
  String? _backError;

  @override
  void initState() {
    super.initState();
    final card = widget.initialCard;
    _frontController = TextEditingController(text: card?.front);
    _backController = TextEditingController(text: card?.back);
    _hintController = TextEditingController(text: card?.hint);
    _exampleController = TextEditingController(text: card?.example);
    _batchController = TextEditingController();
    _tags = [...?card?.tags];
    _mode = widget.isEditing ? CardEditorMode.single : widget.initialMode;
    _showDetails =
        (card?.hint.isNotEmpty ?? false) ||
        (card?.example.isNotEmpty ?? false) ||
        (card?.tags.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _hintController.dispose();
    _exampleController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  CardBatchParseResult get _preview => ref
      .read(createCardsBatchUseCaseProvider)
      .preview(
        rawText: _batchController.text,
        separator: _separator,
        deckId: widget.deckId,
      );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(SpacingTokens.lg),
    children: [
      if (!widget.isEditing) _ModeSelector(mode: _mode, onChanged: _setMode),
      if (!widget.isEditing) const SizedBox(height: SpacingTokens.fieldGap),
      if (_mode == CardEditorMode.single) ...[
        AppTextField(
          controller: _frontController,
          label: context.l10n.cardFrontLabel,
          hint: context.l10n.cardFrontHint,
          error: _frontError,
          maxLines: 3,
          onChanged: (_) => setState(() => _frontError = null),
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        AppTextField(
          controller: _backController,
          label: context.l10n.cardBackLabel,
          hint: context.l10n.cardBackHint,
          error: _backError,
          maxLines: 4,
          onChanged: (_) => setState(() => _backError = null),
        ),
        const SizedBox(height: SpacingTokens.md),
        Align(
          alignment: Alignment.centerLeft,
          child: TextLinkButton(
            label: context.l10n.addMoreDetailsAction,
            onTap: () => setState(() => _showDetails = !_showDetails),
          ),
        ),
        if (_showDetails) ...[
          AppTextField(
            controller: _hintController,
            label: context.l10n.cardHintLabel,
            hint: context.l10n.cardHintHint,
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.fieldGap),
          AppTextField(
            controller: _exampleController,
            label: context.l10n.cardExampleLabel,
            hint: context.l10n.cardExampleHint,
            maxLines: 3,
          ),
          const SizedBox(height: SpacingTokens.fieldGap),
          Text(context.l10n.cardTagsLabel, style: context.textTheme.labelLarge),
          const SizedBox(height: SpacingTokens.sm),
          TagInputField(
            tags: _tags,
            suggestions: const <String>[],
            onChanged: (tags) => setState(() => _tags = tags),
          ),
        ],
        if (!widget.isEditing) ...[
          const SizedBox(height: SpacingTokens.fieldGap),
          SwitchListTile.adaptive(
            value: _addAnother,
            onChanged: (value) => setState(() => _addAnother = value),
            title: Text(context.l10n.addAnotherAction),
          ),
        ],
      ],
      if (_mode == CardEditorMode.batch) ...[
        _BatchEditorSection(
          controller: _batchController,
          separator: _separator,
          preview: _preview,
          onBatchChanged: () => setState(() {}),
          onSeparatorChanged: _setSeparator,
        ),
      ],
    ],
  );

  void _setMode(CardEditorMode mode) {
    setState(() => _mode = mode);
  }

  void _setSeparator(String value) {
    setState(() => _separator = value);
  }

  Future<bool> save() async {
    if (_mode == CardEditorMode.batch) {
      final result = await ref
          .read(createCardsBatchUseCaseProvider)
          .call(
            rawText: _batchController.text,
            separator: _separator,
            deckId: widget.deckId,
          );

      if (!mounted || result.isFailure) {
        return false;
      }

      final summary = result.dataOrNull!;

      if (summary.parsed.isEmpty) {
        context.showSnackBar(
          context.l10n.batchNoValidCardsError,
          isError: true,
        );
        return false;
      }

      if (summary.errors.isNotEmpty) {
        context.showSnackBar(
          context.l10n.batchSaveSummary(
            summary.parsed.length,
            summary.errors.length,
          ),
        );
      }

      return true;
    }

    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    _frontError = front.isEmpty ? context.l10n.cardFrontEmptyError : null;
    _backError = back.isEmpty ? context.l10n.cardBackEmptyError : null;
    setState(() {});

    if (_frontError != null || _backError != null) {
      return false;
    }

    if (widget.isEditing) {
      final result = await ref
          .read(updateCardUseCaseProvider)
          .call(
            id: widget.initialCard!.id,
            front: front,
            back: back,
            hint: _hintController.text,
            example: _exampleController.text,
            tags: _tags,
          );
      if (!mounted || result.isSuccess) {
        return result.isSuccess;
      }

      context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
      return result.isSuccess;
    }

    final result = await ref
        .read(createCardUseCaseProvider)
        .call(
          deckId: widget.deckId,
          front: front,
          back: back,
          hint: _hintController.text,
          example: _exampleController.text,
          tags: _tags,
        );

    if (!mounted || result.isSuccess) {
      if (!result.isSuccess) {
        return false;
      }

      if (_addAnother) {
        _frontController.clear();
        _backController.clear();
        _hintController.clear();
        _exampleController.clear();
        setState(() => _tags = <String>[]);
        return false;
      }

      return true;
    }

    context.showSnackBar(result.failureOrNull?.message ?? '', isError: true);
    return false;
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onChanged});

  final CardEditorMode mode;
  final ValueChanged<CardEditorMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<CardEditorMode>(
    showSelectedIcon: false,
    segments: [
      ButtonSegment(
        value: CardEditorMode.single,
        label: Text(context.l10n.singleModeLabel),
      ),
      ButtonSegment(
        value: CardEditorMode.batch,
        label: Text(context.l10n.batchModeLabel),
      ),
    ],
    selected: {mode},
    onSelectionChanged: (selection) => onChanged(selection.first),
  );
}

class _BatchEditorSection extends StatelessWidget {
  const _BatchEditorSection({
    required this.controller,
    required this.separator,
    required this.preview,
    required this.onBatchChanged,
    required this.onSeparatorChanged,
  });

  static const int _compactInputLines = 8;
  static const int _regularInputLines = 10;

  final TextEditingController controller;
  final String separator;
  final CardBatchParseResult preview;
  final VoidCallback onBatchChanged;
  final ValueChanged<String> onSeparatorChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppTextField(
        controller: controller,
        label: context.l10n.batchCardsLabel,
        hint: context.l10n.batchCardsHint,
        maxLines: context.isCompact ? _compactInputLines : _regularInputLines,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        onChanged: (_) => onBatchChanged(),
      ),
      const SizedBox(height: SpacingTokens.fieldGap),
      Text(
        context.l10n.batchSeparatorLabel,
        style: context.textTheme.labelLarge,
      ),
      const SizedBox(height: SpacingTokens.sm),
      _SeparatorSelector(
        currentValue: separator,
        onSelected: onSeparatorChanged,
      ),
      const SizedBox(height: SpacingTokens.fieldGap),
      _BatchPreviewCard(preview: preview),
    ],
  );
}

class _SeparatorSelector extends StatelessWidget {
  const _SeparatorSelector({
    required this.currentValue,
    required this.onSelected,
  });

  final String currentValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: '\t', label: Text(context.l10n.batchSeparatorTab)),
        ButtonSegment(value: '|', label: Text(context.l10n.batchSeparatorPipe)),
        ButtonSegment(
          value: ',',
          label: Text(context.l10n.batchSeparatorComma),
        ),
      ],
      selected: {currentValue},
      onSelectionChanged: (selection) => onSelected(selection.first),
    ),
  );
}

class _BatchPreviewCard extends StatelessWidget {
  const _BatchPreviewCard({required this.preview});

  final CardBatchParseResult preview;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rule_folder_outlined,
              size: SizeTokens.iconSm,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                context.l10n.batchPreviewCount(preview.parsed.length),
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (preview.errors.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.md),
          ...preview.errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Text(
                error,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
