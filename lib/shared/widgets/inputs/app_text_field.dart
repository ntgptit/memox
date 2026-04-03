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
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.onChanged,
    this.keyboardType,
    this.floatingLabelBehavior,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? error;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final FloatingLabelBehavior? floatingLabelBehavior;

  @override
  Widget build(BuildContext context) {
    final isSingleLine = maxLines == 1 && (minLines ?? 1) == 1;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textAlignVertical: isSingleLine
          ? TextAlignVertical.center
          : TextAlignVertical.top,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        alignLabelWithHint: !isSingleLine,
        floatingLabelBehavior: floatingLabelBehavior,
        counterText: showCounter ? null : '',
        errorStyle: context.textTheme.bodySmall?.copyWith(
          color: context.customColors.ratingAgain,
        ),
        constraints: isSingleLine
            ? const BoxConstraints(minHeight: SizeTokens.inputHeight)
            : null,
      ),
    );
  }
}
