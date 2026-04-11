import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/study/domain/usecases/build_study_deck_recommendation.dart';
import 'package:memox/features/study/presentation/widgets/study_deck_recommendation_tile.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/section_container.dart';

class StudyDeckPickerSection extends StatelessWidget {
  const StudyDeckPickerSection({required this.recommendations, super.key});

  final List<StudyDeckRecommendation> recommendations;

  @override
  Widget build(BuildContext context) => SectionContainer(
    title: context.l10n.studyDecksSectionTitle,
    child: AppCard(
      child: Column(
        children: [
          for (var index = 0; index < recommendations.length; index++)
            StudyDeckRecommendationTile(
              recommendation: recommendations[index],
              showDivider: index < recommendations.length - 1,
            ),
        ],
      ),
    ),
  );
}
