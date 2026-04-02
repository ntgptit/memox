import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmText;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
