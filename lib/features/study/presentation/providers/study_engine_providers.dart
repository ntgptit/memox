import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/domain/srs/fuzzy_matcher.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_engine_providers.g.dart';

@riverpod
FillEngine fillEngine(Ref ref) =>
    FillEngine(fuzzyMatcher: ref.read(fuzzyMatcherProvider));

@riverpod
FuzzyMatcher fuzzyMatcher(Ref ref) => const FuzzyMatcher();

@riverpod
SRSEngine srsEngine(Ref ref) => SRSEngine();
