import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/dialogs/app_dialog.dart';
import 'package:memox/shared/widgets/inputs/app_text_field.dart';
import 'package:memox/shared/widgets/inputs/color_picker.dart';

typedef CreateFolderDraft = ({String name, int colorValue});

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({
    this.initialName,
    this.initialColorValue,
    this.title,
    this.submitLabel,
    super.key,
  });

  final String? initialName;
  final int? initialColorValue;
  final String? title;
  final String? submitLabel;

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  late final TextEditingController _controller;
  late Color _selectedColor;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _selectedColor = Color(
      widget.initialColorValue ?? ColorTokens.seed.toARGB32(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = context.l10n.folderNameEmptyError);
      return;
    }

    Navigator.of(context).pop<CreateFolderDraft>((
      name: name,
      colorValue: _selectedColor.toARGB32(),
    ));
  }

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(widget.title ?? context.l10n.createFolder),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _controller,
          label: context.l10n.folderNameLabel,
          hint: context.l10n.folderNameHint,
          error: _errorText,
          onChanged: (_) => setState(() => _errorText = null),
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
      ],
    ),
    actions: [
      SecondaryButton(
        label: context.l10n.cancelAction,
        onPressed: () => Navigator.of(context).pop(),
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

Future<CreateFolderDraft?> showCreateFolderDialog(
  BuildContext context, {
  String? initialName,
  int? initialColorValue,
  String? title,
  String? submitLabel,
}) => showDialog<CreateFolderDraft>(
  context: context,
  builder: (_) => CreateFolderDialog(
    initialName: initialName,
    initialColorValue: initialColorValue,
    title: title,
    submitLabel: submitLabel,
  ),
);
