import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:memox/core/backup/backup_constants.dart';
import 'package:memox/core/backup/backup_data.dart';
import 'package:memox/core/backup/google_drive_service.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  const BackupService(this._db, this._driveService, this._logger);

  final AppDatabase _db;
  final GoogleDriveService _driveService;
  final AppLogger _logger;

  Future<String> exportToJson() async {
    final folders = await _db.folderDao.getAll();
    final decks = await _db.deckDao.getAll();
    final cards = await _db.cardDao.getAll();
    final sessions = await _db.studySessionDao.getAll();
    final reviews = await _db.cardReviewDao.getAll();
    final payload = BackupPayload(
      version: BackupConstants.currentVersion,
      exportDate: DateTime.now().toIso8601String(),
      appVersion: BackupConstants.appVersion,
      folders: folders.map(_folderToJson).toList(),
      decks: decks.map(_deckToJson).toList(),
      cards: cards.map(_cardToJson).toList(),
      studySessions: sessions.map(_studySessionToJson).toList(),
      cardReviews: reviews.map(_cardReviewToJson).toList(),
    );
    return jsonEncode(payload.toJson());
  }

  Future<ImportResult> importFromJson(String jsonString) async {
    final payload = BackupPayload.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    if (payload.version > BackupConstants.currentVersion) {
      return const ImportFailure(
        'Backup version is newer than the current app version.',
      );
    }
    await _db.transaction(() async {
      await _db.cardReviewDao.deleteAll();
      await _db.studySessionDao.deleteAll();
      await _db.cardDao.deleteAll();
      await _db.deckDao.deleteAll();
      await _db.folderDao.deleteAll();

      for (final folder in payload.folders) {
        await _db.folderDao.insertFolder(_folderFromJson(folder));
      }
      for (final deck in payload.decks) {
        await _db.deckDao.insertDeck(_deckFromJson(deck));
      }
      for (final card in payload.cards) {
        await _db.cardDao.insertCard(_cardFromJson(card));
      }
      for (final session in payload.studySessions) {
        await _db.studySessionDao.insertSession(_studySessionFromJson(session));
      }
      for (final review in payload.cardReviews) {
        await _db.cardReviewDao.insertReview(_cardReviewFromJson(review));
      }
    });
    _logger.info('Imported backup payload with ${payload.cards.length} cards');
    return ImportResult.success(
      folders: payload.folders.length,
      decks: payload.decks.length,
      cards: payload.cards.length,
    );
  }

  Future<BackupResult> backupToDrive() async {
    final jsonString = await exportToJson();
    final fileName =
        '${BackupConstants.backupPrefix}${DateTime.now().millisecondsSinceEpoch}'
        '${BackupConstants.backupFileExtension}';
    final fileId = await _driveService.uploadBackup(
      fileName: fileName,
      bytes: utf8.encode(jsonString),
      mimeType: BackupConstants.backupMimeType,
    );
    if (fileId == null) {
      return const BackupFailure('Google account is not signed in.');
    }
    _logger.info('Backed up MemoX data to Drive as $fileName');
    return BackupResult.success(fileId: fileId, fileName: fileName);
  }

  Future<ImportResult> restoreFromDrive(String fileId) async {
    final bytes = await _driveService.downloadBackup(fileId);
    if (bytes == null) {
      return const ImportFailure('Download failed.');
    }
    return importFromJson(utf8.decode(bytes));
  }

  Future<List<BackupInfo>> listDriveBackups() async {
    final files = await _driveService.listBackups();
    return files.map((file) {
      final size = int.tryParse(file.size ?? '0') ?? 0;
      return BackupInfo(
        fileId: file.id ?? '',
        fileName: file.name ?? '',
        modifiedTime: file.modifiedTime,
        sizeBytes: size,
      );
    }).toList();
  }

  Future<String> exportToFile() async {
    final jsonString = await exportToJson();
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${BackupConstants.localExportFileName}',
    );
    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<ImportResult> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return const ImportFailure('File not found.');
    }
    final jsonString = await file.readAsString();
    return importFromJson(jsonString);
  }

  Map<String, dynamic> _folderToJson(FoldersTableData row) => <String, dynamic>{
    'id': row.id,
    'name': row.name,
    'parentId': row.parentId,
    'colorValue': row.colorValue,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'sortOrder': row.sortOrder,
  };

  Map<String, dynamic> _deckToJson(DecksTableData row) => <String, dynamic>{
    'id': row.id,
    'name': row.name,
    'description': row.description,
    'folderId': row.folderId,
    'colorValue': row.colorValue,
    'tags': row.tags,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'sortOrder': row.sortOrder,
  };

  Map<String, dynamic> _cardToJson(CardsTableData row) => <String, dynamic>{
    'id': row.id,
    'deckId': row.deckId,
    'front': row.front,
    'back': row.back,
    'hint': row.hint,
    'example': row.example,
    'tags': row.tags,
    'imagePath': row.imagePath,
    'status': row.status.name,
    'easeFactor': row.easeFactor,
    'interval': row.interval,
    'repetitions': row.repetitions,
    'nextReviewDate': row.nextReviewDate?.toIso8601String(),
    'lastReviewedAt': row.lastReviewedAt?.toIso8601String(),
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _studySessionToJson(StudySessionsTableData row) =>
      <String, dynamic>{
        'id': row.id,
        'deckId': row.deckId,
        'mode': row.mode.name,
        'startedAt': row.startedAt.toIso8601String(),
        'completedAt': row.completedAt?.toIso8601String(),
        'totalCards': row.totalCards,
        'correctCount': row.correctCount,
        'wrongCount': row.wrongCount,
        'durationSeconds': row.durationSeconds,
      };

  Map<String, dynamic> _cardReviewToJson(CardReviewsTableData row) =>
      <String, dynamic>{
        'id': row.id,
        'cardId': row.cardId,
        'sessionId': row.sessionId,
        'mode': row.mode.name,
        'rating': row.rating,
        'selfRating': row.selfRating,
        'isCorrect': row.isCorrect,
        'userAnswer': row.userAnswer,
        'responseTimeMs': row.responseTimeMs,
        'reviewedAt': row.reviewedAt.toIso8601String(),
      };

  FoldersTableCompanion _folderFromJson(Map<String, dynamic> json) =>
      FoldersTableCompanion(
        id: Value<int>(json['id'] as int),
        name: Value<String>(json['name'] as String),
        parentId: Value<int?>(json['parentId'] as int?),
        colorValue: Value<int>(json['colorValue'] as int),
        createdAt: Value<DateTime>(DateTime.parse(json['createdAt'] as String)),
        updatedAt: Value<DateTime>(DateTime.parse(json['updatedAt'] as String)),
        sortOrder: Value<int>(json['sortOrder'] as int),
      );

  DecksTableCompanion _deckFromJson(Map<String, dynamic> json) =>
      DecksTableCompanion(
        id: Value<int>(json['id'] as int),
        name: Value<String>(json['name'] as String),
        description: Value<String>(json['description'] as String),
        folderId: Value<int>(json['folderId'] as int),
        colorValue: Value<int>(json['colorValue'] as int),
        tags: Value<String>(json['tags'] as String),
        createdAt: Value<DateTime>(DateTime.parse(json['createdAt'] as String)),
        updatedAt: Value<DateTime>(DateTime.parse(json['updatedAt'] as String)),
        sortOrder: Value<int>(json['sortOrder'] as int),
      );

  CardsTableCompanion _cardFromJson(Map<String, dynamic> json) {
    final nextReviewDate = json['nextReviewDate'] as String?;
    final lastReviewedAt = json['lastReviewedAt'] as String?;
    return CardsTableCompanion(
      id: Value<int>(json['id'] as int),
      deckId: Value<int>(json['deckId'] as int),
      front: Value<String>(json['front'] as String),
      back: Value<String>(json['back'] as String),
      hint: Value<String>(json['hint'] as String),
      example: Value<String>(json['example'] as String),
      imagePath: Value<String>(json['imagePath'] as String),
      tags: Value<String>(json['tags'] as String? ?? ''),
      status: Value(CardStatus.values.byName(json['status'] as String)),
      easeFactor: Value<double>((json['easeFactor'] as num).toDouble()),
      interval: Value<int>(json['interval'] as int),
      repetitions: Value<int>(json['repetitions'] as int),
      nextReviewDate: Value<DateTime?>(
        nextReviewDate == null ? null : DateTime.parse(nextReviewDate),
      ),
      lastReviewedAt: Value<DateTime?>(
        lastReviewedAt == null ? null : DateTime.parse(lastReviewedAt),
      ),
      createdAt: Value<DateTime>(DateTime.parse(json['createdAt'] as String)),
      updatedAt: Value<DateTime>(DateTime.parse(json['updatedAt'] as String)),
    );
  }

  StudySessionsTableCompanion _studySessionFromJson(Map<String, dynamic> json) {
    final completedAt = json['completedAt'] as String?;
    return StudySessionsTableCompanion(
      id: Value<int>(json['id'] as int),
      deckId: Value<int>(json['deckId'] as int),
      mode: Value(StudyMode.values.byName(json['mode'] as String)),
      startedAt: Value<DateTime>(DateTime.parse(json['startedAt'] as String)),
      completedAt: Value<DateTime?>(
        completedAt == null ? null : DateTime.parse(completedAt),
      ),
      totalCards: Value<int>(json['totalCards'] as int),
      correctCount: Value<int>(json['correctCount'] as int),
      wrongCount: Value<int>(json['wrongCount'] as int),
      durationSeconds: Value<int>(json['durationSeconds'] as int),
    );
  }

  CardReviewsTableCompanion _cardReviewFromJson(Map<String, dynamic> json) =>
      CardReviewsTableCompanion(
        id: Value<int>(json['id'] as int),
        cardId: Value<int>(json['cardId'] as int),
        sessionId: Value<int>(json['sessionId'] as int),
        mode: Value(StudyMode.values.byName(json['mode'] as String)),
        rating: Value<int?>(json['rating'] as int?),
        selfRating: Value<int?>(json['selfRating'] as int?),
        isCorrect: Value<bool>(json['isCorrect'] as bool),
        userAnswer: Value<String>(json['userAnswer'] as String),
        responseTimeMs: Value<int>(json['responseTimeMs'] as int),
        reviewedAt: Value<DateTime>(
          DateTime.parse(json['reviewedAt'] as String),
        ),
      );
}
