import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/design/study_mode.dart';

part 'study_session.freezed.dart';
part 'study_session.g.dart';

@freezed
abstract class StudySession with _$StudySession {
  const factory StudySession({
    required int id,
    @Default(StudyMode.review) StudyMode mode,
    @Default(0) int deckId,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default(0) int totalCards,
    @Default(0) int correctCount,
    @Default(0) int wrongCount,
    @Default(0) int durationSeconds,
  }) = _StudySession;

  factory StudySession.fromJson(Map<String, dynamic> json) =>
      _$StudySessionFromJson(json);
}
