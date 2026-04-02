# MemoX — Personal Flashcard Learning App

## Project
Flutter 3.24+ / Dart 3.5+ flashcard app with 5 study modes (review, match, guess, recall, fill), SRS spaced repetition, Google Drive backup.

## Architecture
Feature-first Clean Architecture. Dependency flow: presentation → domain ← data.

```
lib/
  core/        # tokens, theme, router, utils, extensions, mixins, database, backup, services
  shared/      # reusable widgets (40+), shared providers
  features/    # folders, decks, cards, study, statistics, settings, search
    [feature]/data/          # tables, daos, mappers, repository impls
    [feature]/domain/        # entities, abstract repos, usecases, value objects
    [feature]/presentation/  # screens, widgets, providers, controllers
```

## Stack
- State + DI: Riverpod (`@riverpod` annotation, code-generated)
- Database: Drift (SQLite). Tables extend `Table`, queries via DAOs (`@DriftAccessor`)
- Auth/Backup: `google_sign_in` + `googleapis` (Drive appDataFolder)
- Navigation: GoRouter with StatefulShellRoute (4 tabs)
- UI: Material 3, Google Fonts "Plus Jakarta Sans", `flutter_animate`
- Models: freezed + json_serializable

## Build & verify
```bash
# Always run after code changes
flutter analyze
flutter test

# After editing freezed, Drift, or Riverpod files
dart run build_runner build --delete-conflicting-outputs

# After editing .arb files
flutter gen-l10n

# Run specific test file
flutter test test/path/to/test_file.dart
```

## Coding rules
- NO `else`. Use early return, guard clause, switch expression, or value reassign.
- NO hardcoded colors, sizes, spacing, radius, duration, strings. Use design tokens and l10n:
  - Colors: `context.colors.*`, `context.customColors.*`
  - Text: `context.textTheme.*`, `context.appTextStyles.*`
  - Spacing: `SpacingTokens.*`, `Gap.*`
  - Sizes: `SizeTokens.*`
  - Radius: `RadiusTokens.*`
  - Duration: `DurationTokens.*`
  - Strings: `context.l10n.*`
- Max 80 lines per widget file. Split into small composable widgets.
- Use `const` constructors everywhere possible.
- Use Dart 3.5 records, patterns, sealed classes.
- Use `Result<T>` sealed class for use case returns. No raw try-catch in domain.

## Required shared widgets
Do NOT recreate these. Import from `shared/widgets/`:
- `AppAsyncBuilder<T>` — all AsyncValue rendering
- `AppCard` — all cards
- `PrimaryButton` / `SecondaryButton` — all buttons
- `StudyTopBar` — all study mode top bars
- `SessionCompleteView` — all study completion screens
- `AppSlidableRow` — swipe-to-delete
- `EmptyStateView` — all empty states
- `MasteryBar` / `MasteryRing` — progress
- `Toast` — feedback messages

## Database (Drift)
- Tables: `core/database/tables/`. DAOs: `core/database/daos/`.
- Reactive streams via `.watch()`.
- Test with `NativeDatabase.memory()`, not mocks.
- Foreign keys enforced. Cascade deletes in repository.

## Validation checklist
Before considering any task complete:
1. `flutter analyze` passes with zero warnings.
2. `dart run build_runner build --delete-conflicting-outputs` succeeds.
3. Relevant tests pass.
4. No `else` keyword in new code.
5. No hardcoded values — all from tokens or l10n.
6. All new widgets use shared components listed above.
7. New files follow the feature folder structure.

## Reference docs
Read relevant sections BEFORE implementing:
- `docs/memox-folder-structure-and-codebase-foundation.md` → tokens, widget specs, responsive
- `docs/memox-codebase-supplement-advanced.md` → SOLID, patterns, l10n, providers
- `docs/memox-migration-isar-to-drift-gdrive-backup.md` → database, backup
- `docs/claude-code-memox-development-prompts.md` → phase-by-phase prompts
