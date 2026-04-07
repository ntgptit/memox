# UI Fix Reference Screens Summary

## Scope

This pass implemented the first screen-level redesign fixes for the reference
screens called out in the MemoX UI audit and roadmap:

1. `DeckDetailScreen`
2. `SettingsScreen`
3. `ReviewModeScreen`
4. `SearchScreen`

The goal was not to restyle the whole app. The goal was to turn a small set of
high-visibility screens into stronger references by fixing rhythm, hierarchy,
grouping, density, CTA structure, and shared-widget usage without changing
business behavior.

## Target Screens And What Was Fixed

### 1. Deck Detail

**Main issues fixed**

- The first viewport spent too much space on repeated chrome before card
  content.
- The stats grid and CTA stack competed with each other instead of forming a
  clear primary action.
- The cards area had a duplicated heading plus a heavy segmented control that
  made the toolbar feel noisy and outdated.
- The header spacing was too loose and the summary text was too heavy for its
  role.

**Implemented**

- Removed the separate cards heading from
  [deck_detail_screen.dart](/D:/workspace/memox/lib/features/decks/presentation/screens/deck_detail_screen.dart)
  so the pinned toolbar now owns the cards context.
- Reordered
  [deck_detail_overview.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_detail_overview.dart)
  so action cards lead the section and stats support them instead of competing
  with them.
- Replaced the raw segmented sort control in
  [deck_cards_toolbar.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar.dart)
  with a calmer shared pattern: section title + compact sort button +
  `AppSearchBarVariant.toolbar` + `showChoiceBottomSheet`.
- Tightened header gaps and softened summary emphasis in
  [deck_detail_header.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_detail_header.dart).
- Rebuilt
  [deck_stats_grid.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_stats_grid.dart)
  around shared `StatCard` usage, quieter spacing, and a single emphasized due
  metric.
- Increased compact stat tile height to eliminate overflow in the redesigned
  shared-card layout.

**Before / after structural improvement**

- Before: header, overview, stats, heading, segmented control, then cards.
- After: header, action-led overview, quieter supporting stats, then a simpler
  pinned cards toolbar.

### 2. Settings

**Main issues fixed**

- Section spacing was too loose and repetitive.
- Section headers felt bureaucratic and weak because they relied on uppercase
  micro labels.
- Settings rows were visually bloated because row padding stacked on top of a
  minimum touch target.
- Backup and data sections mixed informational, operational, and destructive
  actions too closely.
- Appearance and notification controls used grouping patterns that hurt scan
  flow.

**Implemented**

- Tightened inter-section spacing in
  [settings_content_view.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_content_view.dart)
  from repeated section-gap usage to a calmer `xl` rhythm.
- Promoted
  [settings_section_header.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_section_header.dart)
  from uppercase micro-label styling to a proper section-heading role.
- Reduced row bloat in
  [settings_action_row.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_action_row.dart),
  [settings_choice_row.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_choice_row.dart),
  and
  [settings_stepper_row.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_stepper_row.dart)
  by removing redundant vertical padding and normalizing row height.
- Added vertical breathing room inside
  [settings_group_card.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_group_card.dart)
  so compact rows do not visually stick to card edges.
- Reworked
  [settings_notifications_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_notifications_section.dart)
  so reminder time is a value-choice row instead of an overloaded action row.
- Split
  [settings_appearance_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_appearance_section.dart)
  into clearer theme/language and color groups, and changed the theme mode
  chooser to a `Wrap`-based layout that behaves better on compact widths.
- Rebuilt
  [settings_backup_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_backup_section.dart)
  to separate account context, backup actions, and sign-out.
- Rebuilt
  [settings_data_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_data_section.dart)
  so import/export actions are isolated from the destructive history reset.

**Before / after structural improvement**

- Before: many similarly weighted boxed rows with weak grouping boundaries.
- After: stronger section headings, denser but cleaner rows, clearer group
  separation, and better destructive-action isolation.

### 3. Review Mode

**Main issues fixed**

- The round layout used a looser local padding pattern than the app shell.
- The bottom interaction area had weak structure before reveal and visually
  noisy structure after reveal.
- Completion recap text still felt too strong relative to the final CTA.

**Implemented**

- Normalized review-round padding in
  [review_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_round_view.dart)
  to use shell-aware horizontal padding instead of a blanket local `24dp`.
- Replaced the plain pre-reveal hint with an `AppCard` containing subdued helper
  text and an explicit full-width reveal CTA.
- Wrapped the post-reveal rating grid in `AppCard` so both pre- and post-reveal
  states share a calmer surfaced tray.
- Softened the completion extra-content styling in
  [review_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/review_mode_screen.dart)
  so the result recap no longer competes with the primary action.

**Before / after structural improvement**

- Before: reveal state transition felt abrupt and bottom controls floated with
  inconsistent emphasis.
- After: the bottom tray is structurally stable, the reveal step is explicit,
  and the completion recap is quieter.

### 4. Search

**Main issues fixed**

- Search used a looser local gutter than the rest of compact screens.
- The page treated all results as one flat list, which made scanning tiring.
- Result rows lacked directionality and felt disconnected from destination
  context.

**Implemented**

- Restored scaffold-controlled horizontal padding in
  [search_screen.dart](/D:/workspace/memox/lib/features/search/presentation/screens/search_screen.dart)
  and reduced the search-bar wrapper to a lighter top/bottom rhythm.
- Explicitly used `AppSearchBarVariant.page` on the screen-level search entry.
- Reworked
  [search_result_list.dart](/D:/workspace/memox/lib/features/search/presentation/widgets/search_result_list.dart)
  into grouped sections for folders, decks, and cards.
- Updated
  [search_result_tile.dart](/D:/workspace/memox/lib/features/search/presentation/widgets/search_result_tile.dart)
  to use the denser `AppListTileVariant.search` pattern and a trailing chevron
  for clearer navigation intent.

**Before / after structural improvement**

- Before: oversized page gutters and a flat result dump.
- After: normalized page padding and a grouped result flow with clearer scan
  structure.

## Shared / Reusable Patterns Proven By This Pass

These patterns should be propagated next to similar screens instead of adding
local one-off fixes:

1. Action-first overview blocks before secondary stats.
2. Pinned content toolbars that own section context instead of stacking a
   heading plus a separate filter/search control.
3. Settings rows that use shared minimum touch targets without extra vertical
   padding inflation.
4. Settings sections that isolate account context and destructive actions into
   separate groups.
5. Review-mode bottom trays that keep both states inside the same surfaced
   container pattern.
6. Search result lists grouped by destination type instead of one undifferentiated
   list.
7. Screen-level search bars that declare the correct shared `AppSearchBar`
   variant instead of relying on ad hoc defaults.

## Lightweight Guard / Protection Added

- Strengthened
  [rules.yaml](/D:/workspace/memox/tools/guard/policies/memox/rules.yaml)
  so the deck cards toolbar must keep the shared toolbar search + bottom-sheet
  sort pattern and must not regress back to a raw
  `SegmentedButton<DeckCardSort>`.

## Verification

The implementation was verified after the screen changes with:

1. `flutter analyze`
2. `flutter test`
3. `python tools/guard/run.py --scope all`

Results:

- `flutter analyze`: passed with no issues.
- `flutter test`: passed.
- `python tools/guard/run.py --scope all`: passed with only the existing
  `feature_completeness` warnings for intentionally empty feature `data/tables`
  and `data/daos` directories.

Additional test updates were made where the redesigned UI changed shared
behavior expectations:

- deck detail loading now asserts skeleton loading instead of the old spinner
  contract
- folder detail loading test now matches skeleton loading
- search result grouping test now checks section structure instead of brittle
  duplicate text occurrences
- shared smoke coverage was aligned with the current shared link/button
  composition

## Regression Risk

Risk is moderate but controlled:

- `DeckDetailScreen` changed structure in the first viewport, but navigation,
  paging, search, sorting, and card actions were preserved.
- `SettingsScreen` changed grouping and row density only; it did not change
  state flow or setting updates.
- `ReviewModeScreen` changed reveal/rating layout only; it did not change SRS
  rating behavior.
- `SearchScreen` changed grouping and density only; it did not change query or
  navigation behavior.

No business logic, routing intent, provider state flow, or API behavior was
intentionally changed in this pass.

## Follow-up Reference Screen Batch

Date: 2026-04-08

This follow-up batch closed two representative-screen issues that were still
open after the earlier reference-screen pass: home rhythm and folder-detail
deck row consistency.

### 5. Home

**Main issues fixed**

- the transition from the greeting card into the main folder section still used
  a full `sectionGap`, which overstated a weak hierarchy change
- the `MY FOLDERS` handoff still left too much vertical air under a small
  section label

**Implemented**

- reduced the greeting-to-folder transition gap in
  [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
  from `SpacingTokens.sectionGap` to `SpacingTokens.xl`
- simplified the folder section header block and tightened the label-to-content
  handoff from `md` to `sm`

**Before / after structural improvement**

- before: a lightweight greeting card dropped into a chapter-sized break before
  a very small label
- after: the handoff is tighter and better matched to the actual visual weight
  of the section header

### 6. Folder Detail deck browsing rows

**Main issues fixed**

- folder detail still used a separate raw `AppCard` deck-row grammar while the
  rest of the library had already moved to shared card-row primitives
- this kept deck browsing inconsistent across folder detail versus deck lists

**Implemented**

- rebuilt
  [folder_deck_tile.dart](/D:/workspace/memox/lib/features/folders/presentation/widgets/folder_deck_tile.dart)
  on `AppCardListTile` + `AppTileGlyph` + shared subtitle styling
- kept the mastery ring trailing affordance while removing the feature-local
  raw row shell
- stepped deck supporting description hierarchy in
  [deck_tile_supporting.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile_supporting.dart)
  down to the supporting text tier so shared deck rows read with better
  hierarchy

**Before / after structural improvement**

- before: folder detail maintained its own simple deck-row pattern that looked
  related to, but not governed by, the shared deck/folder browsing system
- after: folder detail consumes the same card-row grammar as the wider library,
  so the deck entity reads more consistently across screens

## Additional reusable patterns proven by the follow-up

8. Lightweight hero-to-section transitions should not spend `sectionGap`
   unless the next block truly changes narrative weight.
9. Feature-local entity rows should consume existing shared row primitives
   instead of rebuilding raw `AppCard` shells for the same content type.

## Follow-up Reference Screen Batch 2

Date: 2026-04-08

This continuation pass tightened one remaining weak hierarchy on home and one
remaining generic composition problem in statistics.

### 7. Home header hierarchy

**Main issues fixed**

- the folder section title was still rendered as an uppercase micro label even
  after the oversized gap above it had been reduced
- reorder mode still reopened extra vertical air under a now-lighter header

**Implemented**

- promoted the folder section title in
  [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
  from the shared `sectionLabel` treatment to `headlineMedium`
- removed the uppercase transformation so the handoff reads like a real section
  heading instead of metadata
- tightened the reorder-banner follow-up gap from `md` to `sm`

**Before / after structural improvement**

- before: the home screen still handed off into the main library with a weak,
  metadata-like label
- after: the section heading now carries enough weight to justify the
  transition rhythm and improve scan flow into the folder list

### 8. Statistics difficult-cards section

**Main issues fixed**

- the section still nested `AppCard` + `ExpandableTile` + `AppListTile` for
  each difficult card, which made the expanded content feel generic and bulky
- low-accuracy values were still color-loud inside a screen that had already
  been calmed elsewhere

**Implemented**

- rebuilt row content in
  [difficult_cards_section.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/difficult_cards_section.dart)
  with a focused local `_DifficultCardRow` instead of generic `AppListTile`
  nesting
- kept the row title/supporting-text structure but moved accuracy to a neutral
  label tier instead of warning-colored emphasis
- added a light divider treatment so expanded rows stay readable without
  feeling like another menu stack

**Before / after structural improvement**

- before: the section expanded into a stack of generic menu-like rows with
  louder-than-needed accuracy values
- after: the content reads as a focused statistics drill-down with calmer row
  density and clearer grouping

## Additional reusable patterns proven by follow-up batch 2

10. Home/list handoffs should use a true section heading once the transition is
    visually important, not an all-caps metadata label.
11. Analytics drill-down rows should not default to the generic flat
    list-tile primitive when the content needs a calmer, more focused
    information row.
