import 'package:flutter/widgets.dart';
import 'package:memox/core/responsive/screen_type.dart';

mixin ResponsivePadding {
  static EdgeInsets all(BuildContext context) {
    final padding = ScreenType.of(context).screenPadding;

    return EdgeInsets.all(padding);
  }

  static EdgeInsets horizontal(BuildContext context) {
    final padding = ScreenType.of(context).screenPadding;

    return EdgeInsets.symmetric(horizontal: padding);
  }
}
