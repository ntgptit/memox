import 'package:flutter/widgets.dart';

extension WidgetX on Widget {
  Widget withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);

  Widget centered() => Center(child: this);
}
