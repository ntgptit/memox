import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/dialogs/app_dialog.dart';

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

    return AppDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        SecondaryButton(
          onPressed: () => Navigator.of(context).pop(false),
          label: context.l10n.cancelAction,
          fullWidth: false,
        ),
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(true),
          label: confirmText,
          fullWidth: false,
          backgroundColor: confirmColor,
          foregroundColor: isDestructive
              ? Theme.of(context).colorScheme.onError
              : null,
        ),
      ],
    );
  }
}
