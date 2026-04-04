import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';

typedef ExpandableTileHeaderBuilder =
    Widget Function(BuildContext context, {required bool expanded});

class ExpandableTile extends StatefulWidget {
  const ExpandableTile({
    required this.headerBuilder,
    required this.expandedContent,
    this.initiallyExpanded = false,
    this.headerPadding = EdgeInsets.zero,
    this.expandedContentPadding = EdgeInsets.zero,
    super.key,
  });

  final ExpandableTileHeaderBuilder headerBuilder;
  final Widget expandedContent;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry expandedContentPadding;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  late var _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppPressable(
        onTap: () => setState(() => _expanded = !_expanded),
        padding: widget.headerPadding,
        borderRadiusGeometry: _headerBorderRadius(_expanded),
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
        child: _expanded
            ? Padding(
                padding: widget.expandedContentPadding,
                child: widget.expandedContent,
              )
            : const SizedBox.shrink(),
      ),
    ],
  );
}

BorderRadius _headerBorderRadius(bool expanded) {
  if (!expanded) {
    return BorderRadius.circular(RadiusTokens.card);
  }

  return const BorderRadius.only(
    topLeft: Radius.circular(RadiusTokens.card),
    topRight: Radius.circular(RadiusTokens.card),
  );
}
