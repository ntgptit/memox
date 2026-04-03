abstract final class DurationTokens {
  // ── Core Durations ──
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 500);

  // ── Semantic Durations ──
  static const Duration stateChange = fast; // color, border changes
  static const Duration contentSwitch = normal; // fade in/out content
  static const Duration pageTransition = slow; // route transitions
  static const Duration cardFlip = Duration(milliseconds: 350);
  static const Duration shake = slow;
  static const Duration countUp = Duration(milliseconds: 400);
  static const Duration chartDraw = Duration(milliseconds: 600);
  static const Duration pulse = Duration(milliseconds: 1500);
  static const Duration timerTick = Duration(seconds: 1);
  static const Duration guessAutoAdvance = pulse;

  // ── Delays ──
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration autoAdvance = Duration(milliseconds: 1200);
  static const Duration ratingPause = Duration(milliseconds: 800);
  static const Duration wrongClear = Duration(milliseconds: 500);
  static const Duration debounce = Duration(milliseconds: 300);
  static const Duration tooltipShow = Duration(seconds: 2);
  static const Duration toast = Duration(seconds: 4);
}
