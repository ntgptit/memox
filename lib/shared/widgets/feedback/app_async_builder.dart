import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';
import 'package:memox/shared/widgets/feedback/error_view.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';
import 'package:memox/shared/widgets/feedback/loading_overlay.dart';

class AppAsyncBuilder<T> extends StatelessWidget {
  const AppAsyncBuilder({
    required this.value,
    required this.onData,
    this.onRetry,
    this.onLoading,
    this.onError,
    this.showLoadingOverlay = false,
    this.animate = true,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) onData;
  final VoidCallback? onRetry;
  final Widget Function()? onLoading;
  final Widget Function(Object error)? onError;
  final bool showLoadingOverlay;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (showLoadingOverlay && value.hasValue && value.isLoading) {
      return LoadingOverlay(
        isLoading: true,
        child: _animatedChild(onData(value.requireValue)),
      );
    }

    return value.when(
      data: (data) => _animatedChild(onData(data)),
      loading: () => onLoading?.call() ?? const LoadingIndicator(),
      error: (error, _) =>
          onError?.call(error) ??
          ErrorView(message: error.toString(), onRetry: onRetry),
    );
  }

  Widget _animatedChild(Widget child) {
    if (!animate) {
      return child;
    }

    return FadeInWidget(child: child);
  }
}
