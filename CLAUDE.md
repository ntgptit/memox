# MemoX — Personal Flashcard Learning App

## Project
Flutter 3.24+ / Dart 3.5+ flashcard app with 5 study modes (review, match, guess, recall, fill), SRS spaced repetition, Google Drive backup.

## Architecture
Feature-first Clean Architecture. Dependency flow: presentation → domain ← data. Never import data layer from presentation.

```
lib/
  core/        # tokens, theme, router, utils, extensions, mixins, database, backup, services
  shared/      # reusable widgets (40+), shared providers
  features/    # folders, decks, cards, study, statistics, settings, search
    [feature]/
      data/          # tables, daos, mappers, repository impls
      domain/        # entities, abstract repos, usecases, value objects
      presentation/  # screens, widgets, providers, controllers
```

## Stack
- State + DI: Riverpod (`@riverpod` annotation, code-generated). No get_it, no injectable.
- Database: Drift (SQLite). Tables extend `Table`, queries via DAOs with `@DriftAccessor`.
- Auth/Backup: `google_sign_in` + `googleapis` (Drive appDataFolder). No Firebase, no custom backend.
- Navigation: GoRouter with StatefulShellRoute (4 tabs).
- UI: Material 3 (`useMaterial3: true`), Google Fonts "Plus Jakarta Sans", `flutter_animate`.
- Models: freezed + json_serializable. Enums stored as intEnum in Drift tables.

## Commands
```bash
flutter analyze                                    # lint check
flutter test                                       # all tests
flutter test test/core/database/                   # database tests only
dart run build_runner build --delete-conflicting-outputs  # generate all code
flutter gen-l10n                                   # generate l10n
```

## Coding rules
- NO `else` keyword. Use early return, guard clauses, switch expressions, or reassign.
- NO hardcoded values: colors → `context.colors.*` / `context.customColors.*`, text styles → `context.textTheme.*` / `context.appTextStyles.*`, spacing → `SpacingTokens.*` / `Gap.*`, sizes → `SizeTokens.*`, radius → `RadiusTokens.*`, durations → `DurationTokens.*`, strings → `context.l10n.*`.
- Max 80 lines per widget. Tách thành composable widgets.
- `const` constructors everywhere possible.
- Dart 3.5 records, patterns, sealed classes when appropriate.
- `Result<T>` sealed class for use case return types. No raw try-catch in domain layer.

## Shared widgets (MUST use, do NOT recreate)
- `AppAsyncBuilder<T>` for all AsyncValue rendering (no raw `.when()`).
- `AppCard` for all cards (no raw `Card()`).
- `PrimaryButton` / `SecondaryButton` for buttons.
- `StudyTopBar` for all 5 study mode top bars.
- `SessionCompleteView` for all 5 study mode completion screens.
- `AppSlidableRow` for swipe-to-delete in lists.
- `EmptyStateView` for all empty states.
- `MasteryBar` / `MasteryRing` for progress indicators.
- `Toast` for feedback (no raw `ScaffoldMessenger`).

## Database (Drift)
- Tables in `core/database/tables/`. DAOs in `core/database/daos/`.
- Use `.watch()` for reactive streams. No manual StreamController.
- Testing: `NativeDatabase.memory()` — no mocks for database tests.
- Foreign keys enforced. Cascade deletes handled at repository level.

## Reference docs (read before implementing)
- `docs/memox-folder-structure-and-codebase-foundation.md` → all tokens, widget specs, responsive system
- `docs/memox-codebase-supplement-advanced.md` → SOLID, no-else patterns, l10n, provider hierarchy
- `docs/memox-migration-isar-to-drift-gdrive-backup.md` → database tables, DAOs, backup service
- `docs/claude-code-memox-development-prompts.md` → phase-by-phase implementation prompts

## Workflow
1. Read the relevant reference doc section BEFORE writing code.
2. Run `dart run build_runner build --delete-conflicting-outputs` after creating/editing freezed, Drift, or Riverpod files.
3. Run `flutter analyze` after each file change.
4. Run relevant tests after each feature completion.
5. When compacting, preserve: current task, modified files list, test status.
