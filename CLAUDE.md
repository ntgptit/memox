# MemoX — Personal Flashcard Learning App

## Project

Flutter 3.24+ / Dart 3.5+ flashcard app with 5 study modes (review, match, guess, recall, fill), SRS spaced repetition, Google Drive backup.

## Architecture

Feature-first Clean Architecture. Dependency flow: presentation -> domain <- data. Never import data layer from presentation.

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

- State + DI: Riverpod (`@riverpod` annotation, code-generated). No get_it, no injectable.
- Database: Drift (SQLite). Tables in `core/database/tables/`, DAOs in `core/database/daos/`. Reactive via `.watch()`. Test with `NativeDatabase.memory()`. Foreign keys enforced, cascade deletes in repository.
- Auth/Backup: `google_sign_in` + `googleapis` (Drive appDataFolder). No Firebase.
- Navigation: GoRouter with StatefulShellRoute (4 tabs).
- UI: Material 3, Google Fonts "Plus Jakarta Sans", `flutter_animate`.
- Models: freezed + json_serializable. Enums stored as intEnum in Drift tables.

## Build & verify

```bash
python tools/guard/run.py --scope <scope>   # mandatory before completion
flutter analyze                              # fix error, warning, AND info
flutter test
dart run build_runner build --delete-conflicting-outputs  # after freezed/Drift/Riverpod edits
flutter gen-l10n                                          # after .arb edits
```

Completion order: build_runner -> gen-l10n -> guard -> analyze -> test.

## Guard gate

Run the smallest scope covering changed area:

- `lib/core/**` -> `--scope core`
- `lib/shared/**` -> `--scope shared`
- `lib/features/**` -> `--scope features`
- `test/**` only -> `--scope test`
- multiple areas or unsure -> `--scope all`

Guard is mandatory for any Dart source, test, guard rule, or architecture change. Do not skip.

## Coding rules

- NO `else`. Use early return, guard clause, switch expression, or value reassign.
- NO hardcoded colors, sizes, spacing, radius, duration, strings. Use design tokens and l10n:
  - Colors: `context.colors.*`, `context.customColors.*`
  - Text: `context.textTheme.*`, `context.appTextStyles.*`
  - Spacing: `SpacingTokens.*`, `Gap.*` | Sizes: `SizeTokens.*` | Radius: `RadiusTokens.*` | Duration: `DurationTokens.*`
  - Strings: `context.l10n.*`
- Max 80 lines per widget file. Split into small composable widgets.
- `const` constructors everywhere possible.
- Dart 3.5 records, patterns, sealed classes.
- `Result<T>` sealed class for use case returns. No raw try-catch in domain.

## Validation checklist

1. Guard passes for affected area.
2. `flutter analyze` clean (error + warning + info) on all touched files.
3. `build_runner` succeeds when codegen files changed.
4. `flutter gen-l10n` succeeds when `.arb` files changed.
5. Relevant tests pass.
6. Fix pre-existing lint debt in touched files.
7. No `else`, no hardcoded values, shared widgets used, feature folder structure followed.

## Reference docs (read only the relevant section for the current task)

- `docs/memox-guard-rules-quickref.md` — **read first for any code task**: forbidden patterns, required tokens, widget mapping, color palette, thresholds
- `docs/memox-ui-design-rules.md` — UI design language, tappable patterns, shared wrappers
- `docs/memox-typography-usage-rules.md` — constrained type scale (48/32/24/20/16/14/12)
- `docs/memox-shared-widgets.md` — required shared widgets (do NOT recreate)
- `docs/memox-reference.md` — architecture deep-dive, tokens, database, backup, DI, patterns
- `docs/memox-guard-spec.md` — guard tool internals (read only when modifying guard tool itself)
- `docs/claude-code-memox-development-prompts.md` — bugs, missing features, test gaps
