import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/database/migrations/migration_strategy.dart';
import 'package:memox/core/database/tables/card_reviews_table.dart';
import 'package:memox/core/database/tables/cards_table.dart';
import 'package:memox/core/database/tables/decks_table.dart';
import 'package:memox/core/database/tables/folders_table.dart';
import 'package:memox/core/database/tables/study_sessions_table.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';
part 'daos/card_dao.dart';
part 'daos/card_review_dao.dart';
part 'daos/deck_dao.dart';
part 'daos/folder_dao.dart';
part 'daos/study_session_dao.dart';

@DriftDatabase(
  tables: [
    FoldersTable,
    DecksTable,
    CardsTable,
    StudySessionsTable,
    CardReviewsTable,
  ],
  daos: [FolderDao, DeckDao, CardDao, StudySessionDao, CardReviewDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);

  static QueryExecutor _openConnection() => driftDatabase(
    name: DbConstants.databaseName,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse(DbConstants.webSqliteWasmFileName),
      driftWorker: Uri.parse(DbConstants.webDriftWorkerFileName),
    ),
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );

  Future<String> get databasePath async => p.join(
    (await getApplicationSupportDirectory()).path,
    DbConstants.sqliteFileName,
  );
}
