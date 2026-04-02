import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_snapshot.freezed.dart';
part 'statistics_snapshot.g.dart';

@freezed
abstract class StatisticsSnapshot with _$StatisticsSnapshot {
  const factory StatisticsSnapshot({
    required int id,
    required int totalReviews,
  }) = _StatisticsSnapshot;

  factory StatisticsSnapshot.fromJson(Map<String, dynamic> json) =>
      _$StatisticsSnapshotFromJson(json);
}
