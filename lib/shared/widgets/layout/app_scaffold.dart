import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/responsive/responsive_padding.dart';

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

  @override
  Widget build(BuildContext context) {
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.screenType.maxContentWidth,
        ),
        child: Padding(
          padding: ResponsivePadding.horizontal(context),
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
