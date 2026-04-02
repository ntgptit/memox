import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.error,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.onChanged,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? error;
  final int maxLines;
  final int? maxLength;
  final bool showCounter;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    maxLines: maxLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      counterText: showCounter ? null : '',
      errorStyle: context.textTheme.bodySmall?.copyWith(
        color: context.customColors.ratingAgain,
      ),
      constraints: maxLines == 1
          ? const BoxConstraints(minHeight: SizeTokens.inputHeight)
          : null,
    ),
  );
}
