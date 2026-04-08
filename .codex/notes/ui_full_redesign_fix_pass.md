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

## Final Continuation: Study UX Coverage

Date: 2026-04-08

This continuation stayed inside the study feature and closed the remaining
medium-risk UX gaps that could be improved without redesigning the session data
model itself.

### App-wide / shared-layer fixes touched

- extended [app_text_field.dart](/D:/workspace/memox/lib/shared/widgets/inputs/app_text_field.dart)
  so study inputs can request an explicit `textInputAction`

### Shared widget / shared-in-feature fixes

- added
  [study_mistakes_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/study_mistakes_panel.dart)
  as a reusable completion-time summary surface for difficult cards across
  multiple study modes
- added
  [review_rating_shortcuts.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_shortcuts.dart)
  to give review mode a non-touch action path without changing the visual shell

### Representative screen / mode fixes

- Review:
  - keyboard reveal and `1-4` rating shortcuts
  - difficult-card completion summary for `Again` cards
- Match:
  - deselect hint once one side is chosen
  - longer correct-state confirmation before fade-out
  - attempt-aware SRS rating instead of always `easy`
  - difficult-card completion summary based on mistaken pairs
- Guess:
  - small-deck quality warning
  - per-card skip-limit feedback and skipped-card completion summary
  - difficult-card completion summary for wrong or skipped cards
- Recall:
  - stricter reveal threshold for very short answers
  - `I don't know` fast path
  - practice-missed session labeling
  - edit-card affordance from the comparison view
  - difficult-card completion summary for missed or partial cards
- Fill:
  - better fallback prompt generation from hints/definitions
  - example-coverage warning for decks that are weak fits for fill mode
  - explicit keyboard submit intent through `TextInputAction.done`

### Realistic guard / regression coverage added now

- no new repo guard rules were needed for this continuation; the existing
  design/l10n/shared-widget guards already covered the touched paths cleanly
- regression protection was added through focused provider and screen tests for
  review, match, guess, recall, and fill

### Implemented now vs deferred

Implemented now:

- medium-risk action, explanation, and completion-summary improvements inside
  the existing provider/screen contracts
- stricter but still local anti-bypass rules for recall reveal and guess skip
- reusable difficult-card completion surfaces for the study modes that already
  had enough in-memory result data

Recommended next:

- review-mode undo with delayed commit or explicit rollback support
- pause/resume session persistence across app restart
- session history browsing UI
- “study next deck” selection policy and navigation flow
- card flagging/bookmarking plus deck-detail filtering

Intentionally deferred:

- any feature that requires new persistent session snapshots or a new card data
  field
- any review-undo implementation that would silently mutate completed SRS data
  without a dedicated rollback contract

### Verification for this continuation

- `dart run build_runner build --delete-conflicting-outputs` passed
- `flutter gen-l10n` passed
- `python tools/guard/run.py --scope all` passed with only the pre-existing
  `feature_completeness` warnings
- `flutter analyze` passed
- `flutter test` passed

## Follow-up Batch 9

Date: 2026-04-08

This continuation stayed inside the study feature and focused on the highest
value-to-risk UX improvements that were still missing after the earlier shell,
layout, and content-direction fixes.

### Additional fixes implemented now

#### Representative screen and mode fixes

- added rating guidance copy to review mode through:
  - [review_rating_grid.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_grid.dart)
  - [review_rating_button.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_button.dart)
- added a compact wrong-answer explanation surface for guess mode through:
  - [guess_feedback_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_feedback_card.dart)
  - [guess_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_round_view.dart)
- kept guess auto-advance behavior intact while exposing an explicit manual
  `Continue` action for answered questions
- added recall self-rating criteria through:
  - [recall_rating_guidance.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_rating_guidance.dart)
  - [recall_reveal_phase.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_reveal_phase.dart)
- clarified fill close-match decisions and lowered retry friction through:
  - [fill_feedback_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_feedback_panel.dart)
  - [fill_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/fill_provider.dart)
- implemented selection recovery in match mode through
  [match_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/match_provider.dart)
  so tapping an already-selected item clears that choice
- updated localized study strings in:
  - [app_en.arb](/D:/workspace/memox/l10n/app_en.arb)
  - [app_vi.arb](/D:/workspace/memox/l10n/app_vi.arb)
  - [app_ko.arb](/D:/workspace/memox/l10n/app_ko.arb)

#### Regression coverage

- updated focused study tests to lock the new UX contract in:
  - [review_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/review_mode_screen_test.dart)
  - [guess_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/guess_mode_screen_test.dart)
  - [recall_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/recall_mode_screen_test.dart)
  - [fill_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/fill_mode_screen_test.dart)
  - [fill_provider_test.dart](/D:/workspace/memox/test/features/study/presentation/providers/fill_provider_test.dart)
  - [match_provider_test.dart](/D:/workspace/memox/test/features/study/presentation/providers/match_provider_test.dart)

### Additional visual and UX impact

- review mode now gives first-time users clearer guidance on when to choose
  `Again/Hard/Good/Easy`
- guess mode now teaches on wrong answers instead of only marking them, and it
  lets users continue early without waiting for the timer when they answer
  correctly
- recall mode now anchors self-rating with explicit criteria instead of only
  three terse labels
- fill mode now explains what “close enough” means and surfaces hint/skip
  recovery earlier in the retry loop
- match mode now supports a more obvious recovery path for accidental taps

### Additional regression watchpoints

- this pass intentionally did not implement review undo, swipe-to-rate,
  pause/resume sessions, or recall minimum-answer gating because those would
  widen the change into persistence or SRS semantics
- guess mode now keeps both delayed auto-advance and manual `Continue`, so the
  live feel should still be spot-checked at shorter auto-advance durations
- fill retry still counts the first wrong answer as a wrong first attempt; this
  pass clarified the UX but did not rewrite the underlying grading semantics

### Verification for this continuation

- `dart run build_runner build --delete-conflicting-outputs`
  - passed
- `flutter gen-l10n`
  - passed
- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed

## Final continuation: study proportion cleanup

Date: 2026-04-08

This final continuation stayed inside the already-redesigned study feature and
polished the last high-signal compact-layout issues in fill and recall mode.

### Additional representative screen fixes

- reduced the blank-slot height in
  [fill_prompt_sentence.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_prompt_sentence.dart)
  so fill prompts stop wasting vertical space around the underline animation
- tightened
  [fill_feedback_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_feedback_panel.dart)
  so the response block sits closer to the input while keeping a clearly
  dominant accept action
- promoted the recall prompt label and retained the medium-length prompt bridge
  tier in
  [recall_prompt_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_prompt_card.dart)
- extended
  [recall_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/recall_mode_screen_test.dart)
  to lock the compact-surface prompt cap, sentence-case label, and writing-area
  visibility expectations

### Additional visual impact

- fill mode now gives more of the viewport back to the answer field and
  feedback state instead of spending it on a decorative blank pulse
- recall mode keeps the prompt cluster readable without letting the micro-label
  or medium-length term tier feel overbuilt
- the study shell now has a more even prompt -> answer -> feedback progression
  across both fill and recall

### Verification for this continuation

- `dart run build_runner build --delete-conflicting-outputs`
  - passed
- `flutter gen-l10n`
  - passed
- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed

## Follow-up Batch 8

Date: 2026-04-08

This continuation stayed in shared interaction contracts and cleaned up one
remaining press-feedback defect that still made otherwise improved screens feel
cheap during tap states.

### Additional fixes implemented now

#### App-wide interaction cleanup

- changed
  [app_theme.dart](/D:/workspace/memox/lib/core/theme/app_theme.dart)
  so the shared theme no longer paints a visible `highlightColor` layer and now
  uses `InkSparkle.splashFactory` for shape-respecting Material 3 splash
  feedback

#### Shared widget cleanup

- strengthened
  [icon_action_button.dart](/D:/workspace/memox/lib/shared/widgets/buttons/icon_action_button.dart)
  so compact icon actions keep their neutral filled surface but gain a clearer
  enabled-state outline in dark mode

#### Guard follow-up

- added `inkwell_highlight_override` in
  [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
  to keep future shared/theme code from overriding `highlightColor:` outside
  the one allowed theme owner

### Additional visual impact

- rounded cards and grouped settings rows now press with a cleaner,
  shape-respecting splash path instead of the old rectangular highlight layer
- compact icon actions such as settings steppers read more clearly as
  interactive without introducing a new visual language
- the fix is centralized, so existing rounded Ink surfaces benefit
  automatically

### Additional regression watchpoints

- this pass intentionally did not touch the Settings section header or section
  gap files because the current source already matches the calmer `titleLarge`
  and `Gap.section()` contract
- `InkSparkle` should still be spot-checked on-device for feel, especially on
  Android hardware where splash motion is most visible

### Verification for this continuation

- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed

## Follow-up Batch 4

Date: 2026-04-08

This continuation stayed in the shared shell. It fixed one remaining app-wide
bottom-rhythm inconsistency around floating actions without changing navigation
or screen-specific business behavior.

### Additional fixes implemented now

#### App-wide shell cleanup

- updated
  [app_scaffold.dart](/D:/workspace/memox/lib/shared/widgets/layout/app_scaffold.dart)
  so FAB-driven bottom breathing room is applied whenever a screen has a FAB,
  even if the same shell also has a bottom navigation bar
- centralized that formula as `AppScaffold.fabContentClearance` instead of
  duplicating the size math inline

#### Verification coverage

- extended
  [app_scaffold_test.dart](/D:/workspace/memox/test/shared/widgets/layout/app_scaffold_test.dart)
  with a `FAB + bottom nav` geometry assertion that locks the content baseline
  to the FAB top edge and confirms the remaining gap above the nav equals the
  shared clearance contract
- re-ran home and theme-preview screen tests to validate the shared shell change
  against the existing FAB consumers

### Additional visual impact

- screens using the shared FAB contract now land content at a more consistent
  bottom baseline across root-tab and detail contexts
- the app keeps the existing FAB placement style, but the content no longer
  feels visually lower on screens that combine FAB and bottom nav

### Additional regression watchpoints

- this pass intentionally did not change `floatingActionButtonLocation`, so any
  future request to make the FAB itself sit lower should be treated as a
  separate design decision rather than another body-padding tweak

## Follow-up Batch 5

Date: 2026-04-08

This continuation stayed inside the existing deck-detail/cards-section system.
It cleaned up one of the last dark-mode contrast weak spots and removed one
remaining feature-local action-pattern bypass.

### Additional fixes implemented now

#### Shared / shared-consumer cleanup

- strengthened the toolbar-search contract in
  [app_search_bar.dart](/D:/workspace/memox/lib/shared/widgets/inputs/app_search_bar.dart)
  by giving the toolbar variant an explicit enabled/focused border on top of
  its stronger fill tier
- replaced the expanded raw edit/delete icon row in
  [card_list_tile.dart](/D:/workspace/memox/lib/features/cards/presentation/widgets/card_list_tile.dart)
  with `AppEditDeleteMenu` and moved the card onto a clearer filled neutral
  surface with a stronger border

#### Representative screen cleanup

- moved the pinned cards toolbar in
  [deck_cards_toolbar.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar.dart)
  onto a stronger neutral surface tier and promoted the section title to
  `titleLarge`
- added a pinned-state divider in
  [deck_cards_toolbar_delegate.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar_delegate.dart)
  so the sticky toolbar reads as a distinct control band once content scrolls
  underneath it
- inserted a clearer section gap before the toolbar and increased card-row
  separators in
  [deck_detail_screen.dart](/D:/workspace/memox/lib/features/decks/presentation/screens/deck_detail_screen.dart)

### Additional visual impact

- the cards section now reads as a real section boundary below the overview
  instead of a low-contrast continuation of the same block
- search stays visible against the toolbar in dark mode
- card rows feel more containerized and their expanded actions match the shared
  menu grammar already used elsewhere in the library

### Additional regression watchpoints

- card edit/delete is now a calmer shared overflow menu, so action access is
  one tap deeper than the previous raw icon row
- no extra deck-detail sliver bottom padding was added because the shared
  `AppScaffold` FAB clearance already reserves more than `SpacingTokens.xxxl`
  at the bottom edge

## Follow-up Batch 6

Date: 2026-04-08

This continuation stayed within the existing settings/shared-control system and
finished one of the remaining weak reference screens without widening the
design-system scope.

### Additional fixes implemented now

#### Shared widget fixes

- lifted
  [settings_group_card.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_group_card.dart)
  onto a visible neutral surface tier with a clearer outline so grouped
  settings surfaces stop collapsing into the page background in dark mode
- upgraded
  [icon_action_button.dart](/D:/workspace/memox/lib/shared/widgets/buttons/icon_action_button.dart)
  to a clearer neutral surface/border treatment while preserving the shared
  MemoX icon-action contract and adding focused regression coverage in
  [icon_action_button_test.dart](/D:/workspace/memox/test/shared/widgets/buttons/icon_action_button_test.dart)

#### Representative screen fixes

- normalized inter-section rhythm in
  [settings_content_view.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_content_view.dart)
  so peer settings sections now separate with `Gap.section()`
- rebuilt
  [settings_section_header.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_section_header.dart)
  onto the calmer `titleLarge` tier and aligned it to the inner group-card
  content edge
- merged theme, language, and app color into one grouped Appearance surface in
  [settings_appearance_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_appearance_section.dart)
  and rebalanced the theme chooser into a stable three-column row
- let
  [settings_stepper_row.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_stepper_row.dart)
  inherit the restored 48dp shared icon-action target instead of locally
  shrinking the controls

### Additional visual impact

- Settings now reads as one coherent hierarchy instead of a stack of oversized
  section labels on top of faint card blocks
- the Appearance section feels compact and intentional instead of split into
  loosely related cards
- stepper controls are easier to spot and feel more consistent with the rest of
  the shared control grammar

### Additional regression watchpoints

- the Appearance chooser now assumes three equal columns on compact screens, so
  future locale growth should be spot-checked on-device before widening the
  labels or card padding
- this pass intentionally did not add a dedicated settings-only group-card
  variant; if another feature later needs the same calmer grouped-surface
  grammar, the team should decide whether to generalize it or keep it local to
  Settings

### Verification for this continuation

- `dart run build_runner build --delete-conflicting-outputs`
  - passed
- `flutter gen-l10n`
  - passed
- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed

## Follow-up Batch 7

Date: 2026-04-08

This continuation stayed inside the study feature and corrected one remaining
high-impact semantic mismatch between the redesigned UI and the actual content
shown to the user.

### Additional fixes implemented now

#### Representative screen / mode fixes

- reversed the fill prompt contract in
  [fill_engine.dart](/D:/workspace/memox/lib/features/study/domain/fill/fill_engine.dart)
  so fill mode now consistently expects `card.front` as the typed answer and
  uses the opposite side only as clue context
- removed the old mixed-direction example fallback from `FillEngine` so the
  mode can no longer alternate between two content directions across cards
- remapped
  [recall_prompt_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_prompt_card.dart)
  to show `card.back` in the prompt phase and
  [recall_reveal_phase.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_reveal_phase.dart)
  to reveal `card.front`

#### Regression coverage updates

- updated study regression coverage so the new prompt-direction contract is
  locked in:
  - [fill_engine_test.dart](/D:/workspace/memox/test/features/study/domain/fill/fill_engine_test.dart)
  - [fill_provider_test.dart](/D:/workspace/memox/test/features/study/presentation/providers/fill_provider_test.dart)
  - [fill_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/fill_mode_screen_test.dart)
  - [recall_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/recall_mode_screen_test.dart)
  - [study_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/study_screen_test.dart)

### Additional visual and UX impact

- fill mode now matches the intended “look at the answer-side clue, type the
  answer-side term” study direction instead of silently drifting between
  opposite mappings
- recall mode now presents and reveals content in the same direction users
  expect from the redesigned study shell
- the app-level study router tests now reinforce the corrected mode semantics
  instead of preserving the old inversion

### Additional regression watchpoints

- this pass intentionally did not rename copy or redesign the fill/recall
  surfaces; it corrected the content mapping first, so any later wording or
  layout polish should build on the now-stable study contract
- existing decks that were mentally worked around the old fill bug may feel
  different on first use, so on-device sanity-checking of a few real decks is
  still recommended

### Verification for this continuation

- `python tools/guard/run.py --scope all`
  - passed
  - only the pre-existing `feature_completeness` warnings remain
- `flutter analyze`
  - passed with no issues
- `flutter test`
  - passed
