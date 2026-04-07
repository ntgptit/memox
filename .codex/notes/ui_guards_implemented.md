# MemoX UI Guards Implemented

Date: 2026-04-08  
Mode: coordinator-owned guard implementation using the MemoX `ui-heavy` workflow

## What This Pass Added

This pass added a small set of maintainable UI-quality guards tied directly to
the redesign and shared-widget fixes that were already implemented. The goal
was not to invent generic “design quality” heuristics. The goal was to lock in
the exact shared contracts and usage patterns that were already proven
high-value.

The guard changes were limited to:

- `tools/guard/policies/memox/policy.yaml`
- `tools/guard/policies/memox/rules.yaml`

## Guards Added

### 1. Raw low-level widget bans added to `shared_widget`

Added new forbidden patterns to the existing `shared_widget` rule in
`tools/guard/policies/memox/policy.yaml`:

- raw `Switch.adaptive(`
- raw `SearchBar(`
- raw `RawChip(`

#### What this protects against

- bypassing `AppCardSwitchTile` or other shared switch wrappers
- bypassing `AppSearchBar`
- introducing ad hoc chip surfaces instead of using shared chip primitives

#### Why it matters

These are exactly the kinds of low-level Material controls that caused MemoX to
drift back toward default Flutter styling or one-off local behavior.

#### False-positive risk

Low. The existing `shared_widget` rule already excludes `lib/shared/widgets/**`
and `test/**`, so the allowed shared implementations remain untouched.

#### Limitation

This does not ban `SegmentedButton` yet. The repo still has intentional raw
`SegmentedButton` usage in a few approved places, and adding a blanket ban now
would create noise instead of signal.

### 2. `app_theme_surface_contract`

Added a new exact-file `content_contract` for
`lib/core/theme/app_theme.dart`.

#### What it protects against

- collapsing page, card, dialog, sheet, and input surfaces back onto the same
  neutral tier
- drifting away from the current shared surface ladder:
  `surfaceContainerLowest` → `surface` → `surfaceContainerLow` →
  `surfaceContainerHigh`

#### Why it matters

The recent redesign deliberately cleaned up surface layering. This rule keeps
that mapping from regressing through small theme edits.

#### False-positive risk

Low to moderate. It is exact-file and token-based, so it only fires if the
shared theme contract changes materially.

#### Limitation

It intentionally pins the current MemoX surface model. If the team later wants
to change the shared surface ladder, this rule should be updated as part of
that decision.

### 3. `shared_action_button_contract`

Added a new exact-file `content_contract` covering:

- `lib/shared/widgets/buttons/primary_button.dart`
- `lib/shared/widgets/buttons/secondary_button.dart`
- `lib/shared/widgets/buttons/icon_action_button.dart`

#### What it protects against

- shared buttons drifting away from the standardized height/touch-target setup
- loss of `ScaleTap` feedback on primary and secondary buttons
- `SecondaryButton` regressing back to stronger accent defaults instead of the
  calmer neutral-secondary styling

#### Why it matters

These button primitives are used widely. If they regress, multiple screens lose
CTA hierarchy at once.

#### False-positive risk

Low. These are exact-file contracts on stable shared primitives.

#### Limitation

This protects the shared defaults, not every feature-level usage of those
buttons.

### 4. `app_search_bar_contract`

Added a new exact-file `content_contract` for
`lib/shared/widgets/inputs/app_search_bar.dart`.

#### What it protects against

- losing the `page` and `toolbar` variant split
- losing the standardized search height or debounce behavior
- regressing the calmer neutral fill mapping for page and toolbar search

#### Why it matters

`AppSearchBar` was one of the highest-leverage shared-widget fixes. Search and
toolbar layouts depend on that variant contract staying stable.

#### False-positive risk

Low. The rule only checks the shared search-bar file.

#### Limitation

It does not attempt to detect “too many search bars in one screen” or other
screen-level heuristics, because those would be noisy and not robust.

### 5. `app_list_tile_contract`

Added a new exact-file `content_contract` for
`lib/shared/widgets/lists/app_list_tile.dart`.

#### What it protects against

- losing the `standard / sheet / search` variant split
- drifting away from the size tiers introduced for flat rows
- quietly collapsing search rows back into standard list-row proportions

#### Why it matters

`AppListTile` is one of the main shared row primitives. The redesign work on
search, settings sheets, and flat list rows depends on these metrics staying
coherent.

#### False-positive risk

Low to moderate. The contract intentionally pins the shared row grammar, so it
will need an update if MemoX deliberately redesigns those variants later.

#### Limitation

This is a shared-file contract. It does not by itself guarantee every feature
uses the correct variant. That gap is covered by the mapping rules below.

### 6. `shared_overlay_contract`

Added a new exact-file `content_contract` covering:

- `lib/shared/widgets/dialogs/app_dialog.dart`
- `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`

#### What it protects against

- dialogs losing responsive inset padding or max-width behavior
- sheets losing safe-area handling
- bottom-sheet option lists drifting away from `AppListTileVariant.sheet`

#### Why it matters

Overlay spacing and sheet-row semantics were part of the redesign cleanup, and
they are easy to erode with small local edits.

#### False-positive risk

Low. These are exact shared wrappers with stable responsibilities.

#### Limitation

This does not police every feature-local `showModalBottomSheet` body. It only
locks the shared overlay primitives that are meant to be reused.

### 7. `selection_surface_contract`

Added a new exact-file `content_contract` covering:

- `lib/shared/widgets/cards/selectable_card.dart`
- `lib/shared/widgets/chips/mode_chip.dart`
- `lib/shared/widgets/chips/status_chip.dart`

#### What it protects against

- selected cards and chips regressing into loud primary-filled surfaces
- status chips putting semantic color back into both container and label instead
  of keeping the dot semantic and the label neutral

#### Why it matters

The redesign explicitly reduced accent overuse in selection and status widgets.
These are small shared primitives, but they appear in many places.

#### False-positive risk

Low. The contracts are exact-file and tied to intentional shared behavior.

#### Limitation

This protects the shared widgets themselves, not every custom selection pattern
in feature code.

### 8. New `shared_widget_mapping` usage contracts

Added path-specific usage rules in `tools/guard/policies/memox/rules.yaml` for:

- `features/settings/presentation/widgets/settings_*_section.dart`
  - requires `SettingsSectionHeader(` and `SettingsGroupCard(`
- `features/search/presentation/widgets/search_result_tile.dart`
  - requires `AppListTile(` and `variant: AppListTileVariant.search`
  - forbids `AppCard(` and `AppCardListTile(`
- `features/settings/presentation/widgets/backup_list_sheet.dart`
  - requires `AppListTile(` and `variant: AppListTileVariant.sheet`
- `features/folders/presentation/screens/home_screen.dart`
  - requires `TopBarActionRow(` and `TopBarIconButton(`
- `features/folders/presentation/screens/folder_detail_screen.dart`
  - requires `TopBarActionRow(` and `TopBarIconButton(`
- `features/decks/presentation/widgets/deck_detail_header.dart`
  - requires `TopBarActionRow(` and `TopBarIconButton(`

#### What this protects against

- search tiles or sheet rows drifting back to the wrong shared row grammar
- settings section composition regressing away from the current grouped layout
- top-bar actions quietly falling back to ad hoc action-button layouts

#### Why it matters

These are now stable reference patterns. They are easy to guard because they
map to specific files or narrow path patterns, which keeps the noise low.

#### False-positive risk

Low. The rules are narrowly scoped to files that already use these patterns.

#### Limitation

I intentionally did **not** add a wildcard rule like “every `*_tile.dart` must
use `AppListTile` or `AppCardListTile`.” MemoX has legitimate counterexamples,
and that kind of filename-based rule would be noisy.

## What Was Intentionally Not Added

Some proposed guards are not realistically enforceable yet, or they would fail
on approved current code. I left them out on purpose.

### Not added: blanket `SegmentedButton` ban

There are still intentional raw `SegmentedButton` uses in MemoX, and there is
not yet one shared replacement that covers those contexts cleanly. Adding a
repo-wide ban now would create churn and exception lists, not quality.

### Not added: generic spacing-rhythm heuristics

Rules like “too many spacing values in one screen” or “screen padding feels
weak” are not robust in the current guard framework. They would be easy to game
and hard to maintain.

### Not added: blanket nested-card or CTA-count heuristics

Those are visually appealing ideas in theory, but they are not realistically
enforceable with low false-positive rates in MemoX today.

### Not added: fail-now guards for still-unfixed UI drift

I did **not** add guards for `folder_deck_tile.dart` or the remaining
feature-local raw `IconButton` cases that would immediately fail current code.
Those should be added only after the corresponding UI cleanup lands.

## Summary of Coverage

After this pass, MemoX now has stronger automated protection for:

- hardcoded low-level Material widget regressions where a shared wrapper exists
- shared surface-layer regressions in the app theme
- shared button sizing and hierarchy regressions
- shared search-bar, list-tile, dialog, and sheet behavior drift
- shared selection/status color regressions
- feature-level misuse of the stabilized row, section-grouping, and top-bar
  patterns

The areas that remain intentionally manual or deferred are:

- high-level visual polish heuristics
- broad screen-level density heuristics
- generic segmented-control policy
- unresolved legacy feature widgets that still need redesign before they can be
  safely guarded

## Verification

### Guard gate

- `python tools/guard/run.py --scope all`
- Result: passed with `0` errors
- Residual warnings: `14` pre-existing `feature_completeness` warnings for the
  empty feature `data/tables` and `data/daos` directories

### Analyzer

- `flutter analyze`
- Result: passed with no issues

### Guard framework tests

- `python -m pytest tools/guard/tests/core/test_rule_executor.py tools/guard/tests/local_guards/test_shared_widget_mapping_guard.py`
- Result: `52` tests passed

### Not run

- `flutter test`

Reason: this pass only changed guard policy YAML and the summary note. No Dart
runtime behavior or widget implementation changed, so the targeted guard
framework verification was the stronger relevant test.

## Follow-up Guards Added

Date: 2026-04-08

This follow-up added two more narrow protections after the subsequent
representative-screen cleanup landed.

### 9. `balanced_top_bar_slot`

Files:

- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)

What it protects against:

- spreading `TopBarIconButton.balancedSlotWidth` or
  `TopBarBackButton.balancedSlotWidth` into new headers that do not actually
  need centered-title geometry

Why it matters:

- the audits repeatedly called out expensive compact-width header slots as a
  proportion risk
- the current repo has a small set of intentional uses, so this is a
  high-signal allowlist guard

How it is implemented:

- normalized `forbidden_pattern` rule
- excludes the current allowlisted files:
  - study top bar
  - shared back button
  - editor top bar
  - deck detail header/screen
  - folder detail screen

False-positive risk:

- low, as long as future legitimate uses are explicitly allowlisted instead of
  appearing silently

### 10. `folder_deck_tile` shared-widget mapping

Files:

- [rules.yaml](/D:/workspace/memox/tools/guard/policies/memox/rules.yaml)

What it protects against:

- folder-detail deck rows regressing back to a raw `AppCard` composition
  instead of the shared deck/folder card-row grammar

Why it matters:

- the shared-widget audit explicitly called out `FolderDeckTile` as a remaining
  feature-side bypass that weakened library consistency

How it is implemented:

- path-specific `shared_widget_mapping` rule
- requires:
  - `AppCardListTile(`
  - `AppTileGlyph(`
- forbids:
  - `AppCard(`

False-positive risk:

- low; the rule targets one exact file with one intentional shared pattern

### Verification for this follow-up

- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed

## Follow-up Guards Added 3

Date: 2026-04-08

This continuation added one narrow guard after the shared press-feedback fix
landed in the theme.

### 12. `inkwell_highlight_override`

Files:

- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)

What it protects against:

- direct `highlightColor:` overrides reappearing in shared widgets or theme
  files and reintroducing rectangular press artifacts inside rounded containers

Why it matters:

- the rounded press-feedback fix now depends on `ThemeData.highlightColor`
  staying transparent while splash/overlay layers carry the visible feedback
- this is a low-noise pattern because the current codebase has one intentional
  owner for `highlightColor`, and it is the shared theme file

How it is implemented:

- normalized `forbidden_pattern` rule
- scans `lib/shared/widgets/**` and `lib/core/theme/**`
- excludes [app_theme.dart](/D:/workspace/memox/lib/core/theme/app_theme.dart)
  and tests
- emits a warning when `highlightColor:` appears outside the allowlisted theme
  owner

False-positive risk:

- low, because raw `InkWell` usage is already tightly constrained and the
  allowed `highlightColor` owner is explicit

### Verification for this follow-up

- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed

## Follow-up Guards Added 2

Date: 2026-04-08

This continuation pass added one more narrow protection after the shared
bottom-sheet cleanup landed.

### 11. `feature_bottom_sheet_entrypoint`

Files:

- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)

What it protects against:

- raw `showModalBottomSheet(...)` reappearing inside feature presentation code
  after the shared bottom-sheet helper path was restored

Why it matters:

- the guard-candidate notes explicitly called out feature-local bottom-sheet
  entry points as a fragmentation risk once the sheet family was cleaned up
- the repo now routes current feature sheet helpers through
  `context.showAppBottomSheet(...)`, so this became a low-noise rule

How it is implemented:

- normalized `forbidden_pattern` rule scoped to
  `lib/features/*/presentation/**/*.dart`
- flags any direct `showModalBottomSheet(...)` call and points authors back to
  `context.showAppBottomSheet(...)` or a shared sheet helper

False-positive risk:

- low, because the current feature presentation paths are already migrated and
  shared-layer wrappers remain excluded from the rule

Additional shared-overlay contract update:

- `shared_overlay_contract` for
  [choice_bottom_sheet.dart](/D:/workspace/memox/lib/shared/widgets/dialogs/choice_bottom_sheet.dart)
  was updated to require `context.showAppBottomSheet<T>(` instead of the old
  raw modal entry point token

### Verification for this follow-up

- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed
