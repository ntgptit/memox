import 'package:memox/core/design/study_mode.dart';

Map<StudyMode, double> zeroStatisticsModeUsage() => <StudyMode, double>{
  for (final mode in StudyMode.values) mode: 0,
};
