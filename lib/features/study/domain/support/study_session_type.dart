import 'package:memox/l10n/generated/app_localizations.dart';

enum StudySessionType {
  firstLearning,
  review,
  reinforcement,
  quickDrill;

  String label(L10n l10n) => switch (this) {
    StudySessionType.firstLearning => l10n.studySessionTypeFirstLearning,
    StudySessionType.review => l10n.studySessionTypeReview,
    StudySessionType.reinforcement => l10n.studySessionTypeReinforcement,
    StudySessionType.quickDrill => l10n.studySessionTypeQuickDrill,
  };
}
