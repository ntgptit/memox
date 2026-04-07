# MemoX Shared Widget Fix Summary

Date: 2026-04-08  
Mode: coordinator-owned shared-widget redesign using the MemoX `ui-heavy` workflow

## What This Pass Fixed

This pass stayed inside the shared layer and a small set of direct consumers. The goal was not to create more flexibility. The goal was to make the existing shared widgets stricter, more context-aware, and safer to use correctly.

The main shared-widget problems addressed were:

- `AppListTile` was too generic for search rows, sheet rows, and standard flat rows
- `AppDialog` had weak default spacing structure for form dialogs versus standard confirm dialogs
- `AppSearchBar` relied on one implicit default context even though page search and toolbar search need different surface treatment
- `ChoiceBottomSheet` still used weak title hierarchy and generic flat rows
- feature screens could still drift back to raw dialog shells or implicit search-bar context without guard protection

I did **not** rewrite larger shared surfaces such as `AppCardListTile`, settings rows, or top-bar geometry in this pass. Those need a separate redesign pass because their blast radius is wider.

## Shared Widgets Fixed

### `AppListTile`

Files:

- `lib/shared/widgets/lists/app_list_tile.dart`
- `lib/features/search/presentation/widgets/search_result_tile.dart`
- `lib/features/settings/presentation/widgets/backup_list_sheet.dart`
- `lib/features/decks/presentation/widgets/study_mode_sheet.dart`
- `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`

Why it needed work:

- one flat tile grammar was being stretched across search results, bottom-sheet pickers, and normal list rows
- the default leading slot, row height, divider indent, and title treatment were too heavy for search and too generic for sheet pickers

Change type:

- variant addition
- default behavior improvement
- layout simplification

What was implemented:

- added `AppListTileVariant.standard`, `sheet`, and `search`
- moved sizing decisions into one shared metrics resolver instead of leaving each use case to local layout hacks
- made search rows denser with a smaller leading slot, tighter vertical padding, and a lighter `titleSmall` title style
- kept sheet rows flatter than card rows while preserving readable subtitle spacing
- aligned divider indent to the actual leading slot instead of a generic fixed indent token
- updated bottom-sheet and search consumers to use explicit variants

Why this improves downstream screens automatically:

- search results no longer inherit the same row weight as picker and menu rows
- study mode and backup sheets now read as intentional selection sheets instead of generic list stacks
- any future flat-list consumer can opt into one of the limited row contexts instead of rebuilding spacing locally

### `AppDialog`

Files:

- `lib/shared/widgets/dialogs/app_dialog.dart`
- `lib/shared/widgets/dialogs/input_dialog.dart`
- `lib/features/decks/presentation/widgets/create_deck_dialog.dart`
- `lib/features/folders/presentation/widgets/create_folder_dialog.dart`
- `lib/features/folders/presentation/widgets/delete_folder_confirm_dialog.dart`

Why it needed work:

- form dialogs and confirm dialogs were using the same shell behavior even though they need different content-to-action rhythm
- the dialog shell was too loose structurally and left wrappers to fake the right spacing

Change type:

- variant addition
- default behavior improvement
- layout simplification

What was implemented:

- added `AppDialogVariant.standard` and `form`
- standardized dialog title/content/actions padding in the shared shell
- kept confirm dialogs on the tighter standard action spacing
- gave form dialogs explicit extra separation before actions and zeroed the content bottom padding so field groups and buttons do not feel double-padded
- kept dialog width logic centralized and decomposed the layout helpers so the shell stays short and auditable

Why this improves downstream screens automatically:

- create deck and create folder flows now inherit better form rhythm without screen-level spacing hacks
- input dialogs and confirm dialogs now diverge through an explicit shell contract instead of accidental local differences

### `AppSearchBar`

Files:

- `lib/shared/widgets/inputs/app_search_bar.dart`
- `lib/features/search/presentation/screens/search_screen.dart`
- `lib/features/decks/presentation/widgets/deck_cards_toolbar.dart`
- `test/shared/widgets/compact_reference_widgets_test.dart`

Why it needed work:

- the widget had one implicit default context even though page search and pinned toolbar search need different surface treatment
- leaving the context implicit encouraged weak, inconsistent search styling

Change type:

- variant addition
- API tightening
- default behavior improvement

What was implemented:

- added `AppSearchBarVariant.page` and `toolbar`
- made `variant` required so callers must choose the intended context explicitly
- mapped page search to the calmer neutral surface token and toolbar search to the stronger toolbar container tier
- gave the toolbar variant explicit content padding so the pinned deck toolbar looks more deliberate

Why this improves downstream screens automatically:

- search screen and deck detail toolbar stop sharing the same ambiguous search treatment
- future search entrypoints now need to declare their visual context instead of inheriting the wrong default

### `ChoiceBottomSheet`

Files:

- `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`

Why it needed work:

- the sheet header was using the same weak title tier as option rows
- option rows were still falling back to the generic tile behavior

Change type:

- default behavior improvement

What was implemented:

- promoted the sheet title to `titleLarge`
- moved option rows onto `AppListTileVariant.sheet`

Why this improves downstream screens automatically:

- selection sheets now have a real header tier and clearer picker-row rhythm without changing any feature-specific flow logic

## Guard Additions

Files:

- `tools/guard/policies/memox/rules.yaml`

What was added:

- `feature_dialogs`
  - requires feature dialog widgets under `lib/features/*/presentation/widgets/*dialog*.dart` to use `AppDialog(`, `ConfirmDialog(`, or `InputDialog(`
  - forbids raw `AlertDialog(`
- `search_screen_entry`
  - requires `SearchScreen` to use `AppSearchBar(` with `variant: AppSearchBarVariant.page`
- `deck_toolbar_search`
  - requires `DeckCardsToolbar` to use `AppSearchBar(` with `variant: AppSearchBarVariant.toolbar`

Why these guards are useful:

- they protect the exact shared-widget contracts tightened in this pass
- they are narrow enough to stay low-noise
- they prevent future drift back to raw dialog shells or implicit search-bar styling

## Files Modified In This Pass

Shared widgets and direct consumers:

- `lib/shared/widgets/lists/app_list_tile.dart`
- `lib/shared/widgets/dialogs/app_dialog.dart`
- `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`
- `lib/shared/widgets/dialogs/input_dialog.dart`
- `lib/shared/widgets/inputs/app_search_bar.dart`
- `lib/features/search/presentation/screens/search_screen.dart`
- `lib/features/search/presentation/widgets/search_result_tile.dart`
- `lib/features/settings/presentation/widgets/backup_list_sheet.dart`
- `lib/features/decks/presentation/widgets/study_mode_sheet.dart`
- `lib/features/decks/presentation/widgets/deck_cards_toolbar.dart`
- `lib/features/decks/presentation/widgets/create_deck_dialog.dart`
- `lib/features/folders/presentation/widgets/create_folder_dialog.dart`
- `lib/features/folders/presentation/widgets/delete_folder_confirm_dialog.dart`
- `tools/guard/policies/memox/rules.yaml`

Verification coverage:

- `test/shared/widgets/lists/app_list_tile_test.dart`
- `test/shared/widgets/dialogs/app_dialog_test.dart`
- `test/shared/widgets/inputs/app_search_bar_test.dart`
- `test/shared/widgets/compact_reference_widgets_test.dart`

## Expected Visual Impact

The visible improvements from this pass should be:

- flatter, calmer sheet rows where the old generic list-tile spacing felt clumsy
- denser and cleaner search-result rows
- stronger bottom-sheet title hierarchy
- better form-dialog rhythm in create flows
- clearer distinction between page search and toolbar search
- fewer local spacing decisions in feature widgets because the shared layer now owns more of the context

The biggest automatic improvements should show up in:

- `SearchScreen`
- `DeckCardsToolbar`
- `StudyModeSheet`
- `BackupListSheet`
- `CreateDeckDialog`
- `CreateFolderDialog`
- `InputDialog`
- `ChoiceBottomSheet`

## Business and Regression Risk

Business behavior was not changed. This pass only changed shared visual contracts and the feature consumers needed to adopt them.

Main regression risks were:

- search-bar sizing or fill-color changes affecting pinned toolbar layout
- dialog padding changes affecting compact form flows
- tile density changes affecting search and sheet readability

Those risks were contained by keeping the API changes small, updating direct consumers in the same pass, and adding widget-level tests plus narrow guard rules.

## Verification

### Guard

- `python tools/guard/run.py --scope all`
- Result: passed with `0` errors
- Residual warnings: `14` pre-existing `feature_completeness` warnings for empty `data/tables` and `data/daos` folders across features

### Analyzer

- `flutter analyze`
- Result: passed with no issues

### Targeted tests

Ran:

- `flutter test test/shared/widgets/lists/app_list_tile_test.dart test/shared/widgets/dialogs/app_dialog_test.dart test/shared/widgets/inputs/app_search_bar_test.dart test/shared/widgets/compact_reference_widgets_test.dart test/features/search/presentation/screens/search_screen_test.dart test/features/folders/presentation/widgets/create_folder_dialog_test.dart`

Result:

- all targeted tests passed

## Deliberately Deferred

I did **not** try to solve these in the same pass:

- `AppCardListTile` role separation for card-surface entity rows
- settings-row density cleanup
- richer `ChoiceBottomSheet` option modeling
- top-bar geometry normalization

Those are valid redesign targets, but they need their own bounded pass to avoid turning this shared-widget cleanup into a broad screen rewrite.

## Follow-up Batch: Shared Widget Usage Cleanup

Date: 2026-04-08

This follow-up batch did not redesign another shared API. It removed one of the
remaining feature-side shared-widget bypasses that the audit still called out.

### `FolderDeckTile`

Files:

- [folder_deck_tile.dart](/D:/workspace/memox/lib/features/folders/presentation/widgets/folder_deck_tile.dart)
- [folder_deck_tile_test.dart](/D:/workspace/memox/test/features/folders/presentation/widgets/folder_deck_tile_test.dart)

Why it needed work:

- folder-detail deck rows were still bypassing the shared deck-row/card-row
  grammar by building a raw `AppCard` + `Row` composition directly
- that kept folder detail visually inconsistent with the rest of the library
  even after the earlier shared row cleanups

Change type:

- shared widget usage fix
- layout simplification

What was implemented:

- replaced the raw `AppCard` row in `FolderDeckTile` with `AppCardListTile`
- moved the leading icon onto `AppTileGlyph`
- aligned subtitle styling with the shared deck/folder row treatment
- kept highlight state on the shared card border instead of the feature-local
  accent stripe path

Why this improves downstream screens automatically:

- folder detail now consumes the same shared row grammar as the rest of the
  library instead of maintaining a parallel deck-card pattern
- future spacing or hierarchy adjustments in the shared card-row family now
  apply more consistently across deck browsing surfaces

### `DeckTileSupporting`

Files:

- [deck_tile_supporting.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile_supporting.dart)

Why it needed work:

- deck description text was still sitting on the base reading tier, which kept
  title and supporting description too close in emphasis

Change type:

- default behavior improvement

What was implemented:

- stepped deck description copy down from `bodyMedium` to `bodySmall`

Why this improves downstream screens automatically:

- deck tiles keep a clearer title/supporting-text hierarchy without changing
  the card structure or metadata flow

### Verification for this follow-up

- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed

## Follow-up Batch: Toolbar Search Contrast

Date: 2026-04-08

This follow-up kept the scope narrow. It did not introduce a new search widget.
It tightened the existing toolbar-search contract so pinned toolbars read more
clearly in dark mode.

### `AppSearchBar`

Files:

- [app_search_bar.dart](/D:/workspace/memox/lib/shared/widgets/inputs/app_search_bar.dart)
- [app_search_bar_test.dart](/D:/workspace/memox/test/shared/widgets/inputs/app_search_bar_test.dart)

Why it needed work:

- the toolbar variant already used a stronger fill tier than the page variant,
  but it still depended entirely on the global input theme for border presence
- on darker neutral toolbar surfaces that left the search field too easy to
  lose visually

Change type:

- default behavior improvement
- API tightening of the toolbar variant contract

What was implemented:

- kept `AppSearchBarVariant.toolbar` on `surfaceContainerHighest`
- added an explicit toolbar-only enabled border and focused border so the field
  keeps a visible container edge even when the surrounding toolbar surface is
  also neutral

Why this improves downstream screens automatically:

- pinned toolbar search fields no longer depend on implicit theme behavior for
  their outline contrast
- deck detail and any future toolbar-search consumer inherit a clearer search
  container without local overrides

### Verification for this follow-up

- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test test/shared/widgets/inputs/app_search_bar_test.dart test/features/decks/presentation/widgets/deck_cards_toolbar_test.dart`
  passed

## Follow-up Batch: Settings Shared Surface and Control Cleanup

Date: 2026-04-08

This follow-up stayed in the existing settings/shared-control system and fixed
the shared defaults that were making the Settings screen feel flat, heavy, and
under-interactive.

### `SettingsGroupCard`

Files:

- [settings_group_card.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_group_card.dart)
- [settings_section_grouping_test.dart](/D:/workspace/memox/test/features/settings/presentation/widgets/settings_section_grouping_test.dart)

Why it needed work:

- grouped settings cards still relied on the generic `AppCard` default surface,
  which disappeared into the dark-mode page background
- section grouping was structurally correct but visually weak because the
  shared wrapper was too neutral for the settings context

Change type:

- default behavior improvement

What was implemented:

- moved `SettingsGroupCard` onto `surfaceContainerLow`
- promoted its outline to an `onSurface` border at focus opacity for clearer
  dark-mode separation
- extended the settings grouping test to lock the new surface and outline
  contract

Why this improves downstream screens automatically:

- every settings section that already uses `SettingsGroupCard` now gets clearer
  surface separation without local overrides

### `IconActionButton`

Files:

- [icon_action_button.dart](/D:/workspace/memox/lib/shared/widgets/buttons/icon_action_button.dart)
- [icon_action_button_test.dart](/D:/workspace/memox/test/shared/widgets/buttons/icon_action_button_test.dart)

Why it needed work:

- the shared icon-action primitive was too faint for compact control clusters,
  especially the `+/-` settings steppers
- the settings problem was not a missing widget, but a weak shared default for
  neutral outlined icon actions

Change type:

- default behavior improvement

What was implemented:

- kept the existing shared `IconButton.outlined` contract but restored a clearer
  neutral surface, foreground, and outline treatment
- preserved the MemoX shared-button contract tokens while locking the new
  surface behavior in a focused widget test

Why this improves downstream screens automatically:

- settings steppers and any future compact icon-action clusters now read as
  clearly interactive without inventing a second local button style

### Verification for this follow-up

- `dart run build_runner build --delete-conflicting-outputs` passed
- `flutter gen-l10n` passed
- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed

## Follow-up Batch: Shared Overlay Consistency

Date: 2026-04-08

This follow-up batch stayed inside the existing sheet family and normalized the
last direct feature bottom-sheet entry points while making the generic choice
sheet safer for long option lists.

### `ChoiceBottomSheet`

Files:

- [choice_bottom_sheet.dart](/D:/workspace/memox/lib/shared/widgets/dialogs/choice_bottom_sheet.dart)
- [choice_bottom_sheet_test.dart](/D:/workspace/memox/test/shared/widgets/dialogs/choice_bottom_sheet_test.dart)

Why it needed work:

- the generic choice sheet still expanded every option directly into one
  `Column`
- its helper still owned a raw `showModalBottomSheet(...)` entry point even
  though MemoX already has a shared bottom-sheet wrapper

Change type:

- default behavior improvement
- layout simplification

What was implemented:

- moved option rendering into a constrained `ListView.separated` so long choice
  lists stay scrollable
- changed `showChoiceBottomSheet(...)` to route through
  `context.showAppBottomSheet(...)`

Why this improves downstream screens automatically:

- long selection sheets no longer risk vertical overflow
- bottom-sheet behavior is more centralized and consistent across feature and
  shared entry points

### Feature sheet helpers

Files:

- [study_mode_sheet.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/study_mode_sheet.dart)
- [backup_list_sheet.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/backup_list_sheet.dart)

Why they needed work:

- both helpers still bypassed the shared bottom-sheet wrapper with direct
  `showModalBottomSheet(...)` usage

Change type:

- layout simplification

What was implemented:

- switched both helpers to `context.showAppBottomSheet(...)`

Why this improves downstream screens automatically:

- feature sheets now consume the same shared safe-area and
  scroll-controlled entry behavior as the generic sheet family

### Verification for this follow-up

- `python tools/guard/run.py --scope all` passed with only the existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed
