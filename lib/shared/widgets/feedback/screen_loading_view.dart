import 'package:flutter/material.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';

class ScreenLoadingView extends StatelessWidget {
  const ScreenLoadingView({
    this.appBar,
    this.bottomNavigationBar,
    this.applyHorizontalPadding = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool applyHorizontalPadding;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: appBar,
    bottomNavigationBar: bottomNavigationBar,
    applyHorizontalPadding: applyHorizontalPadding,
    body: const LoadingIndicator(),
  );
}
