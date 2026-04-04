import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.flashcardFront,
    required this.flashcardBack,
    required this.flashcardHint,
    required this.flashcardExample,
    required this.questionText,
    required this.studyTerm,
    required this.recallTerm,
    required this.answerCorrect,
    required this.statNumber,
    required this.statNumberMd,
    required this.statNumberSm,
    required this.statLabel,
    required this.appTitle,
    required this.sectionLabel,
    required this.breadcrumb,
    required this.progressCount,
    required this.nextReviewTime,
    required this.tagText,
    required this.batchPreview,
  });

  factory AppTextStyles.fromTextTheme(TextTheme textTheme) {
    final bodyColor = textTheme.bodyLarge?.color ?? ColorTokens.onSurfaceLight;
    final mutedColor = textTheme.bodySmall?.color ?? bodyColor;

    TextStyle themed({
      TextStyle? base,
      required double fontSize,
      required FontWeight fontWeight,
      double? height,
      double? letterSpacing,
      FontStyle? fontStyle,
      Color? color,
      List<FontFeature>? fontFeatures,
    }) => GoogleFonts.plusJakartaSans(
      textStyle: base,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      color: color ?? base?.color,
      fontFeatures: fontFeatures,
    );

    return AppTextStyles(
      flashcardFront: themed(
        base: textTheme.displayLarge,
        fontSize: TypographyTokens.displayLarge,
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.headingHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      flashcardBack: themed(
        base: textTheme.bodyLarge,
        fontSize: TypographyTokens.bodyLarge,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.relaxedHeight,
      ),
      flashcardHint: themed(
        base: textTheme.labelSmall,
        fontSize: TypographyTokens.labelSmall,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.captionHeight,
        color: mutedColor.withValues(alpha: OpacityTokens.subtleHint),
      ),
      flashcardExample: themed(
        base: textTheme.bodySmall,
        fontSize: TypographyTokens.bodySmall,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.bodyHeight,
        fontStyle: FontStyle.italic,
      ),
      questionText: themed(
        base: textTheme.titleMedium,
        fontSize: TypographyTokens.titleMedium,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.relaxedHeight,
      ),
      studyTerm: themed(
        base: textTheme.headlineMedium,
        fontSize: TypographyTokens.headlineMedium,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.headingHeight,
      ),
      recallTerm: themed(
        base: textTheme.displayLarge,
        fontSize: TypographyTokens.displayLarge,
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.headingHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      answerCorrect: themed(
        base: textTheme.titleSmall,
        fontSize: TypographyTokens.titleSmall,
        fontWeight: TypographyTokens.medium,
        height: TypographyTokens.bodyHeight,
      ),
      statNumber: themed(
        base: textTheme.displayLarge,
        fontSize: TypographyTokens.statDisplay,
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.displayHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      statNumberMd: themed(
        base: textTheme.headlineLarge,
        fontSize: TypographyTokens.headlineLarge,
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.displayHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      statNumberSm: themed(
        base: textTheme.titleLarge,
        fontSize: TypographyTokens.titleLarge,
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.headingHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      statLabel: themed(
        base: textTheme.labelSmall,
        fontSize: TypographyTokens.labelSmall,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.captionHeight,
        color: mutedColor,
      ),
      appTitle: themed(
        base: textTheme.headlineMedium,
        fontSize: TypographyTokens.headlineMedium,
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.headingHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      sectionLabel: themed(
        base: textTheme.labelSmall,
        fontSize: TypographyTokens.labelSmall,
        fontWeight: TypographyTokens.medium,
        height: TypographyTokens.captionHeight,
        letterSpacing: TypographyTokens.sectionSpacing,
        color: mutedColor,
      ),
      breadcrumb: themed(
        base: textTheme.bodySmall,
        fontSize: TypographyTokens.bodySmall,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.bodyHeight,
        color: mutedColor,
      ),
      progressCount: themed(
        base: textTheme.labelLarge,
        fontSize: TypographyTokens.bodySmall,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.bodyHeight,
        letterSpacing: TypographyTokens.labelSpacing,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      nextReviewTime: themed(
        base: textTheme.bodySmall,
        fontSize: TypographyTokens.caption,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.captionHeight,
        color: mutedColor,
      ),
      tagText: themed(
        base: textTheme.labelLarge,
        fontSize: TypographyTokens.labelLarge,
        fontWeight: TypographyTokens.regular,
        height: TypographyTokens.bodyHeight,
      ),
      batchPreview: themed(
        base: textTheme.labelLarge,
        fontSize: TypographyTokens.labelLarge,
        fontWeight: TypographyTokens.medium,
        height: TypographyTokens.bodyHeight,
      ),
    );
  }

  final TextStyle flashcardFront;
  final TextStyle flashcardBack;
  final TextStyle flashcardHint;
  final TextStyle flashcardExample;
  final TextStyle questionText;
  final TextStyle studyTerm;
  final TextStyle recallTerm;
  final TextStyle answerCorrect;
  final TextStyle statNumber;
  final TextStyle statNumberMd;
  final TextStyle statNumberSm;
  final TextStyle statLabel;
  final TextStyle appTitle;
  final TextStyle sectionLabel;
  final TextStyle breadcrumb;
  final TextStyle progressCount;
  final TextStyle nextReviewTime;
  final TextStyle tagText;
  final TextStyle batchPreview;

  @override
  AppTextStyles copyWith({
    TextStyle? flashcardFront,
    TextStyle? flashcardBack,
    TextStyle? flashcardHint,
    TextStyle? flashcardExample,
    TextStyle? questionText,
    TextStyle? studyTerm,
    TextStyle? recallTerm,
    TextStyle? answerCorrect,
    TextStyle? statNumber,
    TextStyle? statNumberMd,
    TextStyle? statNumberSm,
    TextStyle? statLabel,
    TextStyle? appTitle,
    TextStyle? sectionLabel,
    TextStyle? breadcrumb,
    TextStyle? progressCount,
    TextStyle? nextReviewTime,
    TextStyle? tagText,
    TextStyle? batchPreview,
  }) => AppTextStyles(
    flashcardFront: flashcardFront ?? this.flashcardFront,
    flashcardBack: flashcardBack ?? this.flashcardBack,
    flashcardHint: flashcardHint ?? this.flashcardHint,
    flashcardExample: flashcardExample ?? this.flashcardExample,
    questionText: questionText ?? this.questionText,
    studyTerm: studyTerm ?? this.studyTerm,
    recallTerm: recallTerm ?? this.recallTerm,
    answerCorrect: answerCorrect ?? this.answerCorrect,
    statNumber: statNumber ?? this.statNumber,
    statNumberMd: statNumberMd ?? this.statNumberMd,
    statNumberSm: statNumberSm ?? this.statNumberSm,
    statLabel: statLabel ?? this.statLabel,
    appTitle: appTitle ?? this.appTitle,
    sectionLabel: sectionLabel ?? this.sectionLabel,
    breadcrumb: breadcrumb ?? this.breadcrumb,
    progressCount: progressCount ?? this.progressCount,
    nextReviewTime: nextReviewTime ?? this.nextReviewTime,
    tagText: tagText ?? this.tagText,
    batchPreview: batchPreview ?? this.batchPreview,
  );

  @override
  AppTextStyles lerp(covariant AppTextStyles? other, double t) {
    if (other == null) {
      return this;
    }

    return AppTextStyles(
      flashcardFront:
          TextStyle.lerp(flashcardFront, other.flashcardFront, t) ??
          flashcardFront,
      flashcardBack:
          TextStyle.lerp(flashcardBack, other.flashcardBack, t) ??
          flashcardBack,
      flashcardHint:
          TextStyle.lerp(flashcardHint, other.flashcardHint, t) ??
          flashcardHint,
      flashcardExample:
          TextStyle.lerp(flashcardExample, other.flashcardExample, t) ??
          flashcardExample,
      questionText:
          TextStyle.lerp(questionText, other.questionText, t) ?? questionText,
      studyTerm: TextStyle.lerp(studyTerm, other.studyTerm, t) ?? studyTerm,
      recallTerm: TextStyle.lerp(recallTerm, other.recallTerm, t) ?? recallTerm,
      answerCorrect:
          TextStyle.lerp(answerCorrect, other.answerCorrect, t) ??
          answerCorrect,
      statNumber: TextStyle.lerp(statNumber, other.statNumber, t) ?? statNumber,
      statNumberMd:
          TextStyle.lerp(statNumberMd, other.statNumberMd, t) ?? statNumberMd,
      statNumberSm:
          TextStyle.lerp(statNumberSm, other.statNumberSm, t) ?? statNumberSm,
      statLabel: TextStyle.lerp(statLabel, other.statLabel, t) ?? statLabel,
      appTitle: TextStyle.lerp(appTitle, other.appTitle, t) ?? appTitle,
      sectionLabel:
          TextStyle.lerp(sectionLabel, other.sectionLabel, t) ?? sectionLabel,
      breadcrumb: TextStyle.lerp(breadcrumb, other.breadcrumb, t) ?? breadcrumb,
      progressCount:
          TextStyle.lerp(progressCount, other.progressCount, t) ??
          progressCount,
      nextReviewTime:
          TextStyle.lerp(nextReviewTime, other.nextReviewTime, t) ??
          nextReviewTime,
      tagText: TextStyle.lerp(tagText, other.tagText, t) ?? tagText,
      batchPreview:
          TextStyle.lerp(batchPreview, other.batchPreview, t) ?? batchPreview,
    );
  }
}
