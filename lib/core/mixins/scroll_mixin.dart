import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';

/// For StatefulWidgets needing scroll tracking.
mixin ScrollMixin<T extends StatefulWidget> on State<T> {
  static const double _bottomThreshold = 50;

  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    (scrollController..removeListener(_onScroll)).dispose();
    super.dispose();
  }

  bool get isAtBottom {
    if (!scrollController.hasClients) {
      return false;
    }

    final max = scrollController.position.maxScrollExtent;
    return scrollController.offset >= max - _bottomThreshold;
  }

  void scrollToTop({bool animated = true}) {
    if (!scrollController.hasClients) {
      return;
    }

    if (!animated) {
      scrollController.jumpTo(0);
      return;
    }

    unawaited(
      scrollController.animateTo(
        0,
        duration: DurationTokens.slow,
        curve: EasingTokens.move,
      ),
    );
  }

  void _onScroll() {
    if (!isAtBottom) {
      return;
    }

    onScrollEnd();
  }

  /// Override for pagination, lazy loading, etc.
  void onScrollEnd() {}
}
