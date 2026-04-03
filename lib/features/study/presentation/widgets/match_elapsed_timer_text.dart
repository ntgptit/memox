import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

class MatchElapsedTimerText extends StatefulWidget {
  const MatchElapsedTimerText({required this.startTime, super.key});

  final DateTime startTime;

  @override
  State<MatchElapsedTimerText> createState() => _MatchElapsedTimerTextState();
}

class _MatchElapsedTimerTextState extends State<MatchElapsedTimerText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(DurationTokens.timerTick, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds.remainder(60);
    final label = '$minutes:${seconds.toString().padLeft(2, '0')}';
    return Text(
      label,
      style: context.appTextStyles.progressCount.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}
