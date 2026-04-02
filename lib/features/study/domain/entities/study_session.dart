class StudySession {
  const StudySession({required this.id, required this.mode});

  final int id;
  final String mode;

  StudySession copyWith({
    int? id,
    String? mode,
  }) {
    return StudySession(
      id: id ?? this.id,
      mode: mode ?? this.mode,
    );
  }
}
