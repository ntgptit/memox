import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';

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
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppStrings.cancelAction),
      ),
      TextButton(
        onPressed: _submit,
        child: const Text(AppStrings.submitAction),
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
