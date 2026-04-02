import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/dialogs/confirm_dialog.dart';

class ExitSessionDialog extends StatelessWidget {
  const ExitSessionDialog({super.key});

  @override
  Widget build(BuildContext context) => const ConfirmDialog(
    title: AppStrings.exitSessionTitle,
    message: AppStrings.exitSessionMessage,
    confirmText: AppStrings.exitAction,
    isDestructive: true,
  );
}

Future<bool?> showExitSessionDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => const ExitSessionDialog(),
);
