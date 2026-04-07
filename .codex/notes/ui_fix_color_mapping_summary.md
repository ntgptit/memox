# MemoX UI Color Mapping Fix Summary

Date: 2026-04-08  
Mode: coordinator-owned implementation using the MemoX `ui-heavy` workflow

## What This Pass Fixed

This pass implemented the highest-leverage color fixes that were already
identified by the color audit. It stayed inside the existing token, theme, and
shared-widget system. It did not introduce a new palette, and it did not apply
screen-by-screen hardcoded overrides.

The main color problems addressed were:

- excessive primary and accent usage in low-priority shared controls
- weak neutral surface layering between page background, cards, dialogs, sheets,
  and filled inputs
- flattened contrast hierarchy where status or accent colors were doing too much
  of the hierarchy work
- destructive and study-status colors being reused too aggressively in shared
  error and delete patterns
- visually noisy semantic states in study and statistics surfaces

## Shared Layers and Screens Updated

### Shared theme and color mapping

- `lib/core/theme/app_theme.dart`

### Shared widgets

- `lib/shared/widgets/buttons/secondary_button.dart`
- `lib/shared/widgets/cards/selectable_card.dart`
- `lib/shared/widgets/chips/mode_chip.dart`
- `lib/shared/widgets/chips/status_chip.dart`
- `lib/shared/widgets/feedback/error_view.dart`
- `lib/shared/widgets/feedback/toast.dart`
- `lib/shared/widgets/inputs/app_search_bar.dart`
- `lib/shared/widgets/inputs/app_switch_tile.dart`
- `lib/shared/widgets/inputs/app_text_field.dart`
- `lib/shared/widgets/lists/app_edit_delete_menu.dart`
- `lib/shared/widgets/lists/app_slidable_row.dart`
- `lib/shared/widgets/lists/reorder_mode_banner.dart`

### High-impact feature widgets and screens improved by the color cleanup

- `lib/features/decks/presentation/widgets/deck_tile_due_pill.dart`
- `lib/features/decks/presentation/widgets/deck_tile_supporting.dart`
- `lib/features/statistics/presentation/widgets/streak_hero_card.dart`
- `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart`
- `lib/features/statistics/presentation/widgets/difficult_cards_section.dart`
- `lib/features/study/presentation/widgets/review_rating_button.dart`
- `lib/features/study/presentation/widgets/guess_option_button.dart`
- `lib/features/study/presentation/widgets/fill_answer_input.dart`
- `lib/features/study/presentation/widgets/fill_feedback_panel.dart`
- `lib/features/settings/presentation/widgets/settings_action_row.dart`
- `lib/features/settings/presentation/widgets/settings_data_section.dart`

### Verification and guard coverage

- `test/core/extensions/context_extensions_test.dart`
- `test/core/theme/theme_extensions_test.dart`
- `test/shared/widgets/buttons/shared_button_defaults_test.dart`
- `test/shared/widgets/chips/status_chip_test.dart`
- `test/shared/widgets/inputs/app_search_bar_test.dart`
- `tools/guard/policies/memox/rules.yaml`

## What Was Implemented

### 1. Neutral surface layering was rebuilt around the existing color roles

In `app_theme.dart` I separated the default surface roles more clearly:

- scaffold background now uses `colorScheme.surfaceContainerLowest`
- shared cards now use `colorScheme.surface`
- dialogs and bottom sheets now use `colorScheme.surfaceContainerLow`
- filled inputs now use `colorScheme.surfaceContainerHigh`
- chip defaults now stay on neutral utility surfaces instead of drifting toward
  accent treatments

This gives MemoX a clearer page-to-container ladder without inventing new
colors or changing the seed-color architecture.

### 2. Accent use was reduced in shared low-priority controls

In the shared widget layer:

- `SecondaryButton` now defaults to `onSurfaceVariant` text with
  `outlineVariant` instead of spending the stronger primary emphasis
- `SelectableCard` and `ModeChip` no longer rely on primary-tinted fills for
  the selected state; they now use neutral elevated containers with a softer
  primary-focus border
- `ReorderModeBanner` no longer uses a primary-tinted border and icon for a
  temporary utility state
- `StatusChip` now keeps the container neutral and the label neutral; only the
  dot keeps the semantic status color

These changes calm shared selection and status patterns across the app.

### 3. Error and destructive mapping now uses the system error role instead of study colors

The audit showed that `customColors.ratingAgain` had leaked into shared error
and destructive contexts. That kept the UI technically consistent but visually
confused, because a study difficulty color was also acting as the global delete
and error color.

I normalized these mappings:

- `ErrorView` now uses `context.colors.error`
- `AppTextField` error style now uses `context.colors.error`
- `AppEditDeleteMenu` delete action now uses `context.colors.error`
- `AppSlidableRow` delete action now uses `errorContainer` and
  `onErrorContainer`
- toast error iconography now uses `context.colors.error`

This separates destructive/error semantics from study-specific rating colors.

### 4. Toast and utility surfaces were softened

`Toast` no longer uses loud semantic backgrounds. It now uses:

- `inverseSurface` as the shared background
- `onInverseSurface` for text
- semantic color only on the icon

This keeps success, info, and error feedback readable without creating another
large saturated block in the viewport.

`AppSearchBar` page mode and `AppCardSwitchTile` were also moved onto calmer
neutral container fills so utility controls stop competing with primary content.

### 5. High-noise study and statistics states were reduced

The feature-level fixes focus on places where the audits showed color noise was
hurting scan flow the most.

#### Study

- `ReviewRatingButton` now uses a neutral container and subtle semantic border
  treatment instead of an accent-heavy filled surface
- `GuessOptionButton` now keeps main answer text neutral, moves semantic color
  toward border and trailing icon, and uses softer state fills
- `FillAnswerInput` now uses softer semantic borders for correct, close, and
  wrong feedback instead of loud full-state framing
- `FillFeedbackPanel` no longer forces colored text-link overrides for accept
  and retry-close actions

#### Statistics

- `StatisticsPeriodTabs` now keep inactive tabs on `onSurfaceVariant`; only the
  selected tab carries the primary accent
- `StreakHeroCard` now uses a calmer neutral surface and keeps one focal accent
  on the main number instead of accenting both number and icon
- `DifficultCardsSection` now keeps ordinary percentages neutral and reserves
  warning color for the truly low-accuracy cases

#### Decks and settings

- `DeckTileDuePill` is now a neutral container with subtle outline instead of a
  loud study-status pill
- `DeckTileSupporting` now keeps the mastery label neutral so the mastery bar
  carries the emphasis
- `SettingsDataSection` no longer shows the destructive row title in red at
  rest
- `SettingsActionRow` was tightened so callers cannot inject arbitrary title
  colors for ordinary settings rows

## How Color Discipline Improved

### Visual noise is lower

Before this pass, MemoX spent saturated color on too many low-priority elements:

- selection cards
- chips
- utility banners
- delete affordances
- toast backgrounds
- settings actions
- study answer states

After this pass, accent and status colors are used more selectively. More of
the interface is now carried by neutral surfaces, neutral text, and subtle
borders, with semantic colors reserved for focal or truly stateful moments.

### Contrast hierarchy is clearer

The UI now relies less on bright color to manufacture hierarchy. Containers,
labels, and supporting text are more neutral, which makes the remaining primary
and error accents read as intentional rather than constant background noise.

### Color-role mapping is more disciplined

The biggest systemic cleanup is semantic separation:

- page, card, dialog, sheet, and input surfaces now have clearer neutral roles
- destructive and error states now use the Material error role instead of
  study-specific rating colors
- status chips and progress-adjacent elements now keep semantic color more
  locally scoped

## Lightweight Guard Additions

I added low-noise shared-layer guards in
`tools/guard/policies/memox/rules.yaml` for the exact regression patterns that
caused the worst color-role drift:

- `shared_error_view_color`
- `shared_toast_error_color`
- `shared_text_field_error_color`
- `shared_delete_menu_color`
- `shared_slidable_delete_color`

These guards specifically require the shared widgets to use the global error
roles and forbid the old `context.customColors.ratingAgain` mapping in those
files.

## Visual Impact

The visible result of this pass should be:

- calmer cards, dialogs, sheets, and utility controls
- less accent competition on settings, search, and list-adjacent shared widgets
- cleaner error and delete semantics
- study screens that still feel stateful without turning every option into a
  loud colored block
- statistics screens with one clearer focal accent instead of several competing
  accents on the same card

The strongest automatic improvements should show up in:

- shared feedback and destructive patterns
- selection controls and chips
- study answer states
- statistics header and filter controls
- deck browsing support metadata

## Regression Risk and Deferrals

### Low-to-moderate risk areas changed

- `app_theme.dart` affects every shared surface and filled input
- `SecondaryButton`, `SelectableCard`, `ModeChip`, and `StatusChip` affect many
  screens automatically
- study widgets may render slightly calmer than previous tests or screenshots
  assumed

I added or updated focused tests for the most important shared color contracts
to reduce this risk.

### Deliberately deferred in this pass

I did not expand this into a larger redesign of:

- progress-ring and mastery-bar color grammar
- chart or data-viz palette strategy
- seed-color generation behavior
- full-screen surface restructuring outside the already selected shared and
  reference widgets

Those can be handled later if the team wants a broader visual refresh, but they
were not necessary to remove the most harmful color noise.

## Verification

### Guard

- `python tools/guard/run.py --scope all`
- Result: passed with `0` errors
- Residual warnings: `14` pre-existing `feature_completeness` warnings for the
  empty feature `data/tables` and `data/daos` directories

### Analyzer

- `flutter analyze`
- Result: passed with no issues

### Tests

- `flutter test`
- Result: passed

### Test contract updated during verification

`test/core/extensions/context_extensions_test.dart` still expected the old
error snackbar background. I updated it to the new calmer toast contract:

- snackbar background expects `context.colors.inverseSurface`
- error icon expects `context.colors.error`

That change aligned the test with the implemented shared behavior.

## Minimal Next Safe Batch

The next safe color follow-up should stay focused and shared-layer-first:

1. review whether `MasteryBar` and `MasteryRing` still overspend accent in
   mixed-information surfaces
2. tighten any remaining feature-level uses of status colors as text-color-only
   hierarchy substitutes
3. add one or two more file-specific guards if another shared widget regresses
   into study-color-as-error or accent-fill-overuse

This pass already addressed the highest-leverage color-role problems without
needing a broader palette rewrite.
