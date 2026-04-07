import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

enum AppSearchBarVariant { page, toolbar }

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    required this.onChanged,
    required this.variant,
    this.hint,
    this.autofocus = false,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String? hint;
  final bool autofocus;
  final AppSearchBarVariant variant;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(DurationTokens.debounce, () => widget.onChanged(value));
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    widget.onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SizeTokens.searchBarHeight,
    child: TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        fillColor: _fillColor(context),
        contentPadding: _contentPadding,
        prefixIcon: const Icon(Icons.search_outlined),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(onPressed: _clear, icon: const Icon(Icons.close)),
      ),
    ),
  );

  Color _fillColor(BuildContext context) => switch (widget.variant) {
    AppSearchBarVariant.page => context.colors.surfaceContainerHigh,
    AppSearchBarVariant.toolbar => context.colors.surfaceContainerHighest,
  };

  EdgeInsetsGeometry? get _contentPadding => switch (widget.variant) {
    AppSearchBarVariant.page => null,
    AppSearchBarVariant.toolbar => const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
  };
}
