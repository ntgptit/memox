import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.fab,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.applyHorizontalPadding = true,
    this.applyBottomPadding = true,
    this.useSafeArea = true,
    this.extendBehindAppBar = false,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? fab;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final bool applyHorizontalPadding;
  final bool applyBottomPadding;
  final bool useSafeArea;
  final bool extendBehindAppBar;

  static double contentBottomPadding({
    required bool hasBottomNav,
    required bool hasFab,
  }) {
    if (hasBottomNav) {
      return 0;
    }

    if (hasFab) {
      return SizeTokens.fabSize + SpacingTokens.lg;
    }

    return SpacingTokens.xl;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = contentBottomPadding(
      hasBottomNav: bottomNavigationBar != null,
      hasFab: fab != null,
    );
    final resolvedBottomPadding = applyBottomPadding ? bottomPadding : 0.0;
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.screenType.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            applyHorizontalPadding ? context.screenType.screenPadding : 0,
            0,
            applyHorizontalPadding ? context.screenType.screenPadding : 0,
            resolvedBottomPadding,
          ),
          child: body,
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBehindAppBar,
      floatingActionButton: fab,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}
