# MemoX App-Wide UI Fix Summary

Date: 2026-04-08  
Mode: coordinator-owned shared-layer implementation using the MemoX `ui-heavy` workflow

## What This Pass Fixed

This pass only implemented centralized UI fixes that were already justified by the audits. It did not introduce a new design language, and it did not rewrite screens wholesale.

The main app-wide problems addressed were:

- flattened typography hierarchy in shared theme mapping
- overly loud secondary and tertiary actions caused by accent-heavy defaults
- weak surface layering where cards, dialogs, and sheets sat too close to the page background
- inconsistent CTA hierarchy caused by `PrimaryButton` and `SecondaryButton` default mismatch
- noisy completion screens where title, stats, and actions all competed at the same emphasis tier
- weak protection around shared shell and pressable primitives in the guard policy

I explicitly did **not** change geometry-anchor tokens such as global screen padding, list tall-row height, or top-bar slot math in this pass. A read-only regression pass showed those changes would have a wider blast radius than the safer mapping and shared-widget fixes.

## Shared Layers Modified

### Theme and mapping

- `lib/core/theme/app_theme.dart`
- `lib/core/theme/text_themes/app_text_theme.dart`
- `lib/core/theme/text_themes/custom_text_styles.dart`

### Shared widgets

- `lib/shared/widgets/buttons/primary_button.dart`
- `lib/shared/widgets/buttons/secondary_button.dart`
- `lib/shared/widgets/buttons/text_link_button.dart`
- `lib/shared/widgets/buttons/inline_text_link_button.dart`
- `lib/shared/widgets/cards/app_card.dart`
- `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`
- `lib/shared/widgets/feedback/session_complete_view.dart`

### Minimal downstream cleanup caused by the shared fix

- `lib/features/decks/presentation/widgets/deck_detail_overview.dart`

### Guard policy

- `tools/guard/policies/memox/policy.yaml`

### Verification and regression tests

- `test/core/theme/theme_extensions_test.dart`
- `test/core/extensions/context_extensions_test.dart`
- `test/shared/widgets/buttons/text_link_button_test.dart`
- `test/shared/widgets/buttons/shared_button_defaults_test.dart`
- `test/shared/widgets/cards/app_card_test.dart`
- `test/shared/widgets/feedback/session_complete_view_test.dart`

## What Was Implemented

### 1. Typography hierarchy normalization

In `app_text_theme.dart` and `custom_text_styles.dart` I rebalanced the shared type mapping without inventing new token sizes:

- `titleMedium` now reads as a stronger 16px title tier instead of feeling too close to body text
- `titleSmall` was softened into a lighter 16px support-title role
- `labelLarge` and `labelMedium` were moved toward quieter support/meta contrast
- `bodySmall` stayed in the approved scale but now behaves more clearly as secondary/support text
- `statNumberSm` was reduced from the louder 24px tier to the 20px bridge headline tier
- `appTitle` was promoted to the 24px navigation-level title tier
- `progressCount` was reduced to the 12px metadata tier so study headers and inline counters stop competing with main titles
- `questionText` and `studyTerm` were given slightly stronger weight so study prompts do not depend only on size

This improves hierarchy across statistics cards, completion screens, study chrome, settings rows, bottom sheets, breadcrumbs, and small support text.

### 2. Surface layering cleanup

In `app_theme.dart` and `app_card.dart` I moved shared neutral surfaces away from raw page-surface equality:

- `CardTheme` now defaults to `customColors.surfaceDim`
- popup menus now use the same dimmed neutral surface
- dialogs and bottom sheets now use the dimmed shared surface and shared shape contract
- `AppCard` now inherits the themed card surface by default instead of falling back to raw `colorScheme.surface`

This does not create a new visual language. It uses the existing custom neutral surface token more consistently so content containers no longer disappear into the scaffold background.

### 3. CTA sizing and emphasis normalization

In the shared button family:

- `PrimaryButton` now defaults to `SizeTokens.buttonHeight` instead of the swollen larger default
- `SecondaryButton` now defaults to neutral `onSurface` text with an `outline` border instead of spending the primary accent by default
- `TextLinkButton` now defaults to a quieter tertiary treatment using the support-text color instead of primary
- `TextLinkButton` arrow treatment was softened and reduced
- `InlineTextLinkButton` now activates to `onSurface` by default instead of jumping to primary

This fixes the most common hierarchy failure in the app: primary, secondary, and tertiary actions were too close in visual loudness because multiple layers defaulted to accent color.

### 4. Shared completion-shell cleanup

In `session_complete_view.dart` I reduced the completion-screen loudness:

- the page title now uses the shared 24px title tier
- stat labels now use support text instead of inheriting value color
- stat values now use the calmer 20px bridge tier
- the secondary action moved onto the quieter inline link primitive instead of the bulkier text-link wrapper

This keeps the completion surface focused on one main outcome and one next step instead of letting every metric shout.

### 5. Shared bottom-sheet hierarchy cleanup

In `choice_bottom_sheet.dart` the sheet title now uses the shared 24px title tier instead of the weaker 16px row-title tier. This gives selection sheets a real header without changing feature-specific sheet logic.

### 6. Low-noise guard additions

I added two narrow shared-layer contracts in `tools/guard/policies/memox/policy.yaml`:

- `app_scaffold_contract`
  - pins `AppScaffold` to its max-width, screen-padding, safe-area, and bottom-breathing behavior
- `app_pressable_contract`
  - pins `AppPressable` to Material + InkWell semantics and the default 48dp touch target

These guards are intentionally file-specific. They protect high-leverage shared primitives without introducing noisy heuristic checks.

## Visual Impact

The visible changes from this pass should be:

- clearer separation between titles, metadata, counters, and stat values
- quieter tertiary links and secondary actions
- less primary-color overuse in low-priority controls
- more mature neutral surface layering for cards, dialogs, sheets, and menus
- more balanced completion screens
- more consistent primary/secondary CTA proportions in dialogs and shared call-to-action stacks

The biggest improvements should show up in:

- study completion screens
- dialogs and bottom sheets
- deck detail action cards
- shared tertiary actions used across folders, decks, settings, and study
- any card-driven surface that previously blended into the page background

## Regression Risk and Deferrals

### Low-to-moderate risk areas changed

- typography weight and custom-style mapping can slightly reflow compact rows and counters
- neutralizing `SecondaryButton` and `TextLinkButton` changes perceived emphasis across many screens
- dimmed default card surface affects all `AppCard` consumers

I added direct widget coverage for the changed shared primitives to reduce this risk.

### Deliberately deferred in this pass

I did **not** normalize these globally yet because they are geometry anchors with a much wider blast radius:

- `SpacingTokens.screenPadding`
- `SpacingTokens.fieldGap`
- `SizeTokens.listItemTall`
- `TopBarIconButton.balancedSlotWidth`

Those should be tackled in a later pass together with dedicated layout-geometry tests for the coupled screens:

- `StudyTopBar`
- `DeckDetailHeader`
- `HomeScreen` and `FolderDetailScreen` top bars
- dense settings row stacks

## Verification

### Guard

- `python tools/guard/run.py --scope all`
- Result: passed with `0` errors
- Residual warnings: `14` pre-existing `feature_completeness` warnings for empty `data/tables` and `data/daos` directories across multiple features

### Analyzer

- `flutter analyze`
- Result: passed with no issues

### Tests

Ran:

- `flutter test test/core/theme/theme_extensions_test.dart test/core/extensions/context_extensions_test.dart test/shared/widgets/buttons test/shared/widgets/navigation test/shared/widgets/layout/app_scaffold_test.dart test/shared/widgets/compact_reference_widgets_test.dart test/shared/widgets/cards/app_card_test.dart test/shared/widgets/feedback/session_complete_view_test.dart`

Result:

- all targeted tests passed

## Minimal Next Safe Batch

The next safe app-wide batch should stay shared-layer-first and target:

1. `AppDialog` and related modal wrappers for tighter field rhythm and more disciplined action placement
2. `AppListTile` / `AppCardListTile` role separation so search, settings, entity rows, and sheet rows stop sharing one overloaded grammar
3. settings row density cleanup using row-specific variants instead of padding stacked on top of `AppPressable`
4. geometry-anchor normalization only after adding dedicated layout tests for top bars, study chrome, and dense card stacks
