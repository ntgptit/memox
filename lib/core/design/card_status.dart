import 'package:memox/l10n/generated/app_localizations.dart';

enum CardStatus {
  newCard,
  learning,
  reviewing,
  mastered;

  String label(L10n l10n) => switch (this) {
    CardStatus.newCard => l10n.statusNew,
    CardStatus.learning => l10n.statusLearning,
    CardStatus.reviewing => l10n.statusReviewing,
    CardStatus.mastered => l10n.statusMastered,
  };
}
