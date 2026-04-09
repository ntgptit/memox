import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
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
  var _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final nextIsFocused = _focusNode.hasFocus;
    if (_isFocused == nextIsFocused) {
      return;
    }

    setState(() => _isFocused = nextIsFocused);
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
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            fillColor: _fillColor(context),
            contentPadding: _contentPadding,
            enabledBorder: _enabledBorder(context),
            focusedBorder: _focusedBorder(context),
            prefixIcon: Icon(
              Icons.search_outlined,
              color: _prefixIconColor(context),
            ),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(onPressed: _clear, icon: const Icon(Icons.close)),
          ),
        ),
        IgnorePointer(
          child: AnimatedContainer(
            duration: DurationTokens.fast,
            margin: _indicatorMargin,
            height: _isFocused
                ? SizeTokens.borderWidthThick
                : SizeTokens.borderWidth,
            decoration: BoxDecoration(
              color: _indicatorColor(context),
              borderRadius: BorderRadius.circular(RadiusTokens.full),
            ),
          ),
        ),
      ],
    ),
  );

  Color _fillColor(BuildContext context) => switch (widget.variant) {
    AppSearchBarVariant.page => context.colors.surfaceContainerLow,
    AppSearchBarVariant.toolbar => context.colors.surfaceContainerLowest,
  };

  EdgeInsetsGeometry get _contentPadding => switch (widget.variant) {
    AppSearchBarVariant.page => const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    AppSearchBarVariant.toolbar => const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
  };

  InputBorder? _enabledBorder(BuildContext context) => switch (widget.variant) {
    AppSearchBarVariant.page => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.input)),
      borderSide: BorderSide(
        color: context.colors.outlineVariant.withValues(alpha: 0),
      ),
    ),
    AppSearchBarVariant.toolbar => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.input)),
      borderSide: BorderSide(
        color: context.colors.outlineVariant.withValues(
          alpha: OpacityTokens.borderSubtle,
        ),
      ),
    ),
  };

  InputBorder? _focusedBorder(BuildContext context) => switch (widget.variant) {
    AppSearchBarVariant.page => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.input)),
      borderSide: BorderSide(
        color: context.colors.outlineVariant.withValues(alpha: 0),
      ),
    ),
    AppSearchBarVariant.toolbar => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.input)),
      borderSide: BorderSide(
        color: context.colors.outlineVariant.withValues(
          alpha: OpacityTokens.borderSubtle,
        ),
      ),
    ),
  };

  EdgeInsetsGeometry get _indicatorMargin => switch (widget.variant) {
    AppSearchBarVariant.page => const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
    ),
    AppSearchBarVariant.toolbar => const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
    ),
  };

  Color _indicatorColor(BuildContext context) {
    if (_isFocused) {
      return context.colors.primary;
    }

    return context.colors.surface.withValues(alpha: 0);
  }

  Color _prefixIconColor(BuildContext context) {
    if (_isFocused) {
      return context.colors.primary;
    }

    return context.colors.outline;
  }
}
