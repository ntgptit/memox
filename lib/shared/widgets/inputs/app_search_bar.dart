import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    required this.onChanged,
    this.hint,
    this.autofocus = false,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String? hint;
  final bool autofocus;

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
        prefixIcon: const Icon(Icons.search_outlined),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(onPressed: _clear, icon: const Icon(Icons.close)),
      ),
    ),
  );
}
