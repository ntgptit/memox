import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_data.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class BackupPayload with _$BackupPayload {
  const factory BackupPayload({
    required int version,
    required String exportDate,
    required String appVersion,
    required List<Map<String, dynamic>> folders,
    required List<Map<String, dynamic>> decks,
    required List<Map<String, dynamic>> cards,
    required List<Map<String, dynamic>> studySessions,
    required List<Map<String, dynamic>> cardReviews,
  }) = _BackupPayload;
  const BackupPayload._();

  factory BackupPayload.fromJson(Map<String, dynamic> json) => BackupPayload(
    version: json['version'] as int,
    exportDate: json['exportDate'] as String,
    appVersion: json['appVersion'] as String,
    folders: (json['folders'] as List<dynamic>).cast<Map<String, dynamic>>(),
    decks: (json['decks'] as List<dynamic>).cast<Map<String, dynamic>>(),
    cards: (json['cards'] as List<dynamic>).cast<Map<String, dynamic>>(),
    studySessions: (json['studySessions'] as List<dynamic>)
        .cast<Map<String, dynamic>>(),
    cardReviews: (json['cardReviews'] as List<dynamic>)
        .cast<Map<String, dynamic>>(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'version': version,
    'exportDate': exportDate,
    'appVersion': appVersion,
    'folders': folders,
    'decks': decks,
    'cards': cards,
    'studySessions': studySessions,
    'cardReviews': cardReviews,
  };
}

@freezed
abstract class BackupResult with _$BackupResult {
  const factory BackupResult.success({
    required String fileId,
    required String fileName,
  }) = BackupSuccess;

  const factory BackupResult.failure(String message) = BackupFailure;
}

@freezed
abstract class ImportResult with _$ImportResult {
  const factory ImportResult.success({
    required int folders,
    required int decks,
    required int cards,
  }) = ImportSuccess;

  const factory ImportResult.failure(String message) = ImportFailure;
}

@Freezed(fromJson: false, toJson: false)
abstract class BackupInfo with _$BackupInfo {
  const factory BackupInfo({
    required String fileId,
    required String fileName,
    DateTime? modifiedTime,
    required int sizeBytes,
  }) = _BackupInfo;
  const BackupInfo._();

  factory BackupInfo.fromJson(Map<String, dynamic> json) => BackupInfo(
    fileId: json['fileId'] as String,
    fileName: json['fileName'] as String,
    modifiedTime: json['modifiedTime'] == null
        ? null
        : DateTime.parse(json['modifiedTime'] as String),
    sizeBytes: json['sizeBytes'] as int,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'fileId': fileId,
    'fileName': fileName,
    'modifiedTime': modifiedTime?.toIso8601String(),
    'sizeBytes': sizeBytes,
  };
}
