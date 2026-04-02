import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';

class TagInputField extends StatefulWidget {
  const TagInputField({
    required this.tags,
    required this.suggestions,
    required this.onChanged,
    this.maxTags,
    super.key,
  });

  final List<String> tags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;
  final int? maxTags;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  late final TextEditingController _controller;

  bool get _isAtLimit =>
      widget.maxTags != null && widget.tags.length >= widget.maxTags!;

  List<String> get _filteredSuggestions {
    final query = AppStringUtils.normalized(_controller.text);

    if (query.isEmpty || _isAtLimit) {
      return const <String>[];
    }

    return widget.suggestions.where((value) {
      final normalized = AppStringUtils.normalized(value);
      final exists = widget.tags.any(
        (tag) => AppStringUtils.normalized(tag) == normalized,
      );
      return normalized.contains(query) && !exists;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final tag = value.trim();
    final normalized = AppStringUtils.normalized(tag);

    if (normalized.isEmpty || _isAtLimit) {
      return;
    }

    if (widget.tags.any((item) => AppStringUtils.normalized(item) == normalized)) {
      _controller.clear();
      setState(() {});
      return;
    }

    widget.onChanged(<String>[...widget.tags, tag]);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: SpacingTokens.chipGap,
        runSpacing: SpacingTokens.chipGap,
        children: widget.tags
            .map(
              (tag) => TagChip(
                label: tag,
                onDelete: () => widget.onChanged(
                  widget.tags.where((item) => item != tag).toList(),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: SpacingTokens.sm),
      TextField(
        controller: _controller,
        enabled: !_isAtLimit,
        onChanged: (_) => setState(() {}),
        onSubmitted: _addTag,
        decoration: const InputDecoration(hintText: AppStrings.addTagHint),
      ),
      if (_filteredSuggestions.isNotEmpty) ...[
        const SizedBox(height: SpacingTokens.sm),
        _SuggestionList(
          suggestions: _filteredSuggestions,
          onSelected: _addTag,
        ),
      ],
    ],
  );
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.suggestions,
    required this.onSelected,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: ListView(
        shrinkWrap: true,
        children: suggestions
            .map(
              (suggestion) => ListTile(
                title: Text(suggestion),
                onTap: () => onSelected(suggestion),
              ),
            )
            .toList(),
      ),
    ),
  );
}
