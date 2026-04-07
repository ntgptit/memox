# MemoX UI Redesign Roadmap

Date: 2026-04-08  
Mode: Read-only redesign planning using the MemoX `ui-heavy` workflow

## Scope

This roadmap assumes the MemoX UI audits are already complete and uses the findings from:

- `.codex/notes/ui_audit_report.md`
- `.codex/notes/ui_proportion_spacing_typography_audit.md`
- `.codex/notes/ui_color_audit.md`
- `.codex/notes/shared_widget_audit.md`
- `.codex/notes/ui_guard_candidates.md`

This is not a rebuild plan. MemoX already has tokens, theme foundations, and shared widgets. The redesign priority is to improve:

- mapping quality
- usage quality
- shared-widget behavior
- proportions
- hierarchy
- surface layering
- color restraint

## 1. Highest-Impact App-Wide Visual Corrections

These should be normalized globally before large screen-by-screen rewrites.

### 1. Typography hierarchy remap

- Normalize the overloaded `16px` and `24px` roles in:
  - `lib/core/theme/text_themes/app_text_theme.dart`
  - `lib/core/theme/text_themes/custom_text_styles.dart`
  - `lib/core/theme/tokens/typography_tokens.dart`
- Correct the current flattening where:
  - `titleMedium`, `titleSmall`, `bodyLarge`, and `bodyMedium` all land at `16`
  - `headlineLarge`, `titleLarge`, and `statNumberSm` all land at `24`
- Global goal:
  - `24` stays for app-bar, dialog, and one strong surface title
  - `20` becomes the real in-body section heading tier
  - `16` stays the base reading and interaction tier
  - `14` becomes the actual support/meta tier
  - `48` stays reserved for one dominant numeric focal point only
- This is the highest-leverage correction because it improves hierarchy across cards, lists, statistics, settings, study completion, and dialogs at once.

### 2. Compact spacing and padding discipline

- Normalize compact screen gutter ownership around one baseline:
  - compact default should come from shell-level padding
  - local screens should not disable shell padding and then recreate `24dp` gutters ad hoc
- Reserve `32` section gaps for true hero-to-section breaks only
- Normalize peer-section spacing closer to `20-24` for dashboards and settings stacks
- Normalize modal field gaps away from repeated `20` jumps unless the form truly needs editorial breathing room
- Target files and patterns first:
  - `lib/core/responsive/screen_type.dart`
  - `lib/core/responsive/responsive_padding.dart`
  - study round views
  - `search_screen.dart`
  - `statistics_content_view.dart`
  - dialog form widgets

### 3. Surface hierarchy and card restraint

- Stop using one neutral outlined `AppCard` shell for:
  - heroes
  - list rows
  - settings groups
  - stat tiles
  - prompts
  - feedback panels
- Introduce a clearer surface model:
  - row-card surface
  - hero/stat surface
  - settings group surface
  - utility/banner surface
- Also increase neutral separation between page background and content containers so the UI no longer feels both flat and noisy.

### 4. CTA hierarchy normalization

- Unify paired action proportions so hierarchy comes from role and styling, not swollen size mismatch
- Keep one clear policy for:
  - primary CTA
  - secondary button
  - quiet tertiary action
  - inline navigation text action
- The first fixes should reduce:
  - `PrimaryButton=52` vs `SecondaryButton=48` modal mismatch
  - `TextLinkButton` being used as the catch-all secondary action
  - study actions where loud answer states overpower the actual next-step action

### 5. Color restraint and semantic color scope

- Restrict primary to:
  - current navigation state
  - one dominant CTA
  - one focal data point or selected control per surface
- Restrict rating colors to study semantics
- Stop spending the same semantic color on fill, border, text, and icon together except for a deliberately chosen limited set of strong states
- Strengthen neutral surface separation before adding more accent treatment

### 6. Row density and sizing normalization

- Normalize single-line interactive rows toward roughly `56-64`
- Normalize two-line rows toward a tighter but readable range, not a default `72` everywhere
- Remove the current settings-row inflation pattern where `AppPressable` padding sits on top of already constrained row children
- Reduce header chrome slot waste, especially around `TopBarIconButton.balancedSlotWidth`

## 2. Shared Widget Redesign Priorities

These are the shared widgets with the highest leverage because they currently shape large parts of the app.

### Priority 1. `AppCard`, `AppCardListTile`, and `AppListTile`

- Why first:
  - they define surface language and row density across decks, folders, statistics, settings, search, and study
  - they are the largest source of repetition and overloaded compositions
- What redesign they need:
  - split surface roles more clearly
  - stop row primitives from self-owning card shells by default
  - add explicit variants for:
    - row-card
    - simple entity row
    - rich entity row
    - search row
    - sheet option row
    - settings row
- Files with the most leverage:
  - `lib/shared/widgets/cards/app_card.dart`
  - `lib/shared/widgets/lists/app_card_list_tile.dart`
  - `lib/shared/widgets/lists/app_list_tile.dart`

### Priority 2. `AppPressable`, `TextLinkButton`, and `InlineTextLinkButton`

- Why second:
  - they control interaction sizing and quiet-action hierarchy across settings, breadcrumbs, home, deck detail, statistics, and study
  - they currently blur row pressables, tertiary actions, inline links, and breadcrumb roles
- What redesign they need:
  - stricter API boundaries
  - quieter default tertiary action styling
  - breadcrumb-specific inline variant
  - better defaults so small text actions do not visually drag `48dp` bulk everywhere
- Files with the most leverage:
  - `lib/shared/widgets/buttons/app_pressable.dart`
  - `lib/shared/widgets/buttons/text_link_button.dart`
  - `lib/shared/widgets/buttons/inline_text_link_button.dart`

### Priority 3. `AppDialog`, `ChoiceBottomSheet`, `AppTextField`, and `AppSearchBar`

- Why third:
  - modal and input quality is currently consistent in structure but weak in hierarchy, rhythm, and variant clarity
  - search is split away from the main input system, and sheets/dialogs lack strong role separation
- What redesign they need:
  - explicit form-dialog variant
  - richer selection-sheet variant
  - stronger header hierarchy
  - unified search-field strategy instead of a separate low-contract path
- Files with the most leverage:
  - `lib/shared/widgets/dialogs/app_dialog.dart`
  - `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`
  - `lib/shared/widgets/inputs/app_text_field.dart`
  - `lib/shared/widgets/inputs/app_search_bar.dart`

### Priority 4. `StudyTopBar`, `TopBarIconButton`, and `SessionCompleteView`

- Why fourth:
  - they centralize the study chrome and completion experience across five study modes
  - they currently lock the app into expensive slots and a one-size-fits-all completion grammar
- What redesign they need:
  - compact top-bar slot policy
  - study header variants based on mode emphasis
  - multiple completion templates instead of one loud success stack
- Files with the most leverage:
  - `lib/shared/widgets/navigation/study_top_bar.dart`
  - `lib/shared/widgets/navigation/top_bar_icon_button.dart`
  - `lib/shared/widgets/feedback/session_complete_view.dart`

### Priority 5. Settings-specific wrappers

- Why fifth:
  - settings currently amplifies several weak shared defaults at once
  - row height, card grouping, dividers, and section headers all combine into a bureaucratic look
- What redesign they need:
  - lighter settings group surface
  - denser row variants
  - better separation between action row, choice row, switch row, and stepper row
- Files with the most leverage:
  - `lib/features/settings/presentation/widgets/settings_group_card.dart`
  - `settings_choice_row.dart`
  - `settings_action_row.dart`
  - `settings_stepper_row.dart`
  - `lib/shared/widgets/inputs/app_switch_tile.dart`

## 3. Screen Redesign Order

The redesign should use a small set of reference screens, then spread the new patterns outward.

### First reference screen: `DeckDetailScreen`

- Files:
  - `lib/features/decks/presentation/screens/deck_detail_screen.dart`
  - `deck_detail_header.dart`
  - `deck_detail_overview.dart`
  - `deck_cards_toolbar.dart`
- Why first:
  - it concentrates the biggest current problems in one place:
    - chrome-before-content
    - weak CTA hierarchy
    - toolbar density
    - stat tile proportion
    - search variant behavior
  - if this screen becomes disciplined, it sets the pattern for content-heavy detail screens
- Use it as the reference for:
  - detail-screen hierarchy
  - top-bar proportion
  - primary vs secondary action placement
  - list-toolbar rhythm

### Second reference screen: `SettingsContentView`

- Files:
  - `lib/features/settings/presentation/widgets/settings_content_view.dart`
  - `settings_group_card.dart`
  - `settings_choice_row.dart`
  - `settings_action_row.dart`
  - `settings_notifications_section.dart`
- Why second:
  - settings exposes row density, divider usage, sheet/dialog quality, and quiet action hierarchy very clearly
  - it is a good proving ground for the redesigned row family and modal family
- Use it as the reference for:
  - settings row height
  - group-card rhythm
  - choice-sheet and dialog behavior

### Third reference screen: `ReviewModeScreen`

- Files:
  - `lib/features/study/presentation/screens/review_mode_screen.dart`
  - `review_round_view.dart`
  - shared `StudyTopBar`
  - shared `SessionCompleteView`
- Why third:
  - review mode exercises the most important shared study chrome
  - it is a better first study reference than fixing all study modes at once
- Use it as the reference for:
  - study header proportion
  - study completion hierarchy
  - compact spacing discipline in study flows

### Fourth reference screen: `SearchScreen`

- Files:
  - `lib/features/search/presentation/screens/search_screen.dart`
  - `search_result_tile.dart`
  - `search_result_list.dart`
- Why fourth:
  - search is currently a clean, isolated place to normalize compact gutter rules and dense list-row variants
  - it will prove whether `AppListTile` really needs a search-specific variant
- Use it as the reference for:
  - utility-screen density
  - search-field behavior
  - search-row rhythm

### Fifth reference screen: `StatisticsContentView`

- Files:
  - `lib/features/statistics/presentation/widgets/statistics_content_view.dart`
  - `statistics_period_tabs.dart`
  - `streak_hero_card.dart`
  - chart sections
- Why fifth:
  - statistics needs a stronger dashboard hierarchy, but it depends heavily on better card, spacing, and type rules first
  - redesigning it too early would create screen-local fixes before the shared surface model stabilizes
- Use it as the reference for:
  - dashboard rhythm
  - hero vs peer-card contrast
  - restrained accent usage in analytics

### After reference screens

- Redesign next:
  - `HomeScreen`
  - folder and deck browsing rows
  - remaining study modes: guess, fill, recall, match
- These screens should mostly consume the improved shared components rather than invent new local patterns.

## 4. Safe Implementation Sequence

This order minimizes visual chaos and avoids scattering one-off fixes.

### Phase 0. Freeze redesign rules before editing screens

- Freeze these decisions first:
  - compact gutter policy
  - section-gap policy
  - typography role mapping
  - primary/secondary/tertiary action policy
  - semantic color scope rules
  - card surface taxonomy
  - row taxonomy

Do not start rewriting screens before these rules are explicit.

### Phase 1. Make app-wide mapping fixes

- Update global mapping and defaults without yet changing every screen:
  - typography mapping
  - compact spacing semantics
  - button hierarchy defaults
  - neutral surface layering
  - accent restraint policy

This phase should reduce the amount of local patching needed later.

### Phase 2. Redesign high-leverage shared widgets with backward-safe variants

- Add or refine variants first
- Keep existing widget names working where possible
- Avoid breaking all call sites at once
- Recommended order:
  1. card and row family
  2. link and pressable family
  3. dialog, sheet, and input family
  4. study header and completion family

### Phase 3. Redesign reference screens one by one

- Apply the new shared rules in this order:
  1. deck detail
  2. settings
  3. review mode
  4. search
  5. statistics

Each reference screen should be treated as the canonical example for a surface type, not as an isolated patch.

### Phase 4. Cascade to secondary screens

- Once the reference screens look stable:
  - update home
  - update folder and deck list surfaces
  - update remaining study modes
  - update smaller utility sheets and dialogs

This is where the app becomes visually consistent without reopening core shared decisions.

### Phase 5. Remove obsolete local workarounds

- Remove local `24dp` compact gutters where shell padding now owns spacing
- remove duplicated row padding patterns
- remove ad hoc card styling that the new variants replace
- remove modal/sheet local rebuilds that now have proper shared variants

## 5. Guard Follow-Up Strategy

The guard rollout should follow the redesign, not fight it prematurely.

### Guards to implement immediately after redesign

- `no_raw_feature_tap_handlers`
  - prevent feature UI from sneaking back to raw `InkWell` or `GestureDetector`
- `no_raw_prominent_material_controls`
  - lock in the repo rule against raw `ChoiceChip`, `SegmentedButton`, and `SwitchListTile`
- `top_bar_balanced_slot_allowlist`
  - stop `TopBarIconButton.balancedSlotWidth` from spreading
- `shared_row_surface_ownership`
  - stop row primitives from re-owning `AppCard`
- `study_rating_color_scope`
  - stop rating colors from leaking into general semantics

These are the cleanest, lowest-noise guards once the redesign rules are set.

### Guards to add after the new variants are stable

- `scan_heavy_row_variant_guard`
  - enforce search-row and sheet-row choices after those variants exist
- `no_direct_feature_show_modal_bottom_sheet`
  - enforce shared sheet entry points once the modal family is finalized
- `mixed_cta_height_pair_guard`
  - useful after dialog CTA rules are explicit
- `screen_padding_drift_guard`
  - useful after shell padding ownership is finalized
- `effective_row_height_inflation_guard`
  - useful after settings row contracts settle

### Guards that should stay warning-only for a while

- section-gap overuse
- full-spectrum status coloring
- completion-loudness heuristics

These are good review signals, but they are more heuristic and should not block iteration too early.

### Guards to avoid

- generic “too many CTAs in a screen”
- generic “too many accent colors in a screen”
- generic “too many text styles in a file”
- fake visual-score or “looks like default Flutter” guards

These will create noise, not quality.

## Minimal First Batch With Fast Visible Improvement

This is the smallest redesign batch that should create obvious improvement without destabilizing the app.

### Batch 1A. Theme and mapping corrections

- Remap typography hierarchy in:
  - `app_text_theme.dart`
  - `custom_text_styles.dart`
- Tighten secondary contrast and support-text hierarchy
- Normalize the global action hierarchy rules for:
  - primary CTA
  - secondary button
  - quiet tertiary action

This is the smallest app-wide change with the biggest immediate visual payoff.

### Batch 1B. Isolated shared widget corrections

- Add one clearer `AppCard` split:
  - row-card
  - hero/utility/stat surface
- Split `TextLinkButton` and `InlineTextLinkButton` into:
  - quiet tertiary action
  - true inline/breadcrumb role
- shared `SessionCompleteView`
  - quick win across all study completion screens with one shared change
- shared modal family:
  - `AppDialog`
  - `ChoiceBottomSheet`
  - equal-height paired CTA policy

These are isolated enough to improve the app visibly without forcing large feature-screen rewrites in the same batch.

### Batch 1C. Defer screen-heavy rollout to batch two

- Do not start batch one with:
  - `DeckDetailScreen`
  - `StatisticsContentView`
  - `SearchScreen`
  - full settings-screen rewrite
  - top-bar family rewrite
  - `AppListTile` family rewrite across multiple features

Those areas have larger regression surface and should consume the new shared rules only after the first shared-layer corrections settle.

Batch one should still make the app look materially more disciplined without touching business logic, routing, or data flow.

## Bottom Line

MemoX does not need a broad rewrite. It needs a controlled redesign in this order:

1. normalize app-wide mapping and hierarchy rules
2. redesign the shared widgets that currently amplify bad proportions and repetition
3. prove the new rules in a small set of reference screens
4. cascade the patterns across the rest of the app
5. add guards that lock the new discipline in place

If the team follows that order, the app should improve quickly and visibly without creating UI chaos or logic regression.
