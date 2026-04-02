import 'package:memox/l10n/generated/app_localizations.dart';

enum StudyMode {
  review,
  match,
  guess,
  recall,
  fill;

  String label(L10n l10n) => switch (this) {
    StudyMode.review => l10n.modeReview,
    StudyMode.match => l10n.modeMatch,
    StudyMode.guess => l10n.modeGuess,
    StudyMode.recall => l10n.modeRecall,
    StudyMode.fill => l10n.modeFill,
  };

  String get emoji => switch (this) {
    StudyMode.review => '🔁',
    StudyMode.match => '🧩',
    StudyMode.guess => '🤔',
    StudyMode.recall => '🧠',
    StudyMode.fill => '✍️',
  };
}
