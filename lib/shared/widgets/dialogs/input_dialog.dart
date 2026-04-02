import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({
    required this.title,
    required this.hint,
    this.initialValue,
    this.validator,
    super.key,
  });

  final String title;
  final String hint;
  final String? initialValue;
  final String? Function(String value)? validator;

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    final error = widget.validator?.call(value);

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      onChanged: (_) => setState(() => _error = null),
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(hintText: widget.hint, errorText: _error),
    ),
    actions: [
      SecondaryButton(
        onPressed: () => Navigator.of(context).pop(),
        label: context.l10n.cancelAction,
        fullWidth: false,
      ),
      PrimaryButton(
        onPressed: _submit,
        label: context.l10n.submitAction,
        fullWidth: false,
      ),
    ],
  );
}

Future<String?> showInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String? initialValue,
  String? Function(String value)? validator,
}) => showDialog<String>(
  context: context,
  builder: (_) => InputDialog(
    title: title,
    hint: hint,
    initialValue: initialValue,
    validator: validator,
  ),
);
