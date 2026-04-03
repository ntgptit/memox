import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.fab,
    this.bottomNavigationBar,
    this.useSafeArea = true,
    this.extendBehindAppBar = false,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? fab;
  final Widget? bottomNavigationBar;
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
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.screenType.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.screenType.screenPadding,
            0,
            context.screenType.screenPadding,
            bottomPadding,
          ),
          child: body,
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBehindAppBar,
      floatingActionButton: fab,
      bottomNavigationBar: bottomNavigationBar,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}
