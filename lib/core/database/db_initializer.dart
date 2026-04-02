import 'dart:io';

import 'package:isar/isar.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/database/migration_handler.dart';
import 'package:memox/features/cards/data/models/flashcard_model.dart';
import 'package:memox/features/decks/data/models/deck_model.dart';
import 'package:memox/features/folders/data/models/folder_model.dart';
import 'package:memox/features/settings/data/models/app_setting_model.dart';
import 'package:memox/features/statistics/data/models/statistics_snapshot_model.dart';
import 'package:memox/features/study/data/models/study_session_model.dart';
import 'package:path_provider/path_provider.dart';

final class DbInitializer {
  const DbInitializer({
    this.migrationHandler = const MigrationHandler(),
  });

  final MigrationHandler migrationHandler;

  Future<Isar> open() async {
    final directory = await _resolveDirectory();
    final isar = await Isar.open(
      [
        FolderModelSchema,
        DeckModelSchema,
        FlashcardModelSchema,
        StudySessionModelSchema,
        AppSettingModelSchema,
        StatisticsSnapshotModelSchema,
      ],
      directory: directory.path,
      name: DbConstants.dbName,
    );
    await migrationHandler.onOpen(isar);
    return isar;
  }

  Future<Directory> _resolveDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return Directory.systemTemp.createTemp('memox_db_');
    }
  }
}
