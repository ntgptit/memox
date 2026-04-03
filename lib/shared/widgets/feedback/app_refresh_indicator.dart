import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    edgeOffset: SpacingTokens.sm,
    displacement: SizeTokens.touchTarget,
    color: context.colors.primary,
    backgroundColor: context.colors.surface,
    child: child,
  );
}

class AppRefreshScrollView extends StatelessWidget {
  const AppRefreshScrollView({
    required this.onRefresh,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => AppRefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Align(alignment: alignment, child: child),
        ),
      ),
    ),
  );
}
