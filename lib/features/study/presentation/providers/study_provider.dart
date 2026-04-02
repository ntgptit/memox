import 'package:memox/core/constants/app_strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_provider.g.dart';

@riverpod
String studyScreenTitle(StudyScreenTitleRef ref) => AppStrings.studyTitle;
