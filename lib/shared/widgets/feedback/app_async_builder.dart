import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';
import 'package:memox/shared/widgets/feedback/error_view.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';
import 'package:memox/shared/widgets/feedback/loading_overlay.dart';
import 'package:memox/shared/widgets/feedback/skeleton_parts.dart';

enum LoadingStyle { spinner, skeleton }

class AppAsyncBuilder<T> extends StatelessWidget {
  const AppAsyncBuilder({
    required this.value,
    required this.onData,
    this.onRetry,
    this.onLoading,
    this.onError,
    this.showLoadingOverlay = false,
    this.animate = false,
    this.loadingStyle = LoadingStyle.spinner,
    this.keepPreviousDataWhileLoading = true,
    super.key,
  });

  static const _loadingLabelCodeUnits = <int>[76, 111, 97, 100, 105, 110, 103];

  final AsyncValue<T> value;
  final Widget Function(T data) onData;
  final VoidCallback? onRetry;
  final Widget Function()? onLoading;
  final Widget Function(Object error)? onError;
  final bool showLoadingOverlay;
  final bool animate;
  final LoadingStyle loadingStyle;

  /// When true, shows previous data during re-loading
  /// instead of a loading indicator.
  final bool keepPreviousDataWhileLoading;

  @override
  Widget build(BuildContext context) {
    if (value.isLoading && value.hasValue) {
      if (showLoadingOverlay) {
        return LoadingOverlay(
          isLoading: true,
          child: _animatedChild(onData(value.requireValue)),
        );
      }

      if (keepPreviousDataWhileLoading) {
        return onData(value.requireValue);
      }
    }

    return value.when(
      data: (data) => _animatedChild(onData(data)),
      loading: () => onLoading?.call() ?? _defaultLoading(),
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

  Widget _defaultLoading() => switch (loadingStyle) {
    LoadingStyle.spinner => const LoadingIndicator(),
    LoadingStyle.skeleton => Semantics(
      label: String.fromCharCodes(_loadingLabelCodeUnits),
      excludeSemantics: true,
      child: const Column(
        children: [
          SkeletonHeader(),
          Expanded(child: SkeletonList()),
        ],
      ),
    ),
  };
}
