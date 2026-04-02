import 'package:memox/core/constants/app_strings.dart';

enum CardStatus {
  newCard,
  learning,
  reviewing,
  mastered;

  String get label => switch (this) {
    CardStatus.newCard => AppStrings.statusNew,
    CardStatus.learning => AppStrings.statusLearning,
    CardStatus.reviewing => AppStrings.statusReviewing,
    CardStatus.mastered => AppStrings.statusMastered,
  };
}
