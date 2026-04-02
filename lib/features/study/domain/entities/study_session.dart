import 'package:memox/core/design/study_mode.dart';

class StudySession {
  const StudySession({
    required this.id,
    this.mode = StudyMode.review,
    this.deckId = 0,
    this.startedAt,
    this.completedAt,
    this.totalCards = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.durationSeconds = 0,
  });

  final int id;
  final StudyMode mode;
  final int deckId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int totalCards;
  final int correctCount;
  final int wrongCount;
  final int durationSeconds;

  StudySession copyWith({
    int? id,
    StudyMode? mode,
    int? deckId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalCards,
    int? correctCount,
    int? wrongCount,
    int? durationSeconds,
  }) {
    return StudySession(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      deckId: deckId ?? this.deckId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalCards: totalCards ?? this.totalCards,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
