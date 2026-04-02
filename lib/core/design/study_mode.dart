import 'package:memox/core/constants/app_strings.dart';

enum StudyMode {
  review,
  match,
  guess,
  recall,
  fill;

  String get label => switch (this) {
    StudyMode.review => AppStrings.modeReview,
    StudyMode.match => AppStrings.modeMatch,
    StudyMode.guess => AppStrings.modeGuess,
    StudyMode.recall => AppStrings.modeRecall,
    StudyMode.fill => AppStrings.modeFill,
  };

  String get emoji => switch (this) {
    StudyMode.review => '🔁',
    StudyMode.match => '🧩',
    StudyMode.guess => '🤔',
    StudyMode.recall => '🧠',
    StudyMode.fill => '✍️',
  };
}
