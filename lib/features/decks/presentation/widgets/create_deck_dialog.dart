import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/dialogs/app_dialog.dart';
import 'package:memox/shared/widgets/inputs/app_text_field.dart';
import 'package:memox/shared/widgets/inputs/color_picker.dart';
import 'package:memox/shared/widgets/inputs/tag_input_field.dart';

typedef CreateDeckDraft = ({
  String name,
  String description,
  int colorValue,
  List<String> tags,
});

class CreateDeckDialog extends StatefulWidget {
  const CreateDeckDialog({
    this.initialName,
    this.initialDescription,
    this.initialColorValue,
    this.initialTags,
    this.title,
    this.submitLabel,
    super.key,
  });

  final String? initialName;
  final String? initialDescription;
  final int? initialColorValue;
  final List<String>? initialTags;
  final String? title;
  final String? submitLabel;

  @override
  State<CreateDeckDialog> createState() => _CreateDeckDialogState();
}

class _CreateDeckDialogState extends State<CreateDeckDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late Color _selectedColor;
  late List<String> _tags;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _selectedColor = Color(
      widget.initialColorValue ?? ColorTokens.seed.toARGB32(),
    );
    _tags = [...?widget.initialTags];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = context.l10n.deckNameEmptyError);
      return;
    }

    Navigator.of(context).pop<CreateDeckDraft>((
      name: name,
      description: _descriptionController.text.trim(),
      colorValue: _selectedColor.toARGB32(),
      tags: _tags,
    ));
  }

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(widget.title ?? context.l10n.createDeck),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _nameController,
          label: context.l10n.deckNameLabel,
          hint: context.l10n.deckNameHint,
          error: _errorText,
          onChanged: (_) => setState(() => _errorText = null),
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        AppTextField(
          controller: _descriptionController,
          label: context.l10n.deckDescriptionLabel,
          hint: context.l10n.deckDescriptionHint,
          maxLines: 3,
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        Text(
          context.l10n.folderColorLabel,
          style: context.textTheme.labelLarge,
        ),
        const SizedBox(height: SpacingTokens.sm),
        ColorPicker(
          selectedColor: _selectedColor,
          onChanged: (color) => setState(() => _selectedColor = color),
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        Text(context.l10n.deckTagsLabel, style: context.textTheme.labelLarge),
        const SizedBox(height: SpacingTokens.sm),
        TagInputField(
          tags: _tags,
          suggestions: const <String>[],
          onChanged: (tags) => setState(() => _tags = tags),
        ),
      ],
    ),
    actions: [
      SecondaryButton(
        label: context.l10n.cancelAction,
        onPressed: () => context.pop<void>(),
        fullWidth: false,
      ),
      PrimaryButton(
        label: widget.submitLabel ?? context.l10n.createAction,
        onPressed: _submit,
        fullWidth: false,
      ),
    ],
  );
}

Future<CreateDeckDraft?> showCreateDeckDialog(
  BuildContext context, {
  String? initialName,
  String? initialDescription,
  int? initialColorValue,
  List<String>? initialTags,
  String? title,
  String? submitLabel,
}) => showDialog<CreateDeckDraft>(
  context: context,
  builder: (_) => CreateDeckDialog(
    initialName: initialName,
    initialDescription: initialDescription,
    initialColorValue: initialColorValue,
    initialTags: initialTags,
    title: title,
    submitLabel: submitLabel,
  ),
);
