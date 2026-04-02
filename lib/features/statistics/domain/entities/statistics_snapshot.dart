class StatisticsSnapshot {
  const StatisticsSnapshot({required this.id, required this.totalReviews});

  final int id;
  final int totalReviews;

  StatisticsSnapshot copyWith({int? id, int? totalReviews}) {
    return StatisticsSnapshot(
      id: id ?? this.id,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
}
