# MemoX — Personal Flashcard Learning App

## Project

Flutter 3.24+ / Dart 3.5+ flashcard app with 5 study modes (review, match, guess, recall, fill), SRS spaced repetition, Google Drive backup.

## Architecture

Feature-first Clean Architecture. Dependency flow: presentation → domain ← data.

```text
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

## OpenSpace preference

- When OpenSpace is available, prefer using the `delegate-task` skill for non-trivial MemoX work.
- Use OpenSpace first for multi-step implementation, cross-file changes, repo-wide analysis, web research, automation, and tasks the user explicitly wants delegated.
- Keep work local when the task is trivial, a tiny read-only lookup is enough, the change is a very small single-file edit, or OpenSpace is unavailable or blocked.
- Treat this as a preference, not an absolute rule.

## Build & verify

```bash
# Always run the guard gate before marking a code task complete
python tools/guard/run.py --scope <scope>

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

After finishing implementation or any required code generation/build step,
run the guard gate before considering the work ready for review or completion.
Do not postpone guard execution until later in the workflow.

## Guard gate

Before marking any task complete, always run the smallest guard scope that
covers the changed area:

- `lib/core/**` -> `python tools/guard/run.py --scope core`
- `lib/shared/**` -> `python tools/guard/run.py --scope shared`
- `lib/features/**` or any feature scaffold -> `python tools/guard/run.py --scope features`
- `test/**` only -> `python tools/guard/run.py --scope test`
- touching multiple areas, root config, or unsure scope -> `python tools/guard/run.py --scope all`

Guard execution is mandatory for any task that changes Dart source, tests,
guard rules, or repo architecture instructions. Do not claim completion if the
guard command was skipped or failed. If Python dependencies are missing, report
the exact blocked command and missing package.

Recommended completion order:

1. Run `dart run build_runner build --delete-conflicting-outputs` when freezed, Drift, or Riverpod files changed.
2. Run `flutter gen-l10n` when `.arb` files changed.
3. Immediately after build/codegen finishes, run `python tools/guard/run.py --scope <derived_scope>`.
4. Run `flutter analyze`.
5. Run relevant tests, or `flutter test` for cross-cutting work.

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

## UI design language rules

- Do NOT ship raw Flutter Material defaults in feature UI when the control is visually prominent or interactive. This includes `TextField`, `ChoiceChip`, `SegmentedButton`, `PopupMenuButton`, `SwitchListTile`, and similar controls unless they are already centralized in theme or wrapped in a shared widget.
- If a new UI pattern is needed and no shared primitive exists yet, create or extend the shared/themed version first in `lib/shared/widgets/**` or `lib/core/theme/**`, then use that in the feature. Do not style ad hoc per screen.
- For UI tasks, passing logic tests is not enough. Review the screen for visual hierarchy, spacing rhythm, empty/loading/error states, selected states, multiline input behavior, and consistency with the rest of MemoX before marking the task complete.
- If a screen still looks like default Flutter after implementation, treat that as incomplete even if functionality works.
- If there is a reason to intentionally diverge from the existing design language, state that reason explicitly and get alignment instead of silently shipping the deviation.

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

1. `python tools/guard/run.py --scope <derived_scope>` passes for the affected area.
2. `flutter analyze` passes with zero warnings.
3. `dart run build_runner build --delete-conflicting-outputs` succeeds when freezed, Drift, or Riverpod files changed.
4. `flutter gen-l10n` succeeds when `.arb` files changed.
5. Relevant tests pass.
6. Any analyzer warnings or similar issues already present in the files touched by the task must be fixed before completion. Do not leave pre-existing warnings behind in modified code.
7. No `else` keyword in new code.
8. No hardcoded values — all from tokens or l10n.
9. All new widgets use shared components listed above.
10. New files follow the feature folder structure.

## Reference docs

Read relevant sections BEFORE implementing:

- `docs/memox-folder-structure-and-codebase-foundation.md` → tokens, widget specs, responsive
- `docs/memox-codebase-supplement-advanced.md` → SOLID, patterns, l10n, providers
- `docs/memox-migration-isar-to-drift-gdrive-backup.md` → database, backup
- `docs/claude-code-memox-development-prompts.md` → phase-by-phase prompts
