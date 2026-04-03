import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

typedef ExpandableTileHeaderBuilder =
    Widget Function(BuildContext context, {required bool expanded});

class ExpandableTile extends StatefulWidget {
  const ExpandableTile({
    required this.headerBuilder,
    required this.expandedContent,
    this.initiallyExpanded = false,
    super.key,
  });

  final ExpandableTileHeaderBuilder headerBuilder;
  final Widget expandedContent;
  final bool initiallyExpanded;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  late var _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(
          children: [
            Expanded(child: widget.headerBuilder(context, expanded: _expanded)),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: DurationTokens.normal,
              child: const Icon(Icons.expand_more),
            ),
          ],
        ),
      ),
      AnimatedSize(
        duration: DurationTokens.normal,
        child: _expanded ? widget.expandedContent : const SizedBox.shrink(),
      ),
    ],
  );
}
