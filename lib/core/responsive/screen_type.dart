import 'package:flutter/widgets.dart';
import 'package:memox/core/responsive/breakpoints.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

enum ScreenType {
  compact,
  medium,
  expanded;

  static ScreenType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.expanded) {
      return ScreenType.expanded;
    }

    if (width >= Breakpoints.medium) {
      return ScreenType.medium;
    }

    return ScreenType.compact;
  }

  double get screenPadding => switch (this) {
    ScreenType.compact => SpacingTokens.lg,
    ScreenType.medium => SpacingTokens.xl,
    ScreenType.expanded => SpacingTokens.xxl,
  };

  int get gridColumns => switch (this) {
    ScreenType.compact => 1,
    ScreenType.medium => 2,
    ScreenType.expanded => 3,
  };

  double get maxContentWidth => switch (this) {
    ScreenType.compact => double.infinity,
    ScreenType.medium => 640,
    ScreenType.expanded => 840,
  };

  double get textScaleFactor => switch (this) {
    ScreenType.compact => 1,
    ScreenType.medium => 1.1,
    ScreenType.expanded => 1.15,
  };

  double get flashcardWidth => switch (this) {
    ScreenType.compact => double.infinity,
    ScreenType.medium => 400,
    ScreenType.expanded => 480,
  };

  double get flashcardHeight => switch (this) {
    ScreenType.compact => 340,
    ScreenType.medium => 380,
    ScreenType.expanded => 420,
  };

  double get matchColumnWidth => switch (this) {
    ScreenType.compact => double.infinity,
    ScreenType.medium => 260,
    ScreenType.expanded => 300,
  };
}
