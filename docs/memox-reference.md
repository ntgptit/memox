# MemoX — Comprehensive Reference

> Single source of truth for architecture, tokens, widgets, database, backup, DI, patterns, and conventions.
> Read relevant sections BEFORE implementing any feature.

---

## 1. Folder Structure

```text
lib/
├── app.dart                          # App widget, MaterialApp.router, responsive text scale
├── main.dart                         # Bootstrap: database init, runApp
│
├── core/
│   ├── backup/
│   │   ├── backup_constants.dart     # App version, Drive folder name
│   │   ├── backup_data.dart          # BackupData freezed model
│   │   ├── backup_service.dart       # Orchestrator: export/import + Drive
│   │   ├── google_auth_client.dart   # Auth HTTP client wrapper
│   │   └── google_drive_service.dart # Drive API: upload/download/list/delete
│   │
│   ├── constants/                    # App-wide constants
│   │
│   ├── database/
│   │   ├── app_database.dart         # AppDatabase class (@DriftDatabase)
│   │   ├── db_constants.dart         # DB name, version
│   │   ├── daos/
│   │   │   ├── card_dao.dart
│   │   │   ├── card_review_dao.dart
│   │   │   ├── deck_dao.dart
│   │   │   ├── folder_dao.dart
│   │   │   └── study_session_dao.dart
│   │   ├── tables/
│   │   │   ├── folders_table.dart
│   │   │   ├── decks_table.dart
│   │   │   ├── cards_table.dart
│   │   │   ├── card_reviews_table.dart
│   │   │   └── study_sessions_table.dart
│   │   └── migrations/
│   │       └── migration_strategy.dart
│   │
│   ├── design/
│   │   ├── card_status.dart          # CardStatus enum
│   │   └── study_mode.dart           # StudyMode enum
│   │
│   ├── errors/                       # App error types
│   ├── extensions/                   # Context extensions, date, string, etc.
│   ├── gen/                          # Generated l10n output
│   ├── guards/                       # Runtime guard utilities
│   ├── logging/                      # Logger setup
│   ├── mixins/                       # LoadingMixin, ScrollMixin
│   ├── providers/                    # Core-level Riverpod providers
│   ├── responsive/                   # ScreenType, breakpoints, adaptive values
│   ├── router/
│   │   └── app_router.dart           # GoRouter + StatefulShellRoute (4 tabs)
│   │
│   ├── services/
│   │   ├── database_export_service.dart       # Platform-conditional DB export
│   │   ├── database_export_service_factory.dart
│   │   ├── database_export_service_stub.dart
│   │   ├── database_export_service_web.dart
│   │   ├── file_picker_service.dart
│   │   ├── google_sign_in_service.dart        # Google Sign-In wrapper
│   │   ├── haptic_service.dart
│   │   ├── notification_service.dart
│   │   ├── secure_storage_service.dart
│   │   └── share_service.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData builder
│   │   ├── color_schemes/
│   │   │   ├── app_color_scheme.dart
│   │   │   └── custom_colors.dart    # CustomColors ThemeExtension
│   │   ├── text_themes/
│   │   │   ├── app_text_theme.dart
│   │   │   └── custom_text_styles.dart  # AppTextStyles ThemeExtension
│   │   └── tokens/
│   │       ├── color_tokens.dart
│   │       ├── duration_tokens.dart
│   │       ├── easing_tokens.dart
│   │       ├── elevation_tokens.dart
│   │       ├── opacity_tokens.dart
│   │       ├── radius_tokens.dart
│   │       ├── size_tokens.dart
│   │       ├── spacing_tokens.dart
│   │       └── typography_tokens.dart
│   │
│   ├── types/                        # Typedef aliases
│   └── utils/                        # Pure utility functions
│
├── shared/
│   ├── providers/
│   │   ├── connectivity_provider.dart
│   │   ├── locale_provider.dart
│   │   ├── seed_color_provider.dart
│   │   └── theme_mode_provider.dart
│   │
│   └── widgets/                      # 60+ shared widgets (see §5)
│       ├── animations/
│       ├── buttons/
│       ├── cards/
│       ├── chips/
│       ├── dialogs/
│       ├── feedback/
│       ├── inputs/
│       ├── layout/
│       ├── lists/
│       ├── navigation/
│       └── progress/
│
└── features/
    ├── cards/
    │   ├── data/          # daos, datasources, mappers, models, repositories, tables
    │   ├── domain/        # entities, repositories, usecases
    │   └── presentation/  # providers, screens, widgets
    │
    ├── decks/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/  # + models/ (view models)
    │
    ├── folders/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── search/
    │   ├── data/          # daos, mappers, repositories, tables (no datasources)
    │   ├── domain/
    │   └── presentation/
    │
    ├── settings/
    │   ├── data/          # daos, mappers, models, repositories, tables (no datasources)
    │   ├── domain/
    │   └── presentation/
    │
    ├── statistics/
    │   ├── data/
    │   ├── domain/        # + value_objects/
    │   └── presentation/
    │
    └── study/
        ├── data/
        ├── domain/        # + fill/, guess/, match/, srs/ (engine subdirs)
        └── presentation/

assets/
  icons/
  images/

l10n/
  app_en.arb
  app_ko.arb
  app_vi.arb

test/
  core/
    database/              # DAO integration tests (NativeDatabase.memory)
    extensions/
    mixins/
    responsive/
    theme/
  features/
    cards/    domain/usecases/, presentation/screens/, presentation/widgets/
    decks/    domain/usecases/, presentation/screens/, presentation/widgets/
    folders/  domain/usecases/, presentation/screens/, presentation/widgets/
    search/   domain/usecases/, presentation/screens/
    settings/ data/repositories/, domain/usecases/, presentation/providers,screens,widgets/
    statistics/ domain/usecases/, presentation/screens/
    study/    domain/fill,guess,match,srs,usecases/, presentation/providers,screens,widgets/
  shared/
    widgets/               # Smoke tests + targeted widget tests
  test_helpers/
    fakes/                 # Fake DAOs, repositories
    test_app.dart          # TestApp with responsive text scale

tools/
  guard/                   # Python guard CLI (see memox-guard-spec.md)
```

---

## 2. Design Tokens

All tokens live in `lib/core/theme/tokens/`. Import and use via class constants — never hardcode values.

### 2.1 Color Tokens (`color_tokens.dart`)

Material 3 seed-based. Access through context extensions:

```dart
// Theme colors
context.colors.primary
context.colors.onPrimary
context.colors.surface
context.colors.onSurface
context.colors.error
// etc.

// Custom colors (ThemeExtension<CustomColors>)
context.customColors.success
context.customColors.warning
context.customColors.info
context.customColors.mastery
context.customColors.streakActive
```

### 2.2 Typography Tokens (`typography_tokens.dart`)

Google Fonts "Plus Jakarta Sans". Constrained type scale: **48 / 32 / 24 / 20 / 16 / 14 / 12**.

| Size | Roles | Semantic names |
|------|-------|----------------|
| 48 | One dominant numeric stat per surface | `statDisplay` |
| 32 | Single hero title or hero term per screen/card | `displayLarge`, `displayMedium` |
| 24 | AppBar titles, dialog/sheet titles, strong stat values | `headlineLarge`, `titleLarge` |
| 20 | In-body headers, emphasized section titles | `headlineMedium` |
| 16 | Body text, list item titles, form input, button labels | `titleMedium`, `titleSmall`, `bodyLarge`, `bodyMedium` |
| 14 | Subtitles, filter/tag text, breadcrumb metadata | `bodySmall`, `labelLarge` |
| 12 | Metadata, overlines, micro labels, timestamps, badges | `labelMedium`, `labelSmall`, `caption` |

Access:

```dart
context.textTheme.bodyMedium     // Standard Material text theme
context.appTextStyles.statDisplay // Custom AppTextStyles extension
```

**Rules:**
- Never hardcode font sizes in feature UI.
- Never stack multiple 32px texts in the same viewport.
- 48px is for one dominant stat only — never for body copy.
- If a text role doesn't fit a bucket, adjust `lib/core/theme/**` — don't invent one-off sizes.

### 2.3 Spacing Tokens (`spacing_tokens.dart`)

```dart
SpacingTokens.xxs   // 2
SpacingTokens.xs    // 4
SpacingTokens.sm    // 8
SpacingTokens.md    // 12
SpacingTokens.lg    // 16
SpacingTokens.xl    // 20
SpacingTokens.xxl   // 24
SpacingTokens.xxxl  // 32
SpacingTokens.huge  // 48

// Gap widget shortcuts
Gap.xxs, Gap.xs, Gap.sm, Gap.md, Gap.lg, Gap.xl, Gap.xxl, Gap.xxxl, Gap.huge
```

### 2.4 Size Tokens (`size_tokens.dart`)

Component dimensions: icon sizes, button heights, avatar sizes, touch targets, etc.

```dart
SizeTokens.iconSm    // 16
SizeTokens.iconMd    // 20
SizeTokens.iconLg    // 24
SizeTokens.iconXl    // 32
SizeTokens.buttonHeight      // 48
SizeTokens.buttonHeightSm    // 36
SizeTokens.touchTarget       // 48
SizeTokens.avatarSm          // 32
SizeTokens.avatarMd          // 40
SizeTokens.avatarLg          // 56
```

### 2.5 Radius Tokens (`radius_tokens.dart`)

```dart
RadiusTokens.xs   // 4
RadiusTokens.sm   // 8
RadiusTokens.md   // 12
RadiusTokens.lg   // 16
RadiusTokens.xl   // 20
RadiusTokens.xxl  // 24
RadiusTokens.full // 999 (pill shape)
```

### 2.6 Duration Tokens (`duration_tokens.dart`)

```dart
DurationTokens.instant   // 100ms
DurationTokens.fast      // 200ms
DurationTokens.normal    // 300ms
DurationTokens.slow      // 400ms
DurationTokens.slower    // 600ms
```

### 2.7 Elevation Tokens (`elevation_tokens.dart`)

```dart
ElevationTokens.none     // 0
ElevationTokens.low      // 1
ElevationTokens.medium   // 3
ElevationTokens.high     // 6
ElevationTokens.highest  // 8
```

### 2.8 Easing Tokens (`easing_tokens.dart`)

```dart
EasingTokens.standard       // Curves.easeInOut
EasingTokens.decelerate     // Curves.decelerate
EasingTokens.accelerate     // Curves.easeIn
EasingTokens.sharp          // Curves.easeOutBack
EasingTokens.emphasized     // Curves.easeInOutCubicEmphasized
```

### 2.9 Opacity Tokens (`opacity_tokens.dart`)

```dart
OpacityTokens.disabled    // 0.38
OpacityTokens.hover       // 0.08
OpacityTokens.focus       // 0.12
OpacityTokens.pressed     // 0.12
OpacityTokens.dragged     // 0.16
```

---

## 3. Theme Extensions

### CustomColors (`core/theme/color_schemes/custom_colors.dart`)

```dart
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color warning;
  final Color info;
  final Color mastery;
  final Color streakActive;
  // + onSuccess, onWarning, successContainer, warningContainer, etc.
}

// Access
context.customColors.success
```

### AppTextStyles (`core/theme/text_themes/custom_text_styles.dart`)

```dart
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle statDisplay;    // 48px — hero stat
  final TextStyle caption;        // 12px — metadata
  // Maps to constrained type scale
}

// Access
context.appTextStyles.statDisplay
context.appTextStyles.caption
```

---

## 4. Context Extensions (`core/extensions/`)

```dart
// Theme shortcuts
context.colors         // ColorScheme
context.customColors   // CustomColors extension
context.textTheme      // TextTheme
context.appTextStyles  // AppTextStyles extension
context.theme          // ThemeData

// Navigation
context.go(path)
context.push(path)
context.pop()

// MediaQuery
context.screenSize
context.screenWidth
context.screenHeight
context.padding

// L10n
context.l10n           // AppLocalizations
```

---

## 5. Shared Widgets

All in `lib/shared/widgets/`. **MUST use these — do NOT recreate.**

### animations/
| Widget | Purpose |
|--------|---------|
| `CountUpAnimation` | Animated number counter |
| `FadeInWidget` | Fade-in entrance |
| `FlipCardWidget` | 3D card flip for review mode |
| `PulseWidget` | Pulsing emphasis animation |
| `ScaleTap` | Scale-down on tap feedback |
| `ShakeWidget` | Shake for error/wrong answer |
| `StaggerList` | Staggered list entrance |

### buttons/
| Widget | Purpose |
|--------|---------|
| `AppFab` | Floating action button |
| `AppPressable` | Material-ink tappable wrapper (surface/control interactions) |
| `AppTapRegion` | Opacity-touch tappable wrapper (inline/geometry interactions) |
| `IconActionButton` | Icon button with label |
| `InlineTextLinkButton` | Inline text link (opacity-touch path) |
| `PrimaryButton` | Primary action button |
| `SecondaryButton` | Secondary action button |
| `TextLinkButton` | Standalone text link (Material-ink path) |

### cards/
| Widget | Purpose |
|--------|---------|
| `AppCard` | All card surfaces — **no raw `Card()`** |
| `InfoBar` | Informational banner bar |
| `SelectableCard` | Card with selection state |
| `StatCard` | Statistic display card |

### chips/
| Widget | Purpose |
|--------|---------|
| `ModeChip` | Study mode indicator |
| `StatusChip` | Status badge |
| `StreakChip` | Streak display |
| `TagChip` | Tag/label chip |

### dialogs/
| Widget | Purpose |
|--------|---------|
| `AppDialog` | Base dialog wrapper |
| `ChoiceBottomSheet` | Multi-option bottom sheet |
| `ConfirmDialog` | Confirm/cancel dialog |
| `ExitSessionDialog` | Study session exit confirmation |
| `InputDialog` | Text input dialog |

### feedback/
| Widget | Purpose |
|--------|---------|
| `AppAsyncBuilder<T>` | All AsyncValue rendering — **no raw `.when()`** |
| `AppRefreshIndicator` | Pull-to-refresh |
| `EmptyStateView` | All empty states |
| `ErrorView` | Error display |
| `LoadingIndicator` | Spinner |
| `LoadingOverlay` | Full-screen loading overlay |
| `OfflineStateView` | No-connection state |
| `ScreenLoadingView` | Full-screen loading placeholder |
| `ScreenSkeletonLoader` | Skeleton shimmer loading |
| `SessionCompleteView` | All 5 study mode completion screens |
| `ShimmerBox` | Shimmer placeholder box |
| `SuccessIndicator` | Success checkmark animation |
| `Toast` | Feedback messages — **no raw `ScaffoldMessenger`** |
| `UnauthorizedStateView` | Auth-required state |

### inputs/
| Widget | Purpose |
|--------|---------|
| `AppSearchBar` | Search input |
| `AppSwitchTile` | Toggle switch tile |
| `AppTextField` | Themed text field |
| `ColorPicker` | Color selection |
| `StepperInput` | Numeric stepper |
| `TagInputField` | Tag entry field |

### layout/
| Widget | Purpose |
|--------|---------|
| `AdaptiveLayout` | Responsive layout wrapper |
| `AppScaffold` | App-level scaffold |
| `SectionContainer` | Content section grouping |
| `SliverScaffold` | Sliver-based scaffold |
| `Spacing` | Gap widget (prefer `Gap.*` constants) |

### lists/
| Widget | Purpose |
|--------|---------|
| `AnimatedListView` | List with entrance animations |
| `AppCardListTile` | List tile for **card surfaces** |
| `AppEditDeleteMenu` | Edit/delete popup menu |
| `AppListTile` | List tile for **flat list/sheet rows** |
| `AppReorderDragHandle` | Drag handle for reorder |
| `AppSlidableRow` | Swipe-to-delete row |
| `AppTileGlyph` | Leading icon/glyph for tiles |
| `ExpandableTile` | Collapsible tile |
| `ReorderModeBanner` | Reorder mode indicator |
| `ReorderableList` | Drag-to-reorder list |

### navigation/
| Widget | Purpose |
|--------|---------|
| `AppBottomNav` | Bottom navigation bar |
| `AppRootBottomNav` | Root-level bottom nav with StatefulShellRoute |
| `BreadcrumbBar` | Breadcrumb navigation |
| `EditorTopBar` | Editor screen top bar |
| `StudyTopBar` | All 5 study mode top bars |
| `TopBarActionRow` | Top bar action buttons row |
| `TopBarBackButton` | Back navigation button |
| `TopBarIconButton` | Top bar icon button |

### progress/
| Widget | Purpose |
|--------|---------|
| `CountUpText` | Animated counting text |
| `MasteryBar` | Linear mastery progress |
| `MasteryRing` | Circular mastery progress |
| `ProgressBar` | Generic progress bar |

---

## 6. Database (Drift)

### Tables (`core/database/tables/`)

| Table | Key columns | Notes |
|-------|-------------|-------|
| `FoldersTable` | id, name, color, sortOrder, createdAt, updatedAt | Root container |
| `DecksTable` | id, folderId (FK), name, color, sortOrder, createdAt, updatedAt | Belongs to folder |
| `CardsTable` | id, deckId (FK), front, back, hint, difficulty, dueDate, interval, easeFactor, reviewCount, sortOrder, createdAt, updatedAt | SRS fields for SM-2 |
| `CardReviewsTable` | id, cardId (FK), sessionId (FK), quality, responseTimeMs, reviewedAt | Per-review log |
| `StudySessionsTable` | id, deckId (FK), mode (intEnum), cardsStudied, correctCount, duration, startedAt, completedAt | Session summary |

### DAOs (`core/database/daos/`)

| DAO | Responsibilities |
|-----|-----------------|
| `FolderDao` | CRUD, recursive CTE queries, sort order, card counts |
| `DeckDao` | CRUD, folder scoping, sort order, mastery stats |
| `CardDao` | CRUD, SRS scheduling, due cards query, bulk operations |
| `CardReviewDao` | Insert reviews, history queries, streaks |
| `StudySessionDao` | Session lifecycle, statistics aggregation |

### Conventions

- Tables extend `Table`. Enums stored as `intEnum`.
- Reactive streams via `.watch()` — no manual StreamController.
- Foreign keys enforced. Cascade deletes handled at repository level.
- Migrations in `migrations/migration_strategy.dart`.
- Testing: `NativeDatabase.memory()` — never mock the database.

---

## 7. Google Drive Backup

### Architecture

```text
google_sign_in_service.dart   → Google Sign-In (signIn, signOut, silentSignIn)
google_auth_client.dart       → HTTP client with auth headers
google_drive_service.dart     → Drive API (appDataFolder): upload, download, list, delete
backup_service.dart           → Orchestrator: export DB → JSON → Drive, Drive → JSON → import DB
backup_data.dart              → BackupData freezed model (metadata + all tables)
backup_constants.dart         → App version, Drive folder name
```

### Flow

1. **Export**: Query all tables → build `BackupData` → serialize JSON → upload to Drive `appDataFolder`
2. **Import**: Download from Drive → deserialize JSON → validate version → clear + insert all tables in transaction
3. **Auth**: `google_sign_in` → `GoogleAuthClient` wraps HTTP client → `googleapis` DriveApi

### Dependencies

```yaml
google_sign_in: ^6.2.0
googleapis: ^13.2.0
http: ^1.2.0
```

No Firebase. No custom backend. All data stays in user's own Google Drive `appDataFolder`.

---

## 8. Dependency Injection — Pure Riverpod

No get_it. No injectable. All DI through `@riverpod` annotation + code generation.

### Provider Hierarchy

```text
Infrastructure (keepAlive)
  └── appDatabaseProvider          → AppDatabase instance
  └── sharedPreferencesProvider    → SharedPreferences
  └── googleSignInServiceProvider  → GoogleSignInService
  └── backupServiceProvider        → BackupService

DataSource (per feature)
  └── folderDaoProvider            → FolderDao(db)
  └── deckDaoProvider              → DeckDao(db)
  └── cardDaoProvider              → CardDao(db)
  └── cardReviewDaoProvider        → CardReviewDao(db)
  └── studySessionDaoProvider      → StudySessionDao(db)

Repository (per feature)
  └── folderRepositoryProvider     → FolderRepositoryImpl(dao)
  └── deckRepositoryProvider       → DeckRepositoryImpl(dao)
  └── cardRepositoryProvider       → CardRepositoryImpl(dao)
  └── ...

UseCase (per feature)
  └── createFolderProvider         → CreateFolder(repo)
  └── getFoldersProvider           → GetFolders(repo)
  └── ...

Presentation
  └── Feature-specific providers consuming use cases
```

### Conventions

- Infrastructure providers: `keepAlive: true`.
- Repository providers: depend on DAO providers. Return abstract repo type.
- UseCase providers: depend on repository providers. Return `Result<T>`.
- Presentation providers: depend on use case providers. Drive UI state.
- All use `@riverpod` annotation → code-generated `.g.dart` files.

---

## 9. L10n — Localization

### Setup

```yaml
# l10n.yaml
arb-dir: l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/core/gen
```

### Locales

- `app_en.arb` — English (template)
- `app_ko.arb` — Korean
- `app_vi.arb` — Vietnamese

### Access

```dart
context.l10n.folderName      // via context extension
AppLocalizations.of(context) // direct access
```

### Rules

- ALL user-visible strings must use `context.l10n.*`.
- Add keys to `app_en.arb` first, then other locales.
- Run `flutter gen-l10n` after editing `.arb` files.
- Use ICU message format for plurals and selects.

---

## 10. Coding Patterns

### No-Else Pattern (5 strategies)

```dart
// 1. Early return
if (items.isEmpty) return const EmptyStateView();
return ItemList(items: items);

// 2. Guard clause
final user = authState.user;
if (user == null) return const UnauthorizedStateView();
// proceed with user...

// 3. Switch expression
final label = switch (mode) {
  StudyMode.review => context.l10n.review,
  StudyMode.match  => context.l10n.match,
  StudyMode.guess  => context.l10n.guess,
  StudyMode.recall => context.l10n.recall,
  StudyMode.fill   => context.l10n.fill,
};

// 4. Conditional expression
final color = isActive ? context.colors.primary : context.colors.outline;

// 5. Value reassign
var status = CardStatus.new_;
if (card.reviewCount > 0) status = CardStatus.learning;
if (card.mastery >= 1.0) status = CardStatus.mastered;
```

### Result<T> Pattern

```dart
// Domain sealed class
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

// UseCase returns Result
class CreateFolder {
  final FolderRepository _repo;
  Future<Result<Folder>> call(String name) async {
    // validation...
    return _repo.create(name);
  }
}

// Presentation consumes
final result = await ref.read(createFolderProvider).call(name);
switch (result) {
  case Success(:final data): // handle success
  case Failure(:final error): // handle error
}
```

### Widget Composition (max 80 lines per widget)

```dart
// ❌ Bad — monolithic 200-line widget
class DeckDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 200 lines of UI...
  }
}

// ✅ Good — composed small widgets
class DeckDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      body: Column(
        children: [
          const DeckHeader(),
          const DeckCardList(),
          const DeckActionBar(),
        ],
      ),
    );
  }
}
```

### UseCase Pattern

```dart
// Abstract in domain
abstract class GetFolders {
  Future<Result<List<Folder>>> call();
}

// Impl in data (registered via Riverpod)
class GetFoldersImpl implements GetFolders {
  final FolderRepository _repo;
  const GetFoldersImpl(this._repo);

  @override
  Future<Result<List<Folder>>> call() => _repo.getAll();
}
```

---

## 11. Responsive System (`core/responsive/`)

### Breakpoints

```dart
enum ScreenType {
  compact,   // < 600dp  (phone)
  medium,    // 600–839dp (tablet portrait)
  expanded,  // ≥ 840dp  (tablet landscape, desktop)
}
```

### Usage

```dart
final screenType = ScreenType.of(context);

// Adaptive values
final columns = screenType.when(
  compact: () => 1,
  medium: () => 2,
  expanded: () => 3,
);

// Text scale (applied at app shell level)
final textScale = screenType.textScaleFactor;
```

### Mandatory

`lib/app.dart` and `test/test_helpers/test_app.dart` must apply `ScreenType.of(context).textScaleFactor` through `MediaQuery.textScaler`.

---

## 12. Mixins (`core/mixins/`)

### LoadingMixin

Provides `isLoading` state and `withLoading(Future)` wrapper for async operations.

### ScrollMixin

Provides `scrollController` with auto-dispose and scroll-to-top utility.

---

## 13. SOLID Principles — Flutter-Specific

| Principle | Rule |
|-----------|------|
| **S** — Single Responsibility | One widget = one visual concern. One use case = one business action. |
| **O** — Open/Closed | Extend via composition (new widget wrapping existing), not modification. |
| **L** — Liskov Substitution | Repository impls are interchangeable. Use abstract types in domain. |
| **I** — Interface Segregation | Small, focused repository interfaces per feature. No god-repository. |
| **D** — Dependency Inversion | Domain defines abstract repos. Data implements them. Presentation depends only on domain. |

---

## 14. UI Design Language Rules

- Do NOT ship raw Material defaults for prominent interactive controls (`TextField`, `ChoiceChip`, `SegmentedButton`, `PopupMenuButton`, `SwitchListTile`). Theme them centrally or use shared widgets.
- Do NOT use raw `InkWell` or `GestureDetector` in feature UI. Use `AppPressable`, `AppTapRegion`, `AppCard`, `TextLinkButton`, etc.
- **Material-ink path**: surface/control interactions (`AppCard`, `AppPressable`, `TextLinkButton`).
- **Opacity-touch path**: inline/geometry interactions where splash is wrong. Prefer `InlineTextLinkButton` over raw `AppTapRegion`.
- Shared row widgets must NOT self-own their card shell. Parent decides the surface.
- `AppListTile` = flat list/sheet rows. `AppCardListTile` = card-surface list items. Don't mix.
- New UI patterns → create/extend shared widget first in `lib/shared/widgets/**` or `lib/core/theme/**`, then use in feature.
- If a screen looks like default Flutter after implementation, treat as incomplete.
- State review: check visual hierarchy, spacing rhythm, empty/loading/error states, selected states, multiline behavior.

---

## 15. Testing Strategy

### Layers

| Layer | Approach |
|-------|----------|
| Database | Integration tests with `NativeDatabase.memory()`. No mocks. |
| Domain/UseCases | Unit tests with `mocktail` fakes for repositories. |
| Presentation | Widget tests with `ProviderScope` overrides and `TestApp`. |
| Shared widgets | Smoke tests + targeted interaction tests. |

### Test Helpers (`test/test_helpers/`)

- `test_app.dart` — `TestApp` widget with `ProviderScope`, theme, l10n, responsive text scale.
- `fakes/` — Fake DAOs and repositories for provider overrides.

### Conventions

- Test file naming: `<source_file>_test.dart`.
- Group tests by behavior, not by method name.
- Use `setUp` / `tearDown` for shared state.
- Prefer integration over mocking for database layer.

---

## 16. Analysis Options

Strict linting enabled. `flutter analyze` must pass with zero errors, warnings, and infos in touched files.

Key enforced rules:
- `prefer_const_constructors`
- `prefer_const_declarations`
- `avoid_unnecessary_containers`
- `prefer_single_quotes`
- `always_use_package_imports`
- `sort_child_properties_last`
- `use_build_context_synchronously`

---

## 17. Dependencies (pubspec.yaml)

### Production

| Category | Packages |
|----------|----------|
| State/DI | `flutter_riverpod`, `riverpod_annotation` |
| Database | `drift`, `drift_flutter`, `sqlite3_flutter_libs` |
| Auth/Backup | `google_sign_in`, `googleapis`, `http` |
| Navigation | `go_router` |
| Models | `freezed_annotation`, `json_annotation` |
| UI | `google_fonts`, `flutter_animate` |
| L10n | `intl` |
| Storage | `shared_preferences`, `path_provider`, `path` |
| Services | `flutter_local_notifications`, `share_plus`, `file_picker` |
| Utils | `characters`, `timezone` |

### Dev

| Category | Packages |
|----------|----------|
| Codegen | `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`, `drift_dev` |
| Testing | `mocktail`, `faker` |
| Linting | `flutter_lints` |

### NOT used (removed per migration)

- ~~isar~~ / ~~isar_flutter_libs~~ / ~~isar_generator~~
- ~~dio~~ / ~~retrofit~~ / ~~retrofit_generator~~
- ~~get_it~~ / ~~injectable~~
