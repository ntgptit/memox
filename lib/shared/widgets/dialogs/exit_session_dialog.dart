import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/dialogs/confirm_dialog.dart';

class ExitSessionDialog extends StatelessWidget {
  const ExitSessionDialog({super.key});

  @override
  Widget build(BuildContext context) => ConfirmDialog(
    title: context.l10n.exitSessionTitle,
    message: context.l10n.exitSessionMessage,
    confirmText: context.l10n.exitAction,
    isDestructive: true,
  );
}

Future<bool?> showExitSessionDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => const ExitSessionDialog(),
);
