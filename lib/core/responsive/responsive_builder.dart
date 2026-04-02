import 'package:flutter/widgets.dart';
import 'package:memox/core/responsive/screen_type.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, ScreenType screenType) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, ScreenType.of(context));
}
