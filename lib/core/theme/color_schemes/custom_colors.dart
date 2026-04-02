import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.success,
    required this.warning,
    required this.mastery,
    required this.surfaceDim,
    required this.statusNew,
    required this.statusLearning,
    required this.statusReviewing,
    required this.statusMastered,
    required this.ratingAgain,
    required this.ratingHard,
    required this.ratingGood,
    required this.ratingEasy,
    required this.selfMissed,
    required this.selfPartial,
    required this.selfGotIt,
    required this.masteryLow,
    required this.masteryMid,
    required this.masteryHigh,
  });

  final Color success;
  final Color warning;
  final Color mastery;
  final Color surfaceDim;
  final Color statusNew;
  final Color statusLearning;
  final Color statusReviewing;
  final Color statusMastered;
  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;
  final Color selfMissed;
  final Color selfPartial;
  final Color selfGotIt;
  final Color masteryLow;
  final Color masteryMid;
  final Color masteryHigh;

  static const CustomColors light = CustomColors(
    success: ColorTokens.successLight,
    warning: ColorTokens.warningLight,
    mastery: ColorTokens.masteryLight,
    surfaceDim: ColorTokens.surfaceDimLight,
    statusNew: ColorTokens.statusNew,
    statusLearning: ColorTokens.statusLearning,
    statusReviewing: ColorTokens.statusReviewing,
    statusMastered: ColorTokens.statusMastered,
    ratingAgain: ColorTokens.ratingAgain,
    ratingHard: ColorTokens.ratingHard,
    ratingGood: ColorTokens.ratingGood,
    ratingEasy: ColorTokens.ratingEasy,
    selfMissed: ColorTokens.selfMissed,
    selfPartial: ColorTokens.selfPartial,
    selfGotIt: ColorTokens.selfGotIt,
    masteryLow: ColorTokens.masteryLow,
    masteryMid: ColorTokens.masteryMid,
    masteryHigh: ColorTokens.masteryHigh,
  );

  static const CustomColors dark = CustomColors(
    success: ColorTokens.successDark,
    warning: ColorTokens.warningDark,
    mastery: ColorTokens.masteryDark,
    surfaceDim: ColorTokens.surfaceDimDark,
    statusNew: ColorTokens.statusNew,
    statusLearning: ColorTokens.statusLearning,
    statusReviewing: ColorTokens.statusReviewing,
    statusMastered: ColorTokens.statusMastered,
    ratingAgain: ColorTokens.ratingAgain,
    ratingHard: ColorTokens.ratingHard,
    ratingGood: ColorTokens.ratingGood,
    ratingEasy: ColorTokens.ratingEasy,
    selfMissed: ColorTokens.selfMissed,
    selfPartial: ColorTokens.selfPartial,
    selfGotIt: ColorTokens.selfGotIt,
    masteryLow: ColorTokens.masteryLow,
    masteryMid: ColorTokens.masteryMid,
    masteryHigh: ColorTokens.masteryHigh,
  );

  @override
  CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? mastery,
    Color? surfaceDim,
    Color? statusNew,
    Color? statusLearning,
    Color? statusReviewing,
    Color? statusMastered,
    Color? ratingAgain,
    Color? ratingHard,
    Color? ratingGood,
    Color? ratingEasy,
    Color? selfMissed,
    Color? selfPartial,
    Color? selfGotIt,
    Color? masteryLow,
    Color? masteryMid,
    Color? masteryHigh,
  }) => CustomColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    mastery: mastery ?? this.mastery,
    surfaceDim: surfaceDim ?? this.surfaceDim,
    statusNew: statusNew ?? this.statusNew,
    statusLearning: statusLearning ?? this.statusLearning,
    statusReviewing: statusReviewing ?? this.statusReviewing,
    statusMastered: statusMastered ?? this.statusMastered,
    ratingAgain: ratingAgain ?? this.ratingAgain,
    ratingHard: ratingHard ?? this.ratingHard,
    ratingGood: ratingGood ?? this.ratingGood,
    ratingEasy: ratingEasy ?? this.ratingEasy,
    selfMissed: selfMissed ?? this.selfMissed,
    selfPartial: selfPartial ?? this.selfPartial,
    selfGotIt: selfGotIt ?? this.selfGotIt,
    masteryLow: masteryLow ?? this.masteryLow,
    masteryMid: masteryMid ?? this.masteryMid,
    masteryHigh: masteryHigh ?? this.masteryHigh,
  );

  @override
  CustomColors lerp(covariant CustomColors? other, double t) {
    if (other == null) {
      return this;
    }

    return CustomColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      mastery: Color.lerp(mastery, other.mastery, t) ?? mastery,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t) ?? surfaceDim,
      statusNew: Color.lerp(statusNew, other.statusNew, t) ?? statusNew,
      statusLearning:
          Color.lerp(statusLearning, other.statusLearning, t) ??
          statusLearning,
      statusReviewing:
          Color.lerp(statusReviewing, other.statusReviewing, t) ??
          statusReviewing,
      statusMastered:
          Color.lerp(statusMastered, other.statusMastered, t) ??
          statusMastered,
      ratingAgain: Color.lerp(ratingAgain, other.ratingAgain, t) ?? ratingAgain,
      ratingHard: Color.lerp(ratingHard, other.ratingHard, t) ?? ratingHard,
      ratingGood: Color.lerp(ratingGood, other.ratingGood, t) ?? ratingGood,
      ratingEasy: Color.lerp(ratingEasy, other.ratingEasy, t) ?? ratingEasy,
      selfMissed: Color.lerp(selfMissed, other.selfMissed, t) ?? selfMissed,
      selfPartial: Color.lerp(selfPartial, other.selfPartial, t) ?? selfPartial,
      selfGotIt: Color.lerp(selfGotIt, other.selfGotIt, t) ?? selfGotIt,
      masteryLow: Color.lerp(masteryLow, other.masteryLow, t) ?? masteryLow,
      masteryMid: Color.lerp(masteryMid, other.masteryMid, t) ?? masteryMid,
      masteryHigh: Color.lerp(masteryHigh, other.masteryHigh, t) ?? masteryHigh,
    );
  }
}
