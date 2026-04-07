# MemoX UI Full Redesign Fix Pass

## Scope

This pass did not start a new visual system. It closed the highest-impact
remaining issues after the earlier app-wide, shared-widget, reference-screen,
color, and guard passes.

The remaining problems were concentrated in four places:

- shared study header alignment still ignored responsive screen padding
- the statistics reference screen still felt too card-heavy and flat in the
  first viewport
- the statistics period filter was still fragile on compact localized layouts
- the backup history sheet still had weak title hierarchy and overflow risk

The work stayed inside the existing token, theme, and shared-widget system and
did not change business logic, routing, or state behavior.

## Highest-impact fixes made

- aligned `StudyTopBar` content to the same responsive gutter system used by
  the app shell instead of leaving it on fixed compact padding
- improved statistics screen scan flow by reducing repeated large gaps,
  promoting the screen title, softening hero noise, and moving the most useful
  section earlier
- replaced the underline-only statistics period tabs with calmer shared-style
  pills that wrap safely on compact and localized layouts
- made the backup history sheet scroll safely for long lists and restored a
  proper sheet-title hierarchy
- added a narrow guard contract so the shared study header does not regress to
  fixed spacing again

## Implemented now

### App-wide fixes

- `StudyTopBar` now uses `context.screenType.screenPadding` for both the title
  row and subtitle/meta row in
  [study_top_bar.dart](/D:/workspace/memox/lib/shared/widgets/navigation/study_top_bar.dart).
  This removes the old fixed `SpacingTokens.sm` and `SpacingTokens.lg` split
  that made study screens misalign against the rest of the app on larger
  breakpoints.

### Shared widget fixes

- `StudyTopBar`
  - change type: default behavior improvement
  - shared study chrome now follows the app shell gutter contract instead of
    self-owning a separate compact layout rhythm

### Representative screen fixes

- `StatisticsScreen`
  - files:
    - [statistics_content_view.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/statistics_content_view.dart)
    - [statistics_header.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/statistics_header.dart)
    - [statistics_period_tabs.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/statistics_period_tabs.dart)
    - [streak_hero_card.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/streak_hero_card.dart)
  - main issues fixed:
    - overly loose section rhythm from repeated `Gap.section()` usage between
      peer blocks
    - weak screen heading hierarchy at the top of the content stack
    - noisy hero card with too much emphasis below the main streak value
    - fragile period tabs that depended on equal-width row slots and broke down
      under longer localized labels
  - implementation:
    - reduced top padding and hero separation in the content stack
    - replaced repeated section-sized gaps with smaller peer-section spacing
    - promoted the header title to `appTitle` and tightened the header gap
    - softened supporting copy in `StreakHeroCard` so the main number stays
      dominant
    - rebuilt the period tabs as wrapped, pressable pill filters with calmer
      border and container emphasis
    - moved `DifficultCardsSection` earlier so the first scroll shows a more
      actionable section sooner
  - before/after improvement:
    - before, the screen read as a long stack of same-weight cards with a weak
      title and a brittle tab row
    - after, the screen lands the heading faster, keeps the streak as the
      focal point, and tolerates compact/localized layouts without overflow

- `BackupListSheet`
  - file:
    - [backup_list_sheet.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/backup_list_sheet.dart)
  - main issues fixed:
    - sheet title used list-row scale instead of sheet-title scale
    - long backup lists could grow a non-scrollable `Column` and risk overflow
  - implementation:
    - promoted the sheet title to `titleLarge`
    - constrained the list area and moved item rendering to
      `ListView.separated`
  - before/after improvement:
    - before, the sheet felt flat and could become structurally fragile with
      many backups
    - after, the title reads as a real sheet header and long backup histories
      remain scrollable

## Guards added

- updated
  [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
  with a new `study_top_bar_contract`
- the guard enforces three shared-layout invariants inside
  `StudyTopBar`:
  - `context.screenType.screenPadding`
  - `TopBarIconButton.balancedSlotWidth`
  - `SizeTokens.studyTopBarMetaHeight`

This is intentionally narrow. It protects the exact shared-header regression
that was still visible without introducing a noisy repo-wide spacing heuristic.

## Files changed

- [study_top_bar.dart](/D:/workspace/memox/lib/shared/widgets/navigation/study_top_bar.dart)
- [statistics_content_view.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/statistics_content_view.dart)
- [statistics_header.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/statistics_header.dart)
- [statistics_period_tabs.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/statistics_period_tabs.dart)
- [streak_hero_card.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/streak_hero_card.dart)
- [backup_list_sheet.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/backup_list_sheet.dart)
- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
- [study_top_bar_test.dart](/D:/workspace/memox/test/shared/widgets/navigation/study_top_bar_test.dart)
- [statistics_period_tabs_test.dart](/D:/workspace/memox/test/features/statistics/presentation/widgets/statistics_period_tabs_test.dart)
- [backup_list_sheet_test.dart](/D:/workspace/memox/test/features/settings/presentation/widgets/backup_list_sheet_test.dart)

## Visual impact

- study screens now align with the app shell more consistently across
  breakpoints
- statistics now has a cleaner first viewport, less dead space between peer
  blocks, a calmer hero, and safer compact-layout behavior
- the settings backup sheet now reads as a real modal surface instead of a
  title plus a raw list dump

## Regression risk

Low to moderate.

- `StudyTopBar` spacing changed in a shared surface, but the change is limited
  to using the existing responsive padding contract already used elsewhere
- statistics changes are structural but presentation-only; the order and
  spacing changed, not the data flow
- backup list sheet changed from a `Column` to a constrained `ListView`, which
  is safer for long data and does not affect backup actions

## Recommended next

- apply the calmer statistics section rhythm to the remaining dashboard-like
  surfaces that still stack equal-weight cards
- review other bottom sheets that still use row-title scale for their modal
  headers
- continue narrowing compact-width top-bar geometry where `balancedSlotWidth`
  still consumes too much width in non-study contexts

## Intentionally deferred

- no new token-scale remapping in this pass; the earlier shared theme work
  already handled the highest-value typography and color fixes
- no broad screen-padding guard heuristic; that would be noisy until more
  legacy screens finish migrating to the cleaned shared contracts
- no deeper statistics card decomposition; that should happen only if the team
  wants a larger dashboard redesign beyond this controlled pass

## Verification

- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain for empty
    feature `data/tables` and `data/daos` directories
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed

## Follow-up Batch

Date: 2026-04-08

This follow-up batch stayed inside the same controlled redesign strategy. It
did not reopen the global theme layer. It cleaned up one remaining library-row
inconsistency, tightened one still-loose reference-screen transition, and added
one more low-noise guard tied directly to the audited risks.

### Additional fixes implemented now

#### Shared / usage cleanup

- rebuilt
  [folder_deck_tile.dart](/D:/workspace/memox/lib/features/folders/presentation/widgets/folder_deck_tile.dart)
  on `AppCardListTile` and `AppTileGlyph` so folder-detail deck rows stop
  bypassing the shared library-row grammar
- stepped shared deck supporting description text down in
  [deck_tile_supporting.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile_supporting.dart)
  from `bodyMedium` to `bodySmall` to restore clearer title/support hierarchy

#### Representative screen cleanup

- tightened the home greeting-to-library handoff in
  [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
  by reducing the oversized post-greeting break and tightening the section
  label handoff

#### Guard follow-up

- added `balanced_top_bar_slot` in
  [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
  to keep `balancedSlotWidth` limited to the current allowlisted headers
- added a `folder_deck_tile` mapping rule in
  [rules.yaml](/D:/workspace/memox/tools/guard/policies/memox/rules.yaml)
  so folder-detail deck rows stay on the shared card-row grammar

### Additional files changed

- [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
- [folder_deck_tile.dart](/D:/workspace/memox/lib/features/folders/presentation/widgets/folder_deck_tile.dart)
- [deck_tile_supporting.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile_supporting.dart)
- [folder_deck_tile_test.dart](/D:/workspace/memox/test/features/folders/presentation/widgets/folder_deck_tile_test.dart)
- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
- [rules.yaml](/D:/workspace/memox/tools/guard/policies/memox/rules.yaml)

### Additional regression watchpoints

- focused-deck highlighting in folder detail now uses the shared border path
  instead of the old left accent stripe, so on-device contrast should still be
  checked during later visual QA
- the new `balanced_top_bar_slot` guard is intentionally strict and will need
  an explicit allowlist update if a future centered-title header truly needs
  the wider slot geometry

## Follow-up Batch 3

Date: 2026-04-08

This continuation pass stayed inside the same controlled redesign strategy. It
did not reopen the theme layer or introduce new visual primitives. It focused
on one remaining shared overlay inconsistency and two still-open representative
screen issues from the audit notes.

### Additional fixes implemented now

#### Shared widget and consistency fixes

- moved
  [choice_bottom_sheet.dart](/D:/workspace/memox/lib/shared/widgets/dialogs/choice_bottom_sheet.dart)
  onto the shared bottom-sheet entry helper and made long option lists
  scrollable through a constrained `ListView`
- switched
  [study_mode_sheet.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/study_mode_sheet.dart)
  and
  [backup_list_sheet.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/backup_list_sheet.dart)
  to `context.showAppBottomSheet(...)` so feature sheets stop bypassing the
  shared modal entry path
- kept improving deck-row hierarchy by leaving
  [deck_tile_supporting.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile_supporting.dart)
  on the calmer support-text tier

#### Representative screen fixes

- promoted the home folder section heading in
  [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
  from an uppercase metadata label to a real section heading, and tightened the
  reorder-banner handoff
- rebuilt the expanded rows in
  [difficult_cards_section.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/difficult_cards_section.dart)
  away from nested generic `AppListTile` usage and removed the old
  warning-colored accuracy emphasis

#### Guard follow-up

- added `feature_bottom_sheet_entrypoint` in
  [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
  to block raw `showModalBottomSheet(...)` usage from returning to feature
  presentation code
- updated the shared overlay contract for
  [choice_bottom_sheet.dart](/D:/workspace/memox/lib/shared/widgets/dialogs/choice_bottom_sheet.dart)
  so the shared helper path is now protected

### Additional files changed

- [choice_bottom_sheet.dart](/D:/workspace/memox/lib/shared/widgets/dialogs/choice_bottom_sheet.dart)
- [study_mode_sheet.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/study_mode_sheet.dart)
- [backup_list_sheet.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/backup_list_sheet.dart)
- [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
- [difficult_cards_section.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/difficult_cards_section.dart)
- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
- [choice_bottom_sheet_test.dart](/D:/workspace/memox/test/shared/widgets/dialogs/choice_bottom_sheet_test.dart)

### Additional visual impact

- feature and shared sheets now behave more consistently and tolerate long
  option lists
- the home screen handoff into the main library reads with clearer hierarchy
- the difficult-cards drill-down now feels more like analytics content and less
  like a generic settings/menu stack

### Additional regression watchpoints

- the new bottom-sheet entry guard is intentionally narrow; any future feature
  sheet wrapper must route through `context.showAppBottomSheet(...)` or a
  shared helper
- `DifficultCardsSection` now owns a local row composition, so later statistics
  redesign work should decide whether that pattern stays local or becomes a
  wider analytics-row primitive

### Verification for this continuation

- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed
