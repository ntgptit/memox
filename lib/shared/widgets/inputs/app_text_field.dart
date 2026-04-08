import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppTextField extends _AppTextFieldBase {
  const AppTextField({
    required super.controller,
    required super.label,
    super.hint,
    super.error,
    super.maxLines = 1,
    super.minLines,
    super.maxLength,
    super.showCounter = false,
    super.onChanged,
    super.keyboardType,
    super.floatingLabelBehavior,
    super.autofocus = false,
    super.focusNode,
    super.enabled = true,
    super.onSubmitted,
    super.textInputAction,
    super.readOnly = false,
    super.prefixIcon,
    super.suffixIcon,
    super.textAlign = TextAlign.start,
    super.fillColor,
    super.contentPadding,
    super.enabledBorder,
    super.focusedBorder,
    super.disabledBorder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextField(
    autofocus: autofocus,
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    maxLines: maxLines,
    minLines: minLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    enabled: enabled,
    readOnly: readOnly,
    textAlign: textAlign,
    textAlignVertical: _appTextAlignVertical(isSingleLine),
    decoration: _buildInputDecoration(context, this),
  );
}

abstract class _AppTextFieldBase extends StatelessWidget {
  const _AppTextFieldBase({
    required this.controller,
    required this.label,
    this.hint,
    this.error,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.onChanged,
    this.keyboardType,
    this.floatingLabelBehavior,
    this.autofocus = false,
    this.focusNode,
    this.enabled = true,
    this.onSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    this.fillColor,
    this.contentPadding,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
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
  final bool autofocus;
  final FocusNode? focusNode;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign textAlign;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;

  bool get isSingleLine => maxLines == 1 && (minLines ?? 1) == 1;
}

TextAlignVertical _appTextAlignVertical(bool isSingleLine) =>
    isSingleLine ? TextAlignVertical.center : TextAlignVertical.top;

InputDecoration _buildInputDecoration(
  BuildContext context,
  _AppTextFieldBase config,
) => InputDecoration(
  labelText: config.label,
  hintText: config.hint,
  errorText: config.error,
  alignLabelWithHint: !config.isSingleLine,
  floatingLabelBehavior: config.floatingLabelBehavior,
  counterText: config.showCounter ? null : '',
  prefixIcon: config.prefixIcon,
  suffixIcon: config.suffixIcon,
  fillColor: config.fillColor,
  contentPadding: config.contentPadding,
  enabledBorder: config.enabledBorder,
  focusedBorder: config.focusedBorder,
  disabledBorder: config.disabledBorder,
  errorStyle: context.textTheme.bodySmall?.copyWith(
    color: context.colors.error,
  ),
  constraints: config.isSingleLine
      ? const BoxConstraints(minHeight: SizeTokens.inputHeight)
      : null,
);
