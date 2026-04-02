# 🔄 MemoX — Migration: Isar → Drift + Google Drive Backup

> **File này OVERRIDE các phần tương ứng trong docs cũ.**
> Khi có conflict, file này là source of truth.
>
> **Ảnh hưởng:**
> - `memox-folder-structure-and-codebase-foundation.md` → database section, services
> - `memox-codebase-supplement-advanced.md` → pubspec, providers, datasource, network layer
> - `claude-code-memox-development-prompts.md` → CLAUDE.md, Phase 1.3, Phase 4.2

---

## 📦 STACK CHANGES

```
TRƯỚC (override)                    → SAU (dùng cái này)
─────────────────────────────────────────────────────────
isar + isar_flutter_libs             → drift + drift_flutter + sqlite3_flutter_libs
isar_generator                       → drift_dev
Isar collections (@Collection)       → Drift tables (extends Table)
Isar queries (fluent Dart)           → Drift queries (type-safe SQL + Dart)
IsarLink / IsarLinks                 → Foreign keys + JOIN queries
.g.dart (Isar schemas)               → .g.dart (Drift generated database)

dio + retrofit                       → googleapis + google_sign_in
retrofit_generator                   → (không cần — googleapis đã generated sẵn)
DTO layer (folder_dto, etc.)         → (không cần — backup dùng JSON từ entities)
5 interceptors                       → (không cần — không có REST API)
core/network/ folder                 → core/backup/ folder
"future sync" mindset                → "backup/restore to Drive" mindset
```

---

## 📦 PUBSPEC — Thay thế hoàn toàn phần dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management & DI
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

  # Database (SQLite via Drift)
  drift: ^2.22.0
  drift_flutter: ^0.2.0
  sqlite3_flutter_libs: ^0.5.0

  # Auth & Backup
  google_sign_in: ^6.2.0
  googleapis: ^13.2.0          # Google Drive API
  http: ^1.2.0                 # HTTP client for Drive API auth

  # Code generation annotations
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # UI
  google_fonts: ^6.2.0
  flutter_animate: ^4.5.0
  go_router: ^14.0.0

  # Utils
  path_provider: ^2.1.0
  path: ^1.9.0
  shared_preferences: ^2.3.0
  share_plus: ^10.1.0          # share sheet for manual export
  file_picker: ^8.1.0          # import from file

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.0
  riverpod_lint: ^2.6.0
  drift_dev: ^2.22.0           # Drift code generator

  # Testing
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  faker: ^2.2.0
```

**Removed**: isar, isar_flutter_libs, isar_generator, dio, retrofit, retrofit_generator

---

## 📂 FOLDER STRUCTURE — Thay thế sections

### Thay `core/database/` (cũ) bằng:

```
core/
├── database/
│   ├── app_database.dart          # @DriftDatabase, table registrations, _openConnection
│   ├── app_database.g.dart        # [GENERATED] by drift_dev
│   ├── tables/                    # ── Table definitions ──
│   │   ├── folders_table.dart     # class FoldersTable extends Table
│   │   ├── decks_table.dart
│   │   ├── cards_table.dart
│   │   ├── study_sessions_table.dart
│   │   └── card_reviews_table.dart
│   ├── daos/                      # ── Data Access Objects ──
│   │   ├── folder_dao.dart        # @DriftAccessor, queries for folders
│   │   ├── deck_dao.dart
│   │   ├── card_dao.dart
│   │   ├── study_session_dao.dart
│   │   └── card_review_dao.dart
│   └── migrations/
│       └── migration_strategy.dart # Versioned schema migrations
```

### Thay `core/network/` (cũ) bằng:

```
core/
├── backup/                        # ── Google Drive Backup ──
│   ├── backup_service.dart        # Export/import logic (JSON + .db)
│   ├── google_drive_service.dart  # Google Drive API wrapper (appDataFolder)
│   ├── google_auth_client.dart    # HTTP client with Google auth headers
│   ├── backup_data.dart           # BackupPayload freezed model
│   └── backup_constants.dart      # File names, MIME types, version
```

### Xóa hoàn toàn (không cần nữa):

```
# XÓA — không còn trong project
core/network/dio_client.dart
core/network/api_endpoints.dart
core/network/interceptors/*
core/network/api/*
core/network/dto/*
features/*/data/dto/*                  # feature-level DTOs
features/*/data/datasources/*_remote_* # remote datasources
```

### Thêm vào `core/services/`:

```
core/
├── services/
│   ├── google_sign_in_service.dart  # Google Sign-In wrapper
│   ├── notification_service.dart    # (giữ nguyên)
│   ├── share_service.dart           # (giữ nguyên)
│   ├── file_picker_service.dart     # (giữ nguyên)
│   └── haptic_service.dart          # (giữ nguyên)
```

---

## 🗃️ DRIFT DATABASE — Implementation

### Table Definitions

```dart
// lib/core/database/tables/folders_table.dart

class FoldersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get parentId => integer().nullable().references(FoldersTable, #id)();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF5C6BC0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
```

```dart
// lib/core/database/tables/decks_table.dart

class DecksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get folderId => integer().references(FoldersTable, #id)();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF5C6BC0))();
  TextColumn get tags => text().withDefault(const Constant(''))(); // JSON array string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
```

```dart
// lib/core/database/tables/cards_table.dart

class CardsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(DecksTable, #id)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get hint => text().withDefault(const Constant(''))();
  TextColumn get example => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().withDefault(const Constant(''))();
  IntColumn get status => intEnum<CardStatus>()();  // enum as int

  // SRS fields
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

```dart
// lib/core/database/tables/study_sessions_table.dart

class StudySessionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(DecksTable, #id)();
  IntColumn get mode => intEnum<StudyMode>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get totalCards => integer()();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}
```

```dart
// lib/core/database/tables/card_reviews_table.dart

class CardReviewsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer().references(CardsTable, #id)();
  IntColumn get sessionId => integer().references(StudySessionsTable, #id)();
  IntColumn get mode => intEnum<StudyMode>()();
  IntColumn get rating => integer().nullable()();       // ReviewRating as int
  IntColumn get selfRating => integer().nullable()();   // SelfRating as int
  BoolColumn get isCorrect => boolean()();
  TextColumn get userAnswer => text().withDefault(const Constant(''))();
  IntColumn get responseTimeMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get reviewedAt => dateTime()();
}
```

### Database Class

```dart
// lib/core/database/app_database.dart

@DriftDatabase(
  tables: [
    FoldersTable,
    DecksTable,
    CardsTable,
    StudySessionsTable,
    CardReviewsTable,
  ],
  daos: [
    FolderDao,
    DeckDao,
    CardDao,
    StudySessionDao,
    CardReviewDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Future schema migrations go here
      // await m.alterTable(TableMigration(foldersTable, ...));
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'memox_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  /// Export raw database file path (for .db backup)
  Future<String> get databasePath async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/memox_database.sqlite';
  }
}
```

### DAO Example

```dart
// lib/core/database/daos/folder_dao.dart

@DriftAccessor(tables: [FoldersTable])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  // ── Watch (reactive streams) ──
  Stream<List<FoldersTableData>> watchRootFolders() {
    return (select(foldersTable)
      ..where((f) => f.parentId.isNull())
      ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)])
    ).watch();
  }

  Stream<List<FoldersTableData>> watchByParent(int parentId) {
    return (select(foldersTable)
      ..where((f) => f.parentId.equals(parentId))
      ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)])
    ).watch();
  }

  // ── Read ──
  Future<FoldersTableData?> getById(int id) {
    return (select(foldersTable)..where((f) => f.id.equals(id)))
        .getSingleOrNull();
  }

  // ── Write ──
  Future<int> insertFolder(FoldersTableCompanion folder) {
    return into(foldersTable).insert(folder);
  }

  Future<bool> updateFolder(FoldersTableCompanion folder) {
    return update(foldersTable).replace(folder);
  }

  // ── Delete (cascade handled at repository level) ──
  Future<int> deleteById(int id) {
    return (delete(foldersTable)..where((f) => f.id.equals(id))).go();
  }

  // ── Business Logic Queries ──
  Future<bool> hasSubfolders(int folderId) async {
    final count = await (selectOnly(foldersTable)
      ..where(foldersTable.parentId.equals(folderId))
      ..addColumns([foldersTable.id.count()])
    ).map((row) => row.read(foldersTable.id.count())).getSingle();
    return (count ?? 0) > 0;
  }

  Future<bool> hasDecks(int folderId) async {
    final count = await (selectOnly(db.decksTable)
      ..where(db.decksTable.folderId.equals(folderId))
      ..addColumns([db.decksTable.id.count()])
    ).map((row) => row.read(db.decksTable.id.count())).getSingle();
    return (count ?? 0) > 0;
  }

  // ── Aggregation (JOIN queries — Drift's strength) ──
  Future<int> getRecursiveCardCount(int folderId) async {
    // Get all deck IDs in this folder and subfolders (recursive CTE)
    final query = customSelect(
      'WITH RECURSIVE sub AS ('
      '  SELECT id FROM folders_table WHERE id = ?1'
      '  UNION ALL'
      '  SELECT f.id FROM folders_table f JOIN sub s ON f.parent_id = s.id'
      ') '
      'SELECT COUNT(*) as cnt FROM cards_table '
      'WHERE deck_id IN (SELECT id FROM decks_table WHERE folder_id IN (SELECT id FROM sub))',
      variables: [Variable.withInt(folderId)],
      readsFrom: {foldersTable, db.decksTable, db.cardsTable},
    );
    final result = await query.getSingle();
    return result.read<int>('cnt');
  }
}
```

### Card DAO — SRS Query (Drift advantage)

```dart
// lib/core/database/daos/card_dao.dart (partial — key query)

@DriftAccessor(tables: [CardsTable])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Get due cards: nextReviewDate <= now OR new cards (never reviewed)
  /// Ordered: overdue first (oldest), then new cards
  Future<List<CardsTableData>> getDueCards(int deckId, {int limit = 20}) {
    return (select(cardsTable)
      ..where((c) => c.deckId.equals(deckId) & (
        c.nextReviewDate.isSmallerOrEqualValue(DateTime.now()) |
        c.status.equals(CardStatus.newCard.index)
      ))
      ..orderBy([
        (c) => OrderingTerm.asc(c.nextReviewDate),  // overdue first
        (c) => OrderingTerm.asc(c.createdAt),        // then oldest new
      ])
      ..limit(limit)
    ).get();
  }

  /// Mastery breakdown for a deck
  Future<({int total, int known, int learning, int newCards})> getMasteryBreakdown(int deckId) async {
    final all = await (select(cardsTable)
      ..where((c) => c.deckId.equals(deckId))
    ).get();

    return (
      total: all.length,
      known: all.where((c) => c.status == CardStatus.mastered.index).length,
      learning: all.where((c) => c.status == CardStatus.learning.index || c.status == CardStatus.reviewing.index).length,
      newCards: all.where((c) => c.status == CardStatus.newCard.index).length,
    );
  }

  /// Batch insert (for import / batch card creation)
  Future<void> insertBatch(List<CardsTableCompanion> cards) {
    return batch((b) => b.insertAll(cardsTable, cards));
  }
}
```

---

## 🔐 GOOGLE SIGN-IN + DRIVE BACKUP

### Google Sign-In Service

```dart
// lib/core/services/google_sign_in_service.dart

class GoogleSignInService {
  static const _scopes = [
    'https://www.googleapis.com/auth/drive.appdata', // hidden app folder only
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  /// Current signed-in user (null if not signed in)
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Silent sign-in (check if already signed in)
  Future<GoogleSignInAccount?> signInSilently() {
    return _googleSignIn.signInSilently();
  }

  /// Interactive sign-in (shows Google account picker)
  Future<GoogleSignInAccount?> signIn() {
    return _googleSignIn.signIn();
  }

  /// Sign out
  Future<void> signOut() {
    return _googleSignIn.signOut();
  }

  /// Get authenticated HTTP client for Drive API
  Future<http.BaseClient?> getAuthClient() async {
    final user = _googleSignIn.currentUser ?? await signInSilently();
    if (user == null) return null;

    final headers = await user.authHeaders;
    return GoogleAuthClient(headers);
  }
}

// lib/core/backup/google_auth_client.dart

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
```

### Google Drive Service

```dart
// lib/core/backup/google_drive_service.dart

class GoogleDriveService {
  final GoogleSignInService _authService;

  GoogleDriveService(this._authService);

  /// Get Drive API client (null if not signed in)
  Future<drive.DriveApi?> _getDriveApi() async {
    final client = await _authService.getAuthClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  /// Upload file to appDataFolder
  /// Returns Drive file ID (for update/delete later)
  Future<String?> uploadBackup({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    String? existingFileId,  // for overwrite
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    final driveFile = drive.File()
      ..name = fileName
      ..modifiedTime = DateTime.now().toUtc();

    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: mimeType,
    );

    drive.File response;

    // Update existing or create new
    if (existingFileId != null) {
      response = await driveApi.files.update(
        driveFile,
        existingFileId,
        uploadMedia: media,
      );
    } else {
      driveFile.parents = ['appDataFolder'];
      response = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );
    }

    return response.id;
  }

  /// Download backup file from appDataFolder
  Future<List<int>?> downloadBackup(String fileId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    final response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  /// List all backup files in appDataFolder
  Future<List<drive.File>> listBackups() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return [];

    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      orderBy: 'modifiedTime desc',
      $fields: 'files(id, name, modifiedTime, size)',
    );

    return fileList.files ?? [];
  }

  /// Delete a backup file
  Future<void> deleteBackup(String fileId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;
    await driveApi.files.delete(fileId);
  }
}
```

### Backup Service (Orchestrator)

```dart
// lib/core/backup/backup_service.dart

class BackupService {
  final AppDatabase _db;
  final GoogleDriveService _driveService;
  final AppLogger _logger;

  BackupService(this._db, this._driveService, this._logger);

  // ━━━ EXPORT (JSON) ━━━

  /// Export all data as JSON string
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
      studySessions: sessions.map(_sessionToJson).toList(),
      cardReviews: reviews.map(_reviewToJson).toList(),
    );

    return jsonEncode(payload.toJson());
  }

  // ━━━ IMPORT (JSON) ━━━

  /// Import from JSON string. Returns count of imported items.
  /// OVERWRITES all existing data (after confirmation).
  Future<ImportResult> importFromJson(String jsonString) async {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final payload = BackupPayload.fromJson(json);

    // Version check
    if (payload.version > BackupConstants.currentVersion) {
      return ImportResult.failure(
        'Backup version ${payload.version} is newer than app version. '
        'Please update the app.',
      );
    }

    // Clear existing data (in transaction)
    await _db.transaction(() async {
      await _db.cardReviewDao.deleteAll();
      await _db.studySessionDao.deleteAll();
      await _db.cardDao.deleteAll();
      await _db.deckDao.deleteAll();
      await _db.folderDao.deleteAll();

      // Insert in order (respecting foreign keys)
      for (final f in payload.folders) {
        await _db.folderDao.insertFolder(_folderFromJson(f));
      }
      for (final d in payload.decks) {
        await _db.deckDao.insertDeck(_deckFromJson(d));
      }
      for (final c in payload.cards) {
        await _db.cardDao.insertCard(_cardFromJson(c));
      }
      for (final s in payload.studySessions) {
        await _db.studySessionDao.insertSession(_sessionFromJson(s));
      }
      for (final r in payload.cardReviews) {
        await _db.cardReviewDao.insertReview(_reviewFromJson(r));
      }
    });

    _logger.info('Import complete: ${payload.cards.length} cards');

    return ImportResult.success(
      folders: payload.folders.length,
      decks: payload.decks.length,
      cards: payload.cards.length,
    );
  }

  // ━━━ GOOGLE DRIVE OPERATIONS ━━━

  /// Backup to Google Drive (JSON format)
  Future<BackupResult> backupToDrive() async {
    final jsonString = await exportToJson();
    final bytes = utf8.encode(jsonString);
    final fileName = 'memox_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    final fileId = await _driveService.uploadBackup(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );

    if (fileId == null) return BackupResult.failure('Not signed in');

    _logger.info('Backup to Drive: $fileName ($fileId)');
    return BackupResult.success(fileId: fileId, fileName: fileName);
  }

  /// Restore from Google Drive (specific backup)
  Future<ImportResult> restoreFromDrive(String fileId) async {
    final bytes = await _driveService.downloadBackup(fileId);
    if (bytes == null) return ImportResult.failure('Download failed');

    final jsonString = utf8.decode(bytes);
    return importFromJson(jsonString);
  }

  /// List available backups on Drive
  Future<List<BackupInfo>> listDriveBackups() async {
    final files = await _driveService.listBackups();
    return files.map((f) => BackupInfo(
      fileId: f.id ?? '',
      fileName: f.name ?? '',
      modifiedTime: f.modifiedTime,
      sizeBytes: int.tryParse(f.size ?? '0') ?? 0,
    )).toList();
  }

  // ━━━ LOCAL FILE OPERATIONS ━━━

  /// Export JSON to share sheet (no Google account needed)
  Future<String> exportToFile() async {
    final jsonString = await exportToJson();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/memox_backup.json');
    await file.writeAsString(jsonString);
    return file.path;
  }

  /// Import from local file
  Future<ImportResult> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return ImportResult.failure('File not found');
    }
    final jsonString = await file.readAsString();
    return importFromJson(jsonString);
  }
}
```

### Backup Models

```dart
// lib/core/backup/backup_data.dart

@freezed
class BackupPayload with _$BackupPayload {
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

  factory BackupPayload.fromJson(Map<String, dynamic> json) =>
      _$BackupPayloadFromJson(json);
}

@freezed
class BackupResult with _$BackupResult {
  const factory BackupResult.success({
    required String fileId,
    required String fileName,
  }) = BackupSuccess;
  const factory BackupResult.failure(String message) = BackupFailure;
}

@freezed
class ImportResult with _$ImportResult {
  const factory ImportResult.success({
    required int folders,
    required int decks,
    required int cards,
  }) = ImportSuccess;
  const factory ImportResult.failure(String message) = ImportFailure;
}

@freezed
class BackupInfo with _$BackupInfo {
  const factory BackupInfo({
    required String fileId,
    required String fileName,
    DateTime? modifiedTime,
    required int sizeBytes,
  }) = _BackupInfo;
}

// lib/core/backup/backup_constants.dart

abstract final class BackupConstants {
  static const int currentVersion = 1;
  static const String appVersion = '1.0.0';
  static const String backupMimeType = 'application/json';
  static const String backupPrefix = 'memox_backup_';
}
```

---

## 🔌 PROVIDERS — Override phần database + backup

```dart
// lib/core/providers/database_providers.dart (THAY THẾ HOÀN TOÀN)

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

// DAOs — truy cập trực tiếp từ database instance
@Riverpod(keepAlive: true)
FolderDao folderDao(Ref ref) => ref.watch(appDatabaseProvider).folderDao;

@Riverpod(keepAlive: true)
DeckDao deckDao(Ref ref) => ref.watch(appDatabaseProvider).deckDao;

@Riverpod(keepAlive: true)
CardDao cardDao(Ref ref) => ref.watch(appDatabaseProvider).cardDao;

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) => ref.watch(appDatabaseProvider).studySessionDao;

@Riverpod(keepAlive: true)
CardReviewDao cardReviewDao(Ref ref) => ref.watch(appDatabaseProvider).cardReviewDao;
```

```dart
// lib/core/providers/backup_providers.dart (MỚI)

@Riverpod(keepAlive: true)
GoogleSignInService googleSignInService(Ref ref) => GoogleSignInService();

@Riverpod(keepAlive: true)
GoogleDriveService googleDriveService(Ref ref) {
  return GoogleDriveService(ref.watch(googleSignInServiceProvider));
}

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) {
  return BackupService(
    ref.watch(appDatabaseProvider),
    ref.watch(googleDriveServiceProvider),
    ref.watch(appLoggerProvider),
  );
}

// Current Google account (reactive — UI updates when sign-in state changes)
@riverpod
Future<GoogleSignInAccount?> currentGoogleUser(Ref ref) async {
  final service = ref.watch(googleSignInServiceProvider);
  return service.signInSilently();
}
```

---

## ⚙️ BUILD_RUNNER — Generator table update

```
Generator              │ Package                │ Generates
───────────────────────┼────────────────────────┼──────────────────────────────
freezed                │ freezed                │ .freezed.dart (union, copyWith, ==, hashCode)
json_serializable      │ json_serializable      │ .g.dart (fromJson, toJson)
riverpod_generator     │ riverpod_generator     │ .g.dart (@riverpod → providers)
drift_dev              │ drift_dev              │ .g.dart (database, DAOs, type-safe queries)
flutter gen-l10n       │ flutter SDK            │ app_localizations.dart (l10n)
flutter_gen            │ flutter_gen            │ assets.gen.dart (type-safe asset refs)
```

**Removed**: isar_generator, retrofit_generator

```yaml
# build.yaml — thêm drift config
targets:
  $default:
    builders:
      drift_dev:
        options:
          store_date_time_values_as_text: true    # readable dates in DB
          named_parameters: true                   # named params in generated code
          generate_connect_constructor: false
```

---

## 🖥️ SETTINGS SCREEN — Backup/Restore UI

Override phần DATA trong Settings screen:

```
Section: ACCOUNT & BACKUP
- Google Account → nếu chưa đăng nhập: "Sign in with Google" button
                   nếu đã đăng nhập: avatar + email + "Sign out" text
- Backup to Drive → tap: show loading → call backupToDrive()
                    show: "Last backup: 2 hours ago" subtitle
- Restore from Drive → tap: show list of backups (BottomSheet)
                        mỗi item: filename + date + size
                        tap backup → confirm dialog → restore
- Auto-backup → Toggle (backup mỗi khi app goes to background + có thay đổi)

Section: DATA (LOCAL)
- Export to file (JSON) → tap → share sheet (no Google account needed)
- Import from file → tap → file picker → confirm → import
- Clear study history → tap → confirm dialog → delete sessions + reviews only
```

---

## 🧪 TESTING — Database tests với Drift

```dart
// test/core/database/folder_dao_test.dart

void main() {
  late AppDatabase db;
  late FolderDao dao;

  setUp(() {
    // Drift provides in-memory database for testing — no mock needed!
    db = AppDatabase(NativeDatabase.memory());
    dao = db.folderDao;
  });

  tearDown(() => db.close());

  test('insert and retrieve folder', () async {
    final id = await dao.insertFolder(
      FoldersTableCompanion.insert(name: 'Test Folder'),
    );

    final folder = await dao.getById(id);
    expect(folder?.name, 'Test Folder');
    expect(folder?.parentId, isNull);
  });

  test('hasSubfolders returns true when subfolders exist', () async {
    final parentId = await dao.insertFolder(
      FoldersTableCompanion.insert(name: 'Parent'),
    );
    await dao.insertFolder(
      FoldersTableCompanion.insert(
        name: 'Child',
        parentId: Value(parentId),
      ),
    );

    expect(await dao.hasSubfolders(parentId), isTrue);
    expect(await dao.hasDecks(parentId), isFalse);
  });

  test('watchRootFolders emits on changes', () async {
    final stream = dao.watchRootFolders();

    await dao.insertFolder(
      FoldersTableCompanion.insert(name: 'Folder 1'),
    );

    await expectLater(
      stream,
      emits(hasLength(1)),
    );
  });
}
```

---

## 📋 CLAUDE.md UPDATE — Thêm vào phần CODING RULES

```
DATABASE: Drift (SQLite) — KHÔNG Isar, KHÔNG raw sqflite
- Tables kế thừa Table class, define columns bằng getter methods
- DAOs dùng @DriftAccessor, mỗi table 1 DAO
- Queries: dùng Drift type-safe API, KHÔNG raw SQL trừ khi cần recursive CTE
- Reactive: dùng .watch() cho streams, KHÔNG tự wrap StreamController
- Testing: dùng NativeDatabase.memory() — KHÔNG mock database
- Enums: dùng intEnum<EnumType>() trong table definitions

BACKUP: Google Drive appDataFolder — KHÔNG Firebase, KHÔNG custom backend
- Auth: google_sign_in với scope drive.appdata only
- Format: JSON primary (safe across schema versions)
- Drive API: googleapis package, appDataFolder (hidden, app-only)
- Local fallback: export JSON via share sheet (no account needed)

REFERENCE DOCS (đọc TRƯỚC khi code):
- memox-folder-structure-and-codebase-foundation.md → tokens, widgets, specs
- memox-codebase-supplement-advanced.md → DI, SOLID, patterns, l10n
- memox-migration-isar-to-drift-gdrive-backup.md → database, backup (THIS FILE)
```

---

## 📋 CHECKLIST — Xác nhận scope thay đổi

```
THAY ĐỔI:
✅ Isar → Drift (SQLite)
   ├── Tables thay collections
   ├── DAOs thay raw queries
   ├── Foreign keys + JOINs thay IsarLinks
   ├── Type-safe generated queries
   ├── In-memory DB for testing (no mocks!)
   └── Schema migration built-in

✅ Retrofit + Dio → Google Drive API
   ├── google_sign_in (drive.appdata scope)
   ├── googleapis (Drive API)
   ├── BackupService (export/import JSON)
   ├── GoogleDriveService (upload/download/list)
   └── Local file export fallback

XÓA:
❌ isar, isar_flutter_libs, isar_generator
❌ dio, retrofit, retrofit_generator
❌ core/network/ (toàn bộ folder)
❌ DTO layer (folder_dto, deck_dto, etc.)
❌ Remote datasources
❌ 5 interceptors (auth, logging, error, retry, cache)

GIỮ NGUYÊN (không đổi):
✅ Riverpod (state management + DI)
✅ GoRouter (navigation)
✅ freezed + json_serializable
✅ flutter_animate
✅ Google Fonts
✅ Toàn bộ shared widgets
✅ Toàn bộ design tokens
✅ SOLID patterns, no-else rules
✅ Clean Architecture (data/domain/presentation)
✅ L10n, responsive, testing strategy
```
