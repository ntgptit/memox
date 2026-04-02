# 🔧 MemoX — Codebase Supplement: Advanced Architecture & Best Practices

> **Tài liệu bổ sung** cho `memox-folder-structure-and-codebase-foundation.md`.
> Tập trung vào: DI, l10n, retrofit, build_runner, SOLID, coding conventions,
> design language enforcement, và senior-level patterns.
>
> **Đây là tài liệu bắt buộc đọc** trước khi viết bất kỳ dòng code nào.

---

## 📂 FOLDER STRUCTURE BỔ SUNG

Những thư mục/files MỚI cần thêm vào cấu trúc đã có:

```
lib/
├── core/
│   │
│   ├── providers/                         # ━━━ Riverpod DI (thay thế Injectable + get_it) ━━━
│   │   ├── database_providers.dart        # Isar instance, SharedPreferences (keepAlive)
│   │   ├── network_providers.dart         # Dio instance, Retrofit clients (keepAlive)
│   │   ├── storage_providers.dart         # SharedPreferences, SecureStorage
│   │   ├── service_providers.dart         # NotificationService, ShareService, etc.
│   │   ├── repository_providers.dart      # All repository providers (bridges data → domain)
│   │   └── usecase_providers.dart         # All use case providers
│   │
│   ├── network/                           # ━━━ Network Layer (Retrofit + Dio) ━━━
│   │   ├── dio_client.dart                # Dio factory: interceptors, timeout, base config
│   │   ├── api_endpoints.dart             # Static const endpoints (future sync server)
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart      # Token injection (future)
│   │   │   ├── logging_interceptor.dart   # Request/response logging (debug only)
│   │   │   ├── error_interceptor.dart     # Map DioException → AppException
│   │   │   ├── retry_interceptor.dart     # Auto-retry on timeout/5xx
│   │   │   └── cache_interceptor.dart     # ETag / If-Modified-Since support
│   │   ├── api/
│   │   │   ├── sync_api.dart              # @RestApi: sync endpoints (Retrofit generated)
│   │   │   └── backup_api.dart            # @RestApi: backup/restore endpoints
│   │   └── dto/                           # Data Transfer Objects (API ↔ App boundary)
│   │       ├── folder_dto.dart            # @JsonSerializable
│   │       ├── deck_dto.dart
│   │       ├── card_dto.dart
│   │       └── sync_payload_dto.dart
│   │
│   ├── logging/                           # ━━━ Logging ━━━
│   │   ├── app_logger.dart                # Abstract logger interface
│   │   ├── logger_impl.dart               # Implementation (print in debug, no-op in release)
│   │   └── log_level.dart                 # Enum: debug, info, warning, error
│   │
│   ├── types/                             # ━━━ Type Definitions ━━━
│   │   ├── typedefs.dart                  # Common typedefs: Json, JsonList, Callback, etc.
│   │   ├── result.dart                    # Result<T> sealed class (Success | Failure)
│   │   └── either.dart                    # Either<L, R> if needed beyond Result
│   │
│   ├── guards/                            # ━━━ Precondition Guards ━━━
│   │   └── preconditions.dart             # Static assert helpers: requireNotEmpty, requirePositive
│   │
│   └── gen/                               # ━━━ Generated Barrel Exports ━━━
│       └── core_exports.dart              # barrel file: export all core modules
│
├── l10n/                                  # ━━━ Localization (Full Setup) ━━━
│   ├── app_en.arb                         # English (primary)
│   ├── app_vi.arb                         # Vietnamese
│   ├── app_kr.arb                         # Korean (target learner audience)
│   └── l10n.yaml                          # flutter gen-l10n config
│
├── features/
│   └── [each feature]/
│       ├── data/
│       │   ├── models/                    # Isar collections + freezed
│       │   ├── dto/                       # [NEW] Feature-specific DTOs for API
│       │   ├── mappers/                   # [NEW] DTO ↔ Model ↔ Entity mappers
│       │   ├── datasources/              # [NEW] Local + Remote data sources (separated)
│       │   │   ├── folder_local_datasource.dart
│       │   │   └── folder_remote_datasource.dart  # (future sync)
│       │   └── repositories/
│       │       └── folder_repository_impl.dart
│       ├── domain/
│       │   ├── entities/                  # Pure Dart, no dependencies
│       │   ├── repositories/             # Abstract interfaces only
│       │   ├── usecases/                 # Single-responsibility, Riverpod-provided
│       │   └── value_objects/            # [NEW] Validated value types
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           ├── providers/
│           └── controllers/              # [NEW] Screen-level logic (separates from widget)
│
└── bootstrap.dart                         # [NEW] App initialization sequence
```

---

## 🏗️ DEPENDENCY INJECTION — Pure Riverpod

### Chiến lược DI

```
Riverpod (annotation)   → Quản lý TẤT CẢ: object creation, DI wiring, 
                           reactive state, caching, auto-dispose

Tại sao KHÔNG dùng Injectable + get_it?
- MemoX là app offline-first, single-user, dependency graph đơn giản
- Riverpod annotation đã handle: lazy singleton, auto-dispose, family, keepAlive
- Thêm get_it = 2 hệ thống DI song song + bridge layer không cần thiết
- Ít boilerplate, ít generated code, ít abstraction layers để maintain
- Testing dễ hơn: dùng ProviderContainer.overrides thay vì getIt.registerSingleton

Khi nào CẦN Injectable + get_it?
- Multi-module monorepo (separate packages share DI container)
- Runtime dependency swap phức tạp (e.g. payment gateway by region)
- Pure Dart layers không biết Flutter/Riverpod
→ MemoX KHÔNG thuộc các trường hợp trên
```

### Pubspec dependencies

```yaml
dependencies:
  # State Management & DI (Riverpod handles both)
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

  # Network (future sync)
  dio: ^5.4.0
  retrofit: ^4.4.0

  # Code generation deps
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0

  # UI
  google_fonts: ^6.2.0
  flutter_animate: ^4.5.0
  go_router: ^14.0.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.0
  riverpod_lint: ^2.6.0
  isar_generator: ^3.1.0
  retrofit_generator: ^9.1.0

  # Testing
  mocktail: ^1.0.0
  faker: ^2.2.0
```

### Provider Hierarchy — Dependency Graph

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  ConsumerWidget → ref.watch(controllerProvider)          │
│                 → ref.watch(streamDataProvider)           │
└──────────────────────┬──────────────────────────────────┘
                       │ ref.watch / ref.read
┌──────────────────────▼──────────────────────────────────┐
│               PROVIDERS (Riverpod)                       │
│                                                          │
│  ┌─ Controller Providers ──── UI state management        │
│  │   @riverpod class FolderListController                │
│  │                                                       │
│  ├─ UseCase Providers ──── business logic                 │
│  │   @riverpod CreateFolderUseCase createFolderUseCase    │
│  │                                                       │
│  ├─ Repository Providers ──── data access                 │
│  │   @Riverpod(keepAlive: true) FolderRepository          │
│  │                                                       │
│  ├─ DataSource Providers ──── raw data operations         │
│  │   @Riverpod(keepAlive: true) FolderLocalDataSource     │
│  │                                                       │
│  └─ Infrastructure Providers ──── platform services       │
│      @Riverpod(keepAlive: true) Isar, Dio, SharedPrefs    │
└──────────────────────┬──────────────────────────────────┘
                       │ constructor injection
┌──────────────────────▼──────────────────────────────────┐
│                DOMAIN (pure Dart)                         │
│  Entities, Value Objects, Repository Interfaces           │
│  UseCases (nhận abstract repos qua constructor)           │
└──────────────────────┬──────────────────────────────────┘
                       │ implements
┌──────────────────────▼──────────────────────────────────┐
│                    DATA                                   │
│  Repository Impls, Models, Mappers, DataSources           │
└─────────────────────────────────────────────────────────┘
```

### Infrastructure Providers (keepAlive — sống suốt app lifecycle)

```dart
// lib/core/providers/database_providers.dart

/// Isar instance — initialized once, lives forever.
/// Override in tests with mock Isar.
@Riverpod(keepAlive: true)
Future<Isar> isar(Ref ref) async {
  final isar = await Isar.open(
    [FolderModelSchema, DeckModelSchema, CardModelSchema, 
     StudySessionModelSchema, CardReviewModelSchema],
    directory: (await getApplicationDocumentsDirectory()).path,
    name: DbConstants.dbName,
  );
  ref.onDispose(() => isar.close());
  return isar;
}

/// SharedPreferences — initialized once.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}
```

```dart
// lib/core/providers/network_providers.dart

/// Dio client — configured once with interceptors.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }
  dio.interceptors.addAll([
    ErrorInterceptor(),
    RetryInterceptor(dio),
  ]);

  return dio;
}

/// Retrofit API client — depends on Dio.
@Riverpod(keepAlive: true)
SyncApi syncApi(Ref ref) {
  final dioInstance = ref.watch(dioProvider);
  return SyncApi(dioInstance);
}
```

### DataSource Providers

```dart
// lib/core/providers/datasource_providers.dart

@Riverpod(keepAlive: true)
FolderLocalDataSource folderLocalDataSource(Ref ref) {
  final isarInstance = ref.watch(isarProvider).requireValue;
  return FolderLocalDataSourceImpl(isarInstance);
}

/// Remote datasource — only used when sync is enabled.
/// Returns null if network not configured (offline-only mode).
@Riverpod(keepAlive: true)
FolderRemoteDataSource? folderRemoteDataSource(Ref ref) {
  final settings = ref.watch(settingsProvider);
  if (!settings.syncEnabled) return null;

  final api = ref.watch(syncApiProvider);
  return FolderRemoteDataSourceImpl(api);
}
```

### Repository Providers

```dart
// lib/core/providers/repository_providers.dart

/// Repository: wires local + optional remote datasources.
/// keepAlive because repositories manage streams that outlive screens.
@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  return FolderRepositoryImpl(
    localDataSource: ref.watch(folderLocalDataSourceProvider),
    remoteDataSource: ref.watch(folderRemoteDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) {
  return DeckRepositoryImpl(
    localDataSource: ref.watch(deckLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
CardRepository cardRepository(Ref ref) {
  return CardRepositoryImpl(
    localDataSource: ref.watch(cardLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) {
  return StudyRepositoryImpl(
    localDataSource: ref.watch(studyLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}
```

### UseCase Providers

```dart
// lib/core/providers/usecase_providers.dart

/// UseCases: auto-dispose by default (recreated when needed).
/// Depend on keepAlive repository providers.
@riverpod
CreateFolderUseCase createFolderUseCase(Ref ref) {
  return CreateFolderUseCase(
    folderRepo: ref.watch(folderRepositoryProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@riverpod
DeleteFolderUseCase deleteFolderUseCase(Ref ref) {
  return DeleteFolderUseCase(
    folderRepo: ref.watch(folderRepositoryProvider),
    deckRepo: ref.watch(deckRepositoryProvider),
    cardRepo: ref.watch(cardRepositoryProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@riverpod
CanCreateSubfolderUseCase canCreateSubfolderUseCase(Ref ref) {
  return CanCreateSubfolderUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
GetDueCardsUseCase getDueCardsUseCase(Ref ref) {
  return GetDueCardsUseCase(ref.watch(cardRepositoryProvider));
}

// ... pattern repeats for all use cases
```

### Repository Implementation (NO @LazySingleton — pure Dart)

```dart
// lib/features/folders/data/repositories/folder_repository_impl.dart

/// Repository impl — NO annotations, NO get_it.
/// Riverpod provider handles instantiation and lifecycle.
class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _localDataSource;
  final FolderRemoteDataSource? _remoteDataSource;
  final AppLogger _logger;

  const FolderRepositoryImpl({
    required FolderLocalDataSource localDataSource,
    required FolderRemoteDataSource? remoteDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _logger = logger;

  @override
  Stream<List<FolderEntity>> watchRootFolders() {
    return _localDataSource
        .watchByParent(null)
        .map((models) => models.map(FolderMapper.toEntity).toList());
  }

  @override
  Future<FolderEntity> create({
    required String name,
    String? parentId,
    required int colorValue,
  }) async {
    final model = FolderModel()
      ..name = name
      ..parentId = parentId
      ..colorValue = colorValue
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..sortOrder = await _localDataSource.getNextSortOrder(parentId);

    final saved = await _localDataSource.create(model);
    _logger.info('Created folder: ${saved.id}');
    return FolderMapper.toEntity(saved);
  }
}
```

### Testing với Riverpod — Override thay vì mock DI container

```dart
// test/features/folders/presentation/home_screen_test.dart

void main() {
  late MockFolderRepository mockRepo;

  setUp(() {
    mockRepo = MockFolderRepository();
  });

  testWidgets('HomeScreen shows folders', (tester) async {
    when(() => mockRepo.watchRootFolders())
        .thenAnswer((_) => Stream.value([_testFolder]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // ✅ Override tại provider level — không cần get_it
          folderRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Japanese N5'), findsOneWidget);
  });
}
```

---

## 🌍 L10N — Localization Đầy Đủ

### Setup

```yaml
# l10n.yaml (project root)
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: L10n
nullable-getter: false
synthetic-package: false
output-dir: lib/l10n/generated
```

### ARB Structure

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",

  "appName": "MemoX",

  "homeGreeting": "Good {timeOfDay}, {name}",
  "@homeGreeting": {
    "placeholders": {
      "timeOfDay": { "type": "String", "example": "morning" },
      "name": { "type": "String", "example": "Alex" }
    }
  },

  "homeDueCards": "{count, plural, =0{All caught up!} =1{You have 1 card due today} other{You have {count} cards due today}}",
  "@homeDueCards": {
    "placeholders": {
      "count": { "type": "int" }
    }
  },

  "folderSectionTitle": "My Folders",
  "folderSubtitleDecks": "{deckCount, plural, =1{1 deck} other{{deckCount} decks}} · {cardCount, plural, =1{1 card} other{{cardCount} cards}}",
  "folderSubtitleSubfolders": "{count, plural, =1{1 subfolder} other{{count} subfolders}}",
  "folderContainsSubfolders": "Contains {count, plural, =1{1 subfolder} other{{count} subfolders}}",
  "folderContainsDecks": "Contains {count, plural, =1{1 deck} other{{count} decks}} · {cardCount, plural, =1{1 card} other{{cardCount} cards}}",
  "folderConstraintHint": "To add decks here, organize them in a subfolder",

  "createFolder": "Create Folder",
  "createSubfolder": "Create Subfolder",
  "createDeck": "Create Deck",
  "deleteFolder": "Delete Folder",
  "deleteFolderConfirm": "This will permanently delete {itemCount, plural, =1{1 item} other{{itemCount} items}} inside this folder.",

  "deckDueToday": "{count, plural, =0{No cards due} =1{1 due today} other{{count} due today}}",
  "deckCardCount": "{count, plural, =1{1 card} other{{count} cards}}",
  "studyDueCards": "Study {count} due cards",
  "startStudying": "Start studying",
  "chooseStudyMode": "or choose a study mode",

  "modeReview": "Review",
  "modeReviewDesc": "Flip cards with spaced repetition",
  "modeMatch": "Match",
  "modeMatchDesc": "Pair terms with definitions",
  "modeGuess": "Guess",
  "modeGuessDesc": "Multiple choice from definitions",
  "modeRecall": "Recall",
  "modeRecallDesc": "Type what you remember",
  "modeFill": "Fill",
  "modeFillDesc": "Complete the missing word",

  "ratingAgain": "Again",
  "ratingHard": "Hard",
  "ratingGood": "Good",
  "ratingEasy": "Easy",

  "selfMissed": "Missed",
  "selfPartial": "Partial",
  "selfGotIt": "Got it",

  "sessionComplete": "Session complete",
  "cardsReviewed": "{count} cards reviewed",
  "accuracy": "{percent}% correct",
  "done": "Done",
  "studyMore": "Study more cards",
  "playAgain": "Play again",
  "tryAgain": "Try again",
  "skip": "Skip",
  "cancel": "Cancel",
  "save": "Save",
  "delete": "Delete",
  "edit": "Edit",
  "confirm": "Confirm",

  "progressTitle": "Your Progress",
  "periodWeek": "Week",
  "periodMonth": "Month",
  "periodAll": "All time",
  "dayStreak": "day streak",
  "todayStats": "Today: {cards} cards · {minutes} min",
  "cardsToFocusOn": "Cards to focus on",

  "settingsTitle": "Settings",
  "settingsAppearance": "Appearance",
  "settingsTheme": "Theme",
  "settingsThemeSystem": "System",
  "settingsThemeLight": "Light",
  "settingsThemeDark": "Dark",
  "settingsColor": "App color",
  "settingsStudying": "Studying",
  "settingsDailyGoal": "Daily goal",
  "settingsSessionLimit": "Session limit",
  "settingsNotifications": "Notifications",
  "settingsStudyReminder": "Study reminder",
  "settingsStreakReminder": "Streak reminder",
  "settingsData": "Data",
  "settingsExport": "Export cards",
  "settingsImport": "Import from file",
  "settingsClearHistory": "Clear study history",

  "emptyFolders": "No folders yet",
  "emptyFoldersSubtitle": "Create your first folder to start organizing",
  "emptyFolder": "This folder is empty",
  "emptyFolderSubtitle": "Add subfolders or decks to get started",
  "emptyDeck": "No cards yet",
  "emptyDeckSubtitle": "Add your first flashcard",
  "emptyDue": "All caught up!",
  "emptyDueSubtitle": "No cards due for review. Great job!",
  "emptyStats": "No study data yet",
  "emptyStatsSubtitle": "Complete a study session to see your progress",
  "emptySearch": "No results",
  "emptySearchSubtitle": "Try different keywords",

  "exitSessionTitle": "Exit study session?",
  "exitSessionMessage": "Your progress in this session will not be saved.",
  "exitSession": "Exit",
  "continueSession": "Continue"
}
```

### Access Pattern

```dart
// Truy cập trong widget — KHÔNG dùng AppStrings nữa
// AppStrings chỉ dùng cho non-user-facing constants (route names, db keys)

// ❌ WRONG — hardcode or old AppStrings
Text('No folders yet')
Text(AppStrings.emptyFolders)

// ✅ RIGHT — l10n
Text(context.l10n.emptyFolders)
Text(context.l10n.homeDueCards(dueCount))  // plural-aware

// Extension for convenience
// lib/core/extensions/context_extensions.dart (thêm vào file đã có)
extension BuildContextL10n on BuildContext {
  L10n get l10n => L10n.of(this);
}
```

---

## ⚙️ BUILD_RUNNER — Tận dụng tối đa Code Generation

### Tất cả generators active

```
Generator              │ Package                │ Generates
───────────────────────┼────────────────────────┼──────────────────────────────
freezed                │ freezed                │ .freezed.dart (union, copyWith, ==, hashCode)
json_serializable      │ json_serializable      │ .g.dart (fromJson, toJson)
riverpod_generator     │ riverpod_generator     │ .g.dart (@riverpod → providers + DI wiring)
isar_generator         │ isar_generator         │ .g.dart (Isar schemas)
retrofit_generator     │ retrofit_generator     │ .g.dart (@RestApi → Dio implementations)
flutter gen-l10n       │ flutter SDK            │ app_localizations.dart (l10n)
flutter_gen            │ flutter_gen            │ assets.gen.dart (type-safe asset refs)
```

### Build runner config

```yaml
# build.yaml (project root)
targets:
  $default:
    builders:
      freezed:
        options:
          format: true
          copy_with: true
          equal: true
          make_collector_public: false
          map: none               # dùng sealed class thay map
          when: none              # dùng switch expression thay when

      json_serializable:
        options:
          explicit_to_json: true
          field_rename: snake      # Dart camelCase ↔ API snake_case
          include_if_null: false
          create_factory: true

      riverpod_generator:
        options:
          provider_name_prefix: ''
          provider_family_name_prefix: ''
```

### Naming Conventions cho generated files

```
Model classes:       folder_model.dart        → folder_model.g.dart (Isar + JSON)
Freezed entities:    folder_entity.dart       → folder_entity.freezed.dart
DTOs:                folder_dto.dart          → folder_dto.g.dart (JSON only)
Providers:           folders_provider.dart    → folders_provider.g.dart (Riverpod)
Retrofit:            sync_api.dart            → sync_api.g.dart (Retrofit)
```

### Build commands

```bash
# Full rebuild (clean + generate all)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# L10n generation (separate from build_runner)
flutter gen-l10n

# Asset generation
dart run flutter_gen

# Combined script — tạo file scripts/generate.sh
#!/bin/bash
flutter gen-l10n
dart run flutter_gen
dart run build_runner build --delete-conflicting-outputs
echo "✅ All code generation complete"
```

---

## 🔒 SOLID — Tuân thủ nghiêm ngặt

### S — Single Responsibility

```dart
// ❌ WRONG — UseCase làm quá nhiều việc
class ManageFolderUseCase {
  Future<void> create(String name) { ... }
  Future<void> delete(String id) { ... }
  Future<void> rename(String id, String newName) { ... }
  Future<List<Folder>> getAll() { ... }
}

// ✅ RIGHT — Mỗi UseCase là 1 class, 1 method duy nhất
// Pure Dart class — Riverpod provider handles instantiation (see usecase_providers.dart)
class CreateFolderUseCase {
  final FolderRepository _repo;
  final AppLogger _logger;

  const CreateFolderUseCase(this._repo, this._logger);

  Future<Result<FolderEntity>> call(CreateFolderParams params) async {
    // single responsibility: create a folder
  }
}

class DeleteFolderUseCase {
  final FolderRepository _repo;
  final DeckRepository _deckRepo;

  const DeleteFolderUseCase(this._repo, this._deckRepo);

  Future<Result<void>> call(String folderId) async {
    // single responsibility: delete a folder with cascade
  }
}
```

### O — Open/Closed

```dart
// ❌ WRONG — Thêm study mode phải sửa engine
class StudyEngine {
  void processResult(StudyMode mode, CardEntity card, dynamic result) {
    if (mode == StudyMode.review) { ... }
    if (mode == StudyMode.match) { ... }
    // Thêm mode mới → sửa class này
  }
}

// ✅ RIGHT — Mở rộng bằng cách thêm class mới, không sửa class cũ
abstract class StudyModeProcessor {
  SRSResult process(CardEntity card, dynamic rawResult);
}

class ReviewProcessor implements StudyModeProcessor {
  @override
  SRSResult process(CardEntity card, dynamic rawResult) {
    final rating = rawResult as ReviewRating;
    return SRSEngine.processReview(card, rating);
  }
}

class MatchProcessor implements StudyModeProcessor {
  @override
  SRSResult process(CardEntity card, dynamic rawResult) {
    final attempts = rawResult as int;
    return SRSEngine.processMatchResult(card, attempts);
  }
}

// Thêm mode mới → tạo class mới, KHÔNG sửa code cũ
class NewModeProcessor implements StudyModeProcessor { ... }
```

### L — Liskov Substitution

```dart
// ❌ WRONG — Subclass phá vỡ contract của parent
abstract class DataSource {
  Future<List<FolderEntity>> getAll();
  Future<void> save(FolderEntity folder);
}

class ReadOnlyDataSource extends DataSource {
  @override
  Future<void> save(FolderEntity folder) {
    throw UnsupportedError('Read-only!');  // Violates LSP!
  }
}

// ✅ RIGHT — Tách interface theo capability
abstract class ReadableDataSource {
  Future<List<FolderEntity>> getAll();
}

abstract class WritableDataSource {
  Future<void> save(FolderEntity folder);
}

abstract class DataSource implements ReadableDataSource, WritableDataSource {}

class ReadOnlyDataSource implements ReadableDataSource {
  @override
  Future<List<FolderEntity>> getAll() { ... }  // Only implements what it can
}
```

### I — Interface Segregation

```dart
// ❌ WRONG — Interface quá lớn, client phải implement thứ không cần
abstract class Repository {
  Stream<List<T>> watchAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<void> sync();           // Statistics không cần sync!
  Future<void> export();         // Cards không cần export!
}

// ✅ RIGHT — Tách thành interfaces nhỏ, compose khi cần
abstract class Readable<T> {
  Future<T?> getById(String id);
}

abstract class Watchable<T> {
  Stream<List<T>> watchAll();
}

abstract class Writable<T> {
  Future<T> create(T item);
  Future<void> update(T item);
}

abstract class Deletable {
  Future<void> delete(String id);
}

// Feature-specific: compose chỉ những gì cần
abstract class FolderRepository 
    implements Readable<FolderEntity>, 
               Watchable<FolderEntity>, 
               Writable<FolderEntity>, 
               Deletable {
  // Thêm methods riêng của folder
  Stream<List<FolderEntity>> watchRootFolders();
  Future<bool> hasSubfolders(String id);
  Future<bool> hasDecks(String id);
}
```

### D — Dependency Inversion

```dart
// ❌ WRONG — Presentation phụ thuộc trực tiếp vào Data layer
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isar = ref.watch(isarProvider);       // ← Biết DB cụ thể
    final folders = isar.folderModels.where()...; // ← Query trực tiếp
  }
}

// ✅ RIGHT — Presentation chỉ biết Domain interfaces
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(rootFoldersProvider);  // ← Chỉ biết Provider
    return folders.when(                              // ← AsyncValue handling
      data: (list) => FolderListView(folders: list),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }
}

// Provider ← UseCase ← Repository(abstract) ← Impl ← DataSource ← Isar
// Mũi tên dependency luôn hướng VÀO domain, không bao giờ hướng RA
```

---

## 🚫 CODING CONVENTIONS — Bắt buộc

### Rule 1: CẤM sử dụng `else` — Early Return / Reassign / Throw

```dart
// ━━━ PATTERN 1: Early Return ━━━

// ❌ CẤM
String getGreeting(int hour) {
  if (hour < 12) {
    return 'Good morning';
  } else if (hour < 17) {
    return 'Good afternoon';
  } else {
    return 'Good evening';
  }
}

// ✅ BẮT BUỘC — early return, không có else
String getGreeting(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}


// ━━━ PATTERN 2: Guard Clause (Throw Early) ━━━

// ❌ CẤM
Future<FolderEntity> createFolder(String name, String? parentId) async {
  if (name.isNotEmpty) {
    if (parentId != null) {
      final parent = await _repo.getById(parentId);
      if (parent != null) {
        if (!await _repo.hasDecks(parentId)) {
          return await _repo.create(name, parentId);
        } else {
          throw AppException.conflict('Folder already has decks');
        }
      } else {
        throw AppException.notFound('Parent folder not found');
      }
    } else {
      return await _repo.create(name, null);
    }
  } else {
    throw AppException.validation('Name cannot be empty');
  }
}

// ✅ BẮT BUỘC — guard clauses, flat structure, throw sớm
Future<FolderEntity> createFolder(String name, String? parentId) async {
  if (name.isEmpty) throw AppException.validation('Name cannot be empty');

  if (parentId == null) return _repo.create(name, null);

  final parent = await _repo.getById(parentId);
  if (parent == null) throw AppException.notFound('Parent folder not found');

  final hasDecks = await _repo.hasDecks(parentId);
  if (hasDecks) throw AppException.conflict('Folder already has decks');

  return _repo.create(name, parentId);
}


// ━━━ PATTERN 3: Reassign (Ghi đè giá trị) ━━━

// ❌ CẤM
Color getStatusColor(CardStatus status) {
  Color result;
  if (status == CardStatus.newCard) {
    result = ColorTokens.statusNew;
  } else if (status == CardStatus.learning) {
    result = ColorTokens.statusLearning;
  } else if (status == CardStatus.mastered) {
    result = ColorTokens.statusMastered;
  } else {
    result = ColorTokens.statusReviewing;
  }
  return result;
}

// ✅ BẮT BUỘC — switch expression (Dart 3), không else
Color getStatusColor(CardStatus status) {
  return switch (status) {
    CardStatus.newCard   => ColorTokens.statusNew,
    CardStatus.learning  => ColorTokens.statusLearning,
    CardStatus.reviewing => ColorTokens.statusReviewing,
    CardStatus.mastered  => ColorTokens.statusMastered,
  };
}


// ━━━ PATTERN 4: Nullable handling ━━━

// ❌ CẤM
Widget buildAvatar(User? user) {
  if (user != null) {
    if (user.avatarUrl != null) {
      return NetworkImage(user.avatarUrl!);
    } else {
      return DefaultAvatar(user.initials);
    }
  } else {
    return const PlaceholderAvatar();
  }
}

// ✅ BẮT BUỘC — early return
Widget buildAvatar(User? user) {
  if (user == null) return const PlaceholderAvatar();
  if (user.avatarUrl == null) return DefaultAvatar(user.initials);
  return NetworkImage(user.avatarUrl!);
}


// ━━━ PATTERN 5: Ternary cho assignments đơn giản ━━━

// ✅ OK cho 1 condition đơn giản
final label = isComplete ? context.l10n.done : context.l10n.continueSession;

// ❌ CẤM nested ternary
final label = isComplete ? 'Done' : hasErrors ? 'Retry' : 'Continue';

// ✅ Dùng early return hoặc switch thay nested ternary
String getLabel(bool isComplete, bool hasErrors) {
  if (isComplete) return context.l10n.done;
  if (hasErrors) return context.l10n.tryAgain;
  return context.l10n.continueSession;
}
```

### Rule 2: Widget Composition

```dart
// ❌ CẤM — Widget quá 80 dòng, build method quá lớn
class DeckDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(/* 15 lines */),
      body: Column(
        children: [
          // stats section: 20 lines
          // study button: 10 lines
          // card list: 30 lines
          // empty state: 15 lines
        ],
      ),
      floatingActionButton: FloatingActionButton(/* 5 lines */),
    );
    // Total: 100+ lines in single build
  }
}

// ✅ BẮT BUỘC — Tách thành composable widgets, mỗi cái < 80 dòng
class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({required this.deckId, super.key});
  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckDetailProvider(deckId));

    return deckAsync.when(
      data: (deck) => _DeckDetailContent(deck: deck),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(deckDetailProvider(deckId))),
    );
  }
}

class _DeckDetailContent extends StatelessWidget { ... }  // < 80 lines
class _DeckStatsRow extends StatelessWidget { ... }        // < 40 lines
class _StudyButton extends StatelessWidget { ... }         // < 30 lines
class _CardListSection extends ConsumerWidget { ... }      // < 60 lines
```

### Rule 3: UseCase Pattern

```dart
// ✅ Standard UseCase template — MỌI use case tuân theo pattern này
// KHÔNG dùng annotation — Riverpod provider handle instantiation
class CreateFolderUseCase {
  final FolderRepository _folderRepo;
  final AppLogger _logger;

  const CreateFolderUseCase({
    required FolderRepository folderRepo,
    required AppLogger logger,
  })  : _folderRepo = folderRepo,
        _logger = logger;

  /// Single public method. Tên luôn là `call` để dùng như function.
  Future<Result<FolderEntity>> call(CreateFolderParams params) async {
    // 1. Validate (throw early)
    if (params.name.isBlank) {
      return Result.failure(Failure.validation('Name cannot be empty'));
    }

    // 2. Business logic
    final isUnique = await _folderRepo.isNameUnique(params.name, params.parentId);
    if (!isUnique) {
      return Result.failure(Failure.conflict('Folder name already exists'));
    }

    // 3. Execute
    try {
      final folder = await _folderRepo.create(
        name: params.name,
        parentId: params.parentId,
        colorValue: params.colorValue,
      );
      _logger.info('Created folder: ${folder.id}');
      return Result.success(folder);
    } on Exception catch (e, stack) {
      _logger.error('Failed to create folder', e, stack);
      return Result.failure(Failure.storage(e.toString()));
    }
  }
}

// Params as freezed class
@freezed
class CreateFolderParams with _$CreateFolderParams {
  const factory CreateFolderParams({
    required String name,
    String? parentId,
    @Default(0xFF5C6BC0) int colorValue,
  }) = _CreateFolderParams;
}
```

### Rule 4: Result Type (thay thế try-catch ở mọi nơi)

```dart
// lib/core/types/result.dart

sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  // Pattern matching helpers
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      ResultFailure(:final failure) => failure(failure),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    ResultFailure() => null,
  };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}

// lib/core/types/failure.dart
@freezed
sealed class Failure with _$Failure {
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.notFound(String message) = NotFoundFailure;
  const factory Failure.conflict(String message) = ConflictFailure;
  const factory Failure.storage(String message) = StorageFailure;
  const factory Failure.network(String message, {int? statusCode}) = NetworkFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}
```

### Rule 5: Provider Organization

```dart
// ✅ MỌI provider file tuân theo template này

// ── 1. Repository providers (keepAlive — sống suốt app) ──
//    Defined in core/providers/repository_providers.dart (xem DI section)

// ── 2. UseCase providers (auto-dispose — tạo khi cần, huỷ khi không dùng) ──
//    Defined in core/providers/usecase_providers.dart (xem DI section)

// ── 3. Data stream/future providers (auto-dispose, reactive) ──
@riverpod
Stream<List<FolderEntity>> rootFolders(Ref ref) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.watchRootFolders();
}

@riverpod
Future<FolderDetail> folderDetail(Ref ref, String folderId) async {
  final repo = ref.watch(folderRepositoryProvider);
  // ...compose data
}

// ── 4. Controller notifiers (complex UI state) ──
@riverpod
class FolderListController extends _$FolderListController {
  @override
  FolderListState build() => const FolderListState.initial();

  Future<void> createFolder(CreateFolderParams params) async {
    state = const FolderListState.loading();
    final useCase = ref.read(createFolderUseCaseProvider);
    final result = await useCase(params);
    state = result.when(
      success: (_) => const FolderListState.success(),
      failure: (f) => FolderListState.error(f.message),
    );
  }
}
```

---

## 🔌 RETROFIT — API Layer (Future Sync)

```dart
// lib/core/network/api/sync_api.dart

@RestApi()
abstract class SyncApi {
  factory SyncApi(Dio dio, {String? baseUrl}) = _SyncApi;  // Generated

  @POST('/api/v1/sync/push')
  Future<SyncResponse> pushChanges(@Body() SyncPayloadDto payload);

  @GET('/api/v1/sync/pull')
  Future<SyncPayloadDto> pullChanges(@Query('since') String lastSyncTimestamp);

  @POST('/api/v1/backup')
  Future<BackupResponse> createBackup(@Body() ExportDto data);

  @GET('/api/v1/backup/{id}')
  Future<ExportDto> getBackup(@Path('id') String backupId);
}

// lib/core/network/dto/folder_dto.dart
@JsonSerializable()
class FolderDto {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'parent_id')
  final String? parentId;

  @JsonKey(name: 'color_value')
  final int colorValue;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  const FolderDto({...});

  factory FolderDto.fromJson(Map<String, dynamic> json) => _$FolderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FolderDtoToJson(this);
}
```

### Data Source Separation

```dart
// lib/features/folders/data/datasources/folder_local_datasource.dart

abstract class FolderLocalDataSource {
  Stream<List<FolderModel>> watchAll();
  Stream<List<FolderModel>> watchByParent(String? parentId);
  Future<FolderModel?> getById(String id);
  Future<FolderModel> create(FolderModel model);
  Future<void> update(FolderModel model);
  Future<void> delete(String id);
}

/// NO annotations — Riverpod provider handles lifecycle.
class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  final Isar _isar;
  const FolderLocalDataSourceImpl(this._isar);
  // ... Isar operations
}

// lib/features/folders/data/datasources/folder_remote_datasource.dart

abstract class FolderRemoteDataSource {
  Future<List<FolderDto>> fetchAll(String sinceTimestamp);
  Future<void> pushChanges(List<FolderDto> folders);
}

/// NO annotations — conditionally provided via Riverpod provider.
/// Provider returns null when sync is disabled (see datasource_providers.dart).
class FolderRemoteDataSourceImpl implements FolderRemoteDataSource {
  final SyncApi _api;
  const FolderRemoteDataSourceImpl(this._api);
  // ... Retrofit API calls
}
```

### Mapper Layer

```dart
// lib/features/folders/data/mappers/folder_mapper.dart

abstract class FolderMapper {
  static FolderEntity toEntity(FolderModel model) {
    return FolderEntity(
      id: model.id.toString(),
      name: model.name,
      parentId: model.parentId,
      color: Color(model.colorValue),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      sortOrder: model.sortOrder,
    );
  }

  static FolderModel toModel(FolderEntity entity) {
    return FolderModel()
      ..name = entity.name
      ..parentId = entity.parentId
      ..colorValue = entity.color.value
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..sortOrder = entity.sortOrder;
  }

  static FolderDto toDto(FolderEntity entity) {
    return FolderDto(
      id: entity.id,
      name: entity.name,
      parentId: entity.parentId,
      colorValue: entity.color.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      sortOrder: entity.sortOrder,
    );
  }

  static FolderEntity fromDto(FolderDto dto) {
    return FolderEntity(
      id: dto.id,
      name: dto.name,
      parentId: dto.parentId,
      color: Color(dto.colorValue),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      sortOrder: dto.sortOrder,
    );
  }
}
```

---

## 🧱 VALUE OBJECTS — Domain Validation

```dart
// lib/features/folders/domain/value_objects/folder_name.dart

/// Self-validating value object. Throws on invalid construction.
/// Guarantees name is always valid wherever FolderName is used.
@immutable
class FolderName {
  final String value;

  FolderName(String input) : value = _validate(input);

  static String _validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) throw AppException.validation('Folder name cannot be empty');
    if (trimmed.length > 100) throw AppException.validation('Folder name too long');
    if (trimmed.contains('/')) throw AppException.validation('Folder name cannot contain /');
    return trimmed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FolderName && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

// lib/features/study/domain/value_objects/ease_factor.dart

@immutable
class EaseFactor {
  static const double minimum = 1.3;
  static const double defaultValue = 2.5;
  static const double maximum = 5.0;

  final double value;

  EaseFactor(double input) : value = input.clamp(minimum, maximum);

  EaseFactor adjust(int quality) {
    final newValue = value + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return EaseFactor(newValue);
  }
}
```

---

## 📐 RESPONSIVE DESIGN — Chi tiết Enforcement

### Adaptive Widget Patterns

```dart
// ✅ MỌI screen phải dùng adaptive padding
class DeckDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      // AppScaffold tự xử lý responsive padding
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.screenType.maxContentWidth,  // 840dp max
        ),
        child: const _DeckDetailContent(),
      ),
    );
  }
}

// ✅ Grid adapts
class FolderListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final columns = context.screenType.gridColumns;

    // Compact: vertical list (1 column)
    if (columns == 1) return _buildList();

    // Medium+: grid
    return _buildGrid(columns);
  }
}

// ✅ Study mode cards adapt
class FlashcardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardWidth = switch (context.screenType) {
      ScreenType.compact  => context.screenWidth - (SpacingTokens.xl * 2),
      ScreenType.medium   => 400.0,
      ScreenType.expanded => 480.0,
    };
    // ...
  }
}
```

### Safe Area Handling

```dart
// ✅ AppScaffold xử lý safe area thống nhất
class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final bool useSafeArea;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    required this.body,
    this.floatingActionButton,
    this.appBar,
    this.useSafeArea = true,
    this.extendBodyBehindAppBar = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: body) : body;

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenType.screenPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.screenType.maxContentWidth,
            ),
            child: content,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
```

---

## 🎨 DESIGN LANGUAGE ENFORCEMENT

### Consistency Checklist (mỗi screen phải pass)

```
□ Typography: context.textTheme.* hoặc context.appTextStyles.* — KHÔNG new TextStyle()
□ Colors: context.colors.* và context.customColors.* — KHÔNG Color(0x...)
□ Spacing: SpacingTokens.* và Gap.* — KHÔNG SizedBox(height: 16)
□ Sizes: SizeTokens.* cho component dimensions — KHÔNG magic numbers
□ Radius: RadiusTokens.* — KHÔNG BorderRadius.circular(16)
□ Duration: DurationTokens.* — KHÔNG Duration(milliseconds: 200)
□ Async data: AppAsyncBuilder — KHÔNG raw .when(data:, loading:, error:)
□ Cards: AppCard — KHÔNG tự tạo Card() hoặc Container+BoxDecoration
□ Buttons: PrimaryButton/SecondaryButton — KHÔNG tự style ElevatedButton
□ Lists: AppSlidableRow cho swipe actions — KHÔNG raw Dismissible
□ Progress: MasteryBar/MasteryRing — KHÔNG tự tạo
□ Empty states: EmptyStateView — KHÔNG inline empty UI
□ Loading: LoadingIndicator — KHÔNG tự tạo CircularProgressIndicator
□ Session end: SessionCompleteView — KHÔNG tự build cho mỗi mode
□ Study top bar: StudyTopBar — KHÔNG tự build cho mỗi mode
□ Feedback: Toast — KHÔNG ScaffoldMessenger trực tiếp
□ Icons: Outlined style only — KHÔNG Icons.folder (filled)
□ Animations: DurationTokens + EasingTokens — KHÔNG magic values
□ L10n: context.l10n.* — KHÔNG hardcode strings
□ Responsive: context.screenType aware — KHÔNG fixed widths
□ Text scaling: study mode text uses textScaleFactor — KHÔNG fixed fontSize
```

### Widget Token Audit Script

```dart
// test/core/theme/design_token_audit_test.dart

/// Chạy test này để phát hiện vi phạm design tokens.
/// Scan toàn bộ lib/ cho hardcoded values.

import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('No hardcoded colors in lib/', () {
    final violations = <String>[];
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/tokens/'))     // exclude token defs
        .where((f) => !f.path.contains('.g.dart'))       // exclude generated
        .where((f) => !f.path.contains('.freezed.dart'));

    final colorPattern = RegExp(r'Color\(0x[0-9A-Fa-f]+\)');
    final colorsPattern = RegExp(r'Colors\.\w+');

    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (colorPattern.hasMatch(lines[i]) || colorsPattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(violations, isEmpty, reason: 'Found hardcoded colors:\n${violations.join('\n')}');
  });

  test('No hardcoded durations in lib/', () {
    // Similar scan for Duration(milliseconds: N)
  });

  test('No hardcoded border radius in lib/', () {
    // Scan for BorderRadius.circular(N) where N is literal
  });

  test('No hardcoded font sizes in lib/', () {
    // Scan for fontSize: N where N is literal number
  });

  test('No else keyword in lib/', () {
    final violations = <String>[];
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('.g.dart'))
        .where((f) => !f.path.contains('.freezed.dart'));

    final elsePattern = RegExp(r'\}\s*else\s*\{');
    final elseIfPattern = RegExp(r'\}\s*else\s+if\s*\(');

    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (elsePattern.hasMatch(lines[i]) || elseIfPattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(violations, isEmpty, reason: 'Found else keyword:\n${violations.join('\n')}');
  });
}
```

---

## 🧪 TESTING STRATEGY

### Test Layers

```
Layer          │ Coverage Target │ Tools
───────────────┼─────────────────┼──────────────────────
Value Objects  │ 100%            │ dart test
SRS Engine     │ 100%            │ dart test
Use Cases      │ 90%+            │ dart test + mocktail
Repositories   │ 80%+            │ dart test + Isar test
Mappers        │ 100%            │ dart test
Providers      │ 80%+            │ riverpod test
Key Widgets    │ 70%+            │ flutter_test
Design Tokens  │ Audit tests     │ dart test (file scan)
Integration    │ Critical flows  │ integration_test
```

### Mocktail Pattern

```dart
// ✅ Mock registration — mỗi repository có mock tương ứng
class MockFolderRepository extends Mock implements FolderRepository {}
class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late CreateFolderUseCase sut;
  late MockFolderRepository mockRepo;
  late MockAppLogger mockLogger;

  setUp(() {
    mockRepo = MockFolderRepository();
    mockLogger = MockAppLogger();
    sut = CreateFolderUseCase(mockRepo, mockLogger);
  });

  group('CreateFolderUseCase', () {
    test('returns failure when name is empty', () async {
      final result = await sut(const CreateFolderParams(name: ''));

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.create(
        name: any(named: 'name'),
        parentId: any(named: 'parentId'),
        colorValue: any(named: 'colorValue'),
      ));
    });

    test('returns success when folder created', () async {
      when(() => mockRepo.isNameUnique(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockRepo.create(
        name: any(named: 'name'),
        parentId: any(named: 'parentId'),
        colorValue: any(named: 'colorValue'),
      )).thenAnswer((_) async => _testFolder);

      final result = await sut(const CreateFolderParams(name: 'Test'));

      expect(result.isSuccess, isTrue);
    });
  });
}
```

---

## 🚀 BOOTSTRAP SEQUENCE

```dart
// lib/bootstrap.dart

/// App initialization sequence — chạy trước runApp.
/// Thứ tự quan trọng, KHÔNG thay đổi.
Future<void> bootstrap() async {
  // 1. Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. System UI (status bar, nav bar)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // NOTE: Database, settings, notifications are initialized lazily
  // via Riverpod providers (FutureProvider with keepAlive).
  // No manual initialization needed — Riverpod handles the graph.
}

// lib/main.dart
void main() async {
  await bootstrap();

  runApp(
    const ProviderScope(
      // No overrides in production — all wiring via @riverpod providers.
      // Overrides are used ONLY in tests.
      child: MemoXApp(),
    ),
  );
}

// lib/app.dart
class MemoXApp extends ConsumerWidget {
  const MemoXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch async providers that must resolve before app renders
    final isarAsync = ref.watch(isarProvider);
    final settingsAsync = ref.watch(settingsProvider);

    // Both must be ready before rendering
    if (isarAsync is AsyncLoading || settingsAsync is AsyncLoading) {
      return const MaterialApp(home: _SplashScreen());
    }

    final settings = settingsAsync.requireValue;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seedColor: Color(settings.seedColorValue)),
      darkTheme: AppTheme.dark(seedColor: Color(settings.seedColorValue)),
      themeMode: settings.themeMode,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

---

## 📦 ANALYSIS OPTIONS — Strict Linting

```yaml
# analysis_options.yaml

include: package:flutter_lints/flutter.yaml

analyzer:
  strict-casts: true
  strict-inference: true
  strict-raw-types: true
  errors:
    missing_return: error
    dead_code: warning
    unused_import: warning
    unnecessary_import: warning
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - '**/*.config.dart'
    - 'lib/l10n/generated/**'

linter:
  rules:
    # ── Errors ──
    - always_use_package_imports
    - avoid_dynamic_calls
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_type_to_string
    - cancel_subscriptions
    - close_sinks
    - discarded_futures
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unsafe_html

    # ── Style ──
    - always_declare_return_types
    - annotate_overrides
    - avoid_bool_literals_in_conditional_expressions
    - avoid_catching_errors
    - avoid_classes_with_only_static_members
    - avoid_escaping_inner_quotes
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_implementing_value_types
    - avoid_init_to_null
    - avoid_multiple_declarations_per_line
    - avoid_null_checks_in_equality_operators
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    - avoid_redundant_argument_values
    - avoid_renaming_method_parameters
    - avoid_return_types_on_setters
    - avoid_returning_null_for_void
    - avoid_returning_this
    - avoid_setters_without_getters
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_unnecessary_containers
    - avoid_unused_constructor_parameters
    - avoid_void_async
    - cascade_invocations
    - cast_nullable_to_non_nullable
    - combinators_ordering
    - conditional_uri_does_not_exist
    - constant_identifier_names
    - deprecated_consistency
    - directives_ordering
    - eol_at_end_of_file
    - exhaustive_cases
    - flutter_style_todos
    - join_return_with_assignment
    - leading_newlines_in_multiline_strings
    - library_annotations
    - missing_whitespace_between_adjacent_strings
    - no_leading_underscores_for_library_prefixes
    - no_leading_underscores_for_local_identifiers
    - no_literal_bool_comparisons
    - no_runtimeType_toString
    - noop_primitive_operations
    - null_check_on_nullable_type_parameter
    - omit_local_variable_types
    - one_member_abstracts: false  # Cho phép single-method interfaces (UseCase)
    - only_throw_errors
    - parameter_assignments
    - prefer_asserts_in_initializer_lists
    - prefer_asserts_with_message
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_constructors_over_static_methods
    - prefer_expression_function_bodies
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_int_literals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_mixin
    - prefer_null_aware_method_calls
    - prefer_null_aware_operators
    - prefer_single_quotes
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - require_trailing_commas
    - sized_box_for_whitespace
    - sized_box_shrink_expand
    - sort_child_properties_last
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - type_annotate_public_apis
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_breaks
    - unnecessary_const
    - unnecessary_constructor_name
    - unnecessary_lambdas
    - unnecessary_late
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_checks
    - unnecessary_null_in_if_null_operators
    - unnecessary_nullable_for_final_variable_declarations
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_raw_strings
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - unnecessary_to_list_in_spreads
    - use_colored_box
    - use_decorated_box
    - use_enums
    - use_full_hex_values_for_flutter_colors
    - use_if_null_to_conditional_assignment
    - use_is_even_rather_than_modulo
    - use_late_for_private_fields_and_variables
    - use_named_constants
    - use_raw_strings
    - use_setters_to_change_properties
    - use_string_buffers
    - use_string_in_part_of_directives
    - use_super_parameters
    - use_to_and_as_if_applicable

  # ── Riverpod-specific ──
  plugins:
    - custom_lint
```

---

## 📋 TỔNG KẾT — Những gì bổ sung so với tài liệu cũ

```
✅ BỔ SUNG MỚI
│
├── DI Layer (Pure Riverpod — không dùng Injectable + get_it)
│   ├── Provider hierarchy: Infrastructure → DataSource → Repository → UseCase → Controller
│   ├── keepAlive providers cho singletons (Isar, Dio, Repos)
│   ├── Auto-dispose providers cho UseCases và UI state
│   ├── Conditional providers (e.g. remote datasource only when sync enabled)
│   └── Testing: ProviderScope overrides thay vì mock DI container
│
├── Network Layer (Retrofit + Dio)
│   ├── Dio client factory with interceptors
│   ├── Retrofit API interfaces (@RestApi)
│   ├── DTO layer (API boundary objects)
│   ├── 5 interceptors: auth, logging, error, retry, cache
│   └── Data source separation: local vs remote
│
├── L10n (Full Implementation)
│   ├── l10n.yaml config
│   ├── Complete ARB file (80+ keys) with plurals
│   ├── Context extension: context.l10n
│   └── Multi-language ready (EN, VI, JA)
│
├── Build Runner Maximization
│   ├── 8 generators mapped with file conventions
│   ├── build.yaml config (freezed + json_serializable options)
│   ├── Generation script (scripts/generate.sh)
│   └── Naming convention guide for .g.dart / .freezed.dart
│
├── SOLID Enforcement
│   ├── 5 principles with Flutter-specific ❌/✅ examples
│   ├── Interface Segregation via composable abstract classes
│   ├── Dependency Inversion flow diagram
│   └── Open/Closed via StudyModeProcessor pattern
│
├── No-Else Convention
│   ├── 5 patterns: early return, guard clause, reassign, nullable, ternary
│   ├── Real code examples from MemoX domain
│   └── Automated audit test to detect violations
│
├── Architecture Additions
│   ├── Value Objects (self-validating domain types)
│   ├── Result<T> sealed class (replaces try-catch everywhere)
│   ├── Mapper layer (Entity ↔ Model ↔ DTO)
│   ├── DataSource separation (local + remote per feature)
│   ├── Controller layer (screen-level logic)
│   ├── Precondition guards
│   └── Bootstrap sequence (ordered initialization)
│
├── Testing Strategy
│   ├── Coverage targets per layer
│   ├── Mocktail pattern template
│   └── Design token audit tests (automated)
│
├── Quality Enforcement
│   ├── analysis_options.yaml (100+ lint rules, strict mode)
│   ├── Design language checklist (16 checkpoints per screen)
│   ├── Widget token audit script (automated CI check)
│   └── Logging system (abstracted, testable)
│
└── Responsive Enforcement
    ├── AppScaffold with auto maxWidth + safe area
    ├── Adaptive widget patterns (card sizes, grids)
    └── ScreenType-aware sizing examples
```
