import 'package:memox/core/responsive/screen_type.dart';

mixin ResponsiveGrid {
  static int columnsFor(ScreenType screenType) => screenType.gridColumns;
}
