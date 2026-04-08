import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';

class ReviewRatingShortcuts extends StatelessWidget {
  const ReviewRatingShortcuts({
    required this.isFlipped,
    required this.onToggleFlip,
    required this.onRate,
    required this.child,
    super.key,
  });

  final bool isFlipped;
  final VoidCallback onToggleFlip;
  final ValueChanged<ReviewRating> onRate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shortcuts = isFlipped ? _ratingShortcuts : _revealShortcuts;
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _RevealReviewIntent: CallbackAction<_RevealReviewIntent>(
            onInvoke: (_) => onToggleFlip(),
          ),
          _RateReviewIntent: CallbackAction<_RateReviewIntent>(
            onInvoke: (intent) => onRate(intent.rating),
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }

  static const Map<ShortcutActivator, Intent> _revealShortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): _RevealReviewIntent(),
        SingleActivator(LogicalKeyboardKey.enter): _RevealReviewIntent(),
      };

  static const Map<ShortcutActivator, Intent> _ratingShortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.digit1): _RateReviewIntent(
          ReviewRating.again,
        ),
        SingleActivator(LogicalKeyboardKey.digit2): _RateReviewIntent(
          ReviewRating.hard,
        ),
        SingleActivator(LogicalKeyboardKey.digit3): _RateReviewIntent(
          ReviewRating.good,
        ),
        SingleActivator(LogicalKeyboardKey.digit4): _RateReviewIntent(
          ReviewRating.easy,
        ),
        SingleActivator(LogicalKeyboardKey.numpad1): _RateReviewIntent(
          ReviewRating.again,
        ),
        SingleActivator(LogicalKeyboardKey.numpad2): _RateReviewIntent(
          ReviewRating.hard,
        ),
        SingleActivator(LogicalKeyboardKey.numpad3): _RateReviewIntent(
          ReviewRating.good,
        ),
        SingleActivator(LogicalKeyboardKey.numpad4): _RateReviewIntent(
          ReviewRating.easy,
        ),
      };
}

class _RevealReviewIntent extends Intent {
  const _RevealReviewIntent();
}

class _RateReviewIntent extends Intent {
  const _RateReviewIntent(this.rating);

  final ReviewRating rating;
}
