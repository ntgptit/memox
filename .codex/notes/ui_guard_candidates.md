# MemoX UI Guard Candidates

Date: 2026-04-07  
Mode: Read-only guard-design audit using the MemoX `ui-heavy` workflow

## Scope

This report proposes realistic UI-quality guards for MemoX based on:

- the current guard engine under `tools/guard/**`
- the current MemoX policy files in `tools/guard/policies/memox/**`
- the existing UI audits in `.codex/notes/ui_audit_report.md`, `.codex/notes/ui_proportion_spacing_typography_audit.md`, `.codex/notes/ui_color_audit.md`, and `.codex/notes/shared_widget_audit.md`
- spot checks in representative Flutter source files

One caveat up front: `docs/memox-guard-spec.md` explicitly says its old architecture and file-layout section is historical. The current source of truth is the v2 guard documentation under `tools/guard/docs/` plus the active policy files under `tools/guard/policies/memox/`.

This is not a request for fake “AI design scoring.” The recommendations below stay inside what MemoX can realistically enforce with:

- normalized `forbidden_pattern` rules in `policy.yaml`
- normalized `content_contract` rules in `policy.yaml`
- path-based allowlists and thresholds
- small Python guards similar to the current legacy guards

## Current Guard Baseline

MemoX already protects several important UI basics:

- raw hardcoded colors, sizes, radii, font sizes, and strings are already covered by normalized `no_hardcoded_*` rules in `tools/guard/policies/memox/policy.yaml`
- raw Material buttons are already covered by `button_usage`
- raw `Scaffold` in feature screens is already covered by `screen_scaffold`
- basic touch-target enforcement already exists in `touch_target`
- raw `TextStyle` usage is already covered by `text_style`
- some shared-widget routing already exists in `shared_widget` and `shared_widget_mapping`
- responsive text-scaling and typography-contract protection already exist in `responsive_text_scale` and `typography_scale`

That means the next guard layer should not duplicate existing low-level bans. It should target the specific UI regression patterns the audits found:

- screen padding drift
- bloated shared-row composition
- weak variant discipline
- role confusion in color usage
- repeated shared-widget bypasses
- proportion problems created by valid tokens being combined badly

One obvious remaining gap is raw prominent Material controls. The repo rules explicitly call out `ChoiceChip`, `SegmentedButton`, and `SwitchListTile`, but the current normalized `shared_widget` rule does not obviously ban those constructors yet.

## Guard Architecture Fit

MemoX’s guard engine currently supports two good implementation paths:

1. `policy.yaml` normalized rules
   - best for path-based bans, token bans, required-token contracts, and allowlists
   - lowest maintenance path
2. small Python guards under `tools/guard/local_guards/`
   - best for counts, token-window correlation, or “A and B in the same widget file” heuristics
   - still realistic if the rule stays path-scoped and low-ambiguity

I do not recommend introducing a Dart AST parser or screenshot-based visual scoring right now. The current system is optimized for line-based and file-contract analysis, and the best next guards should fit that model.

## Prioritized Guard Candidates

### 1. Raw Feature Tap Handler Guard

- Category: shared widget usage
- What it checks:
  - forbid raw `InkWell(` and `GestureDetector(` inside `lib/features/**/presentation/**`
  - allow them only in approved shared wrappers such as `lib/shared/widgets/buttons/app_pressable.dart` and `lib/shared/widgets/buttons/app_tap_region.dart`
- Why it matters:
  - MemoX’s repo rules already say feature UI should route interactive behavior through shared wrappers
  - this prevents quiet regressions where a feature screen bypasses the shared interaction language
- How it might be implemented:
  - normalized `forbidden_pattern` rule in `tools/guard/policies/memox/policy.yaml`
  - include only `features/*/presentation/**`
  - exclude `shared/widgets/**`, tests, and any explicit geometry-driven allowlist
- False positive risk: low
- Maintenance cost: low
- Expected value to the team: high; this closes a clear policy gap with almost no engine work
- Classification: `high value and easy`

### 2. Rating-Color Scope Guard

- Category: color discipline
- What it checks:
  - flag `context.customColors.ratingAgain`, `ratingHard`, `ratingGood`, and `ratingEasy` outside `features/study/**`
  - allowlist theme-definition files and any truly approved shared study widgets
- Why it matters:
  - the color audit found study-rating colors leaking into general destructive and metadata roles in `shared/widgets/feedback/toast.dart`, `shared/widgets/feedback/error_view.dart`, `shared/widgets/lists/app_edit_delete_menu.dart`, `shared/widgets/lists/app_slidable_row.dart`, and `features/decks/presentation/widgets/deck_tile_due_pill.dart`
  - this is a clean, enforceable role-boundary problem
- How it might be implemented:
  - normalized `forbidden_pattern` rule in `policy.yaml`
  - include all Dart UI files
  - exclude `lib/core/theme/**`, `features/study/**`, and a short allowlist if needed
- False positive risk: low to medium
- Maintenance cost: low
- Expected value to the team: high; it directly prevents color-role drift after redesign
- Classification: `high value and easy`

### 3. Balanced Top-Bar Slot Allowlist Guard

- Category: proportion and sizing
- What it checks:
  - flag `TopBarIconButton.balancedSlotWidth` outside an explicit allowlist such as `study_top_bar.dart` and `top_bar_back_button.dart`
- Why it matters:
  - the audits found `96dp` reserved side slots are expensive on compact widths and should not silently spread
  - this is exactly the kind of “technically valid but visually costly” token usage that a narrow guard can prevent
- How it might be implemented:
  - normalized `forbidden_pattern` rule in `policy.yaml`
  - scan all Dart files except allowlisted shared navigation wrappers
- False positive risk: low
- Maintenance cost: low
- Expected value to the team: high; this prevents a known spacing/proportion regression with a one-line policy rule
- Classification: `high value and easy`

### 4. Shared Sheet Entry-Point Guard

- Category: shared widget usage
- What it checks:
  - flag direct `showModalBottomSheet(` usage in `features/*/presentation/**`
  - allow only approved shared entry points such as `context.showAppBottomSheet`, `showChoiceBottomSheet`, or explicit allowlisted feature wrappers
- Why it matters:
  - the shared-widget audit found sheet grammar fragmenting because `study_mode_sheet.dart` and `backup_list_sheet.dart` bypass shared modal patterns
  - if the redesign introduces better sheet variants, this guard will keep the team on that path
- How it might be implemented:
  - normalized `forbidden_pattern` rule in `policy.yaml`
  - include feature presentation files only
  - allowlist intentional wrappers during migration
- False positive risk: medium
- Maintenance cost: low to medium
- Expected value to the team: high once the redesigned sheet API exists
- Classification: `high value and easy`

### 5. Raw Prominent Material Control Guard

- Category: shared widget usage
- What it checks:
  - forbid raw `ChoiceChip(`, `SegmentedButton(`, and `SwitchListTile(` in `lib/features/**/presentation/**`
  - optionally also catch `PopupMenuButton(` outside approved shared menu wrappers
- Why it matters:
  - the repo UI rules explicitly call these out as controls that should not silently re-enter feature UI
  - this is a preventive guard: there are no active matches right now, which makes it a clean candidate to add before regressions appear
- How it might be implemented:
  - normalized `forbidden_pattern` rule in `policy.yaml`
  - include feature presentation files only
  - exclude `lib/shared/widgets/**`, theme files, and tests
- False positive risk: low
- Maintenance cost: low
- Expected value to the team: high; it locks in a repo rule that is currently under-enforced
- Classification: `high value and easy`

### 6. Shared Row Surface Ownership Guard

- Category: shared widget usage
- What it checks:
  - flag shared row primitives under `lib/shared/widgets/**` that instantiate `AppCard(` directly
  - target filenames such as `*tile.dart`, `*row.dart`, and `*list_item.dart`
- Why it matters:
  - the shared-widget audit found `AppCardListTile` and `AppCardSwitchTile` blurring the boundary between row layout and surface ownership
  - MemoX’s own rules say row primitives should not self-own their card shell
- How it might be implemented:
  - best as a small Python guard or a narrow `content_contract`/`forbidden_pattern` allowlist rule
  - start with `shared/widgets/lists/**` and `shared/widgets/inputs/**`
  - allowlist true surface widgets such as `stat_card.dart`
- False positive risk: low to medium
- Maintenance cost: low
- Expected value to the team: high; this directly protects a core redesign principle
- Classification: `high value and easy`

### 7. Scan-Heavy Row Variant Guard

- Category: shared widget usage
- What it checks:
  - flag `AppListTile(` in search, backup, and other scan-heavy paths unless the file is allowlisted or uses an explicit variant marker after redesign
  - initial targets:
    - `features/search/**`
    - `features/settings/**/backup*`
    - `features/statistics/**/difficult_cards*`
- Why it matters:
  - the current audits show `AppListTile` is too tall and generic for search results and some utility sheets
  - if the redesign adds `SearchResultRow` or `SheetOptionRow`, the guard can enforce the new contract
- How it might be implemented:
  - easiest path is extending `shared_widget_mapping` or adding a normalized `forbidden_pattern` by path
  - this is best added only after the replacement variants exist
- False positive risk: medium
- Maintenance cost: medium
- Expected value to the team: high after redesign; medium before redesign
- Classification: `high value but moderate effort`

### 8. Screen Padding Drift Guard

- Category: spacing discipline
- What it checks:
  - detect screens or root views that set `applyHorizontalPadding: false` and also add root-level `Padding` using `SpacingTokens.xl`, `SpacingTokens.screenPadding`, or equivalent `24dp` gutters
  - likely targets:
    - compact search
    - study round views
- Why it matters:
  - this is one of the clearest repeated UI regressions across the audits
  - MemoX already has shell-level padding rules, but nothing prevents local code from reintroducing wider gutters inconsistently
- How it might be implemented:
  - small Python guard in `tools/guard/local_guards/`
  - path-scoped to `features/*/presentation/screens/*` and `features/*/presentation/widgets/*_view.dart`
  - simple file-level heuristic: when a file contains `applyHorizontalPadding: false`, scan for nearby root `Padding(` / `EdgeInsets.symmetric(horizontal:` / `EdgeInsets.fromLTRB(` tokens using `SpacingTokens.xl` or `SpacingTokens.screenPadding`
- False positive risk: medium
- Maintenance cost: medium
- Expected value to the team: high; this would stop one of the most visible layout-rhythm regressions
- Classification: `high value but moderate effort`

### 9. Effective Row-Height Inflation Guard

- Category: proportion and sizing
- What it checks:
  - flag shared or feature row widgets that combine:
    - `AppPressable(`
    - significant vertical padding
    - a child with `ConstrainedBox(minHeight: SizeTokens.listItemCompact)` or `AppSwitchTile`
  - the current bad pattern lands around `76dp` in settings rows
- Why it matters:
  - this is a direct cause of bloated settings density
  - it is not a token problem; it is a composition problem between valid tokens
- How it might be implemented:
  - small Python guard that looks for token combinations in one widget file
  - start with `features/settings/**`
  - optionally compute a simple effective height when the padding tokens are recognized
- False positive risk: medium
- Maintenance cost: medium
- Expected value to the team: high; it would catch a repeated density bug family that current hardcode guards miss
- Classification: `high value but moderate effort`

### 10. Mixed CTA Height Pair Guard

- Category: proportion and sizing
- What it checks:
  - flag side-by-side `PrimaryButton(` and `SecondaryButton(` usage when both are using default heights in the same dialog or action row
  - especially valuable in `*_dialog.dart` files
- Why it matters:
  - the proportion audit found the `52dp` vs `48dp` mismatch makes modal CTA pairs look swollen instead of intentionally hierarchical
- How it might be implemented:
  - small Python guard with a narrow path scope:
    - `shared/widgets/dialogs/**`
    - `features/*/presentation/widgets/*_dialog.dart`
  - token-window heuristic: detect both button types within the same `Row(` or `actions:` cluster without explicit shared height
- False positive risk: medium
- Maintenance cost: medium
- Expected value to the team: medium to high; it protects a polished modal detail after redesign
- Classification: `high value but moderate effort`

### 11. Section-Gap Overuse Guard

- Category: spacing discipline
- What it checks:
  - warn when a screen or content view contains `Gap.section()` or `SpacingTokens.sectionGap` four or more times in the same file
  - restrict to dashboard-like or settings-like scroll surfaces
- Why it matters:
  - the audits found chapter-sized spacing is overused between peer blocks, especially in `statistics_content_view.dart`
  - this makes pages feel padded and report-like
- How it might be implemented:
  - small Python count-based guard
  - warning severity only
  - path-scoped to screen/view files
- False positive risk: medium
- Maintenance cost: low to medium
- Expected value to the team: medium; good signal if the scope is narrow
- Classification: `useful but optional`

### 12. Full-Spectrum Status Coloring Guard

- Category: color discipline
- What it checks:
  - warn when the same semantic token family is used in one widget for:
    - container fill or background
    - border
    - text
    - icon
  - likely token groups:
    - `ratingAgain`, `ratingHard`, `ratingGood`, `ratingEasy`
    - `error`, `warning`, `success`
- Why it matters:
  - `guess_option_button.dart` and `review_rating_button.dart` show the exact “flat and noisy” pattern the color audit called out
- How it might be implemented:
  - small Python guard that counts token reuse per file/class
  - warning severity only
  - allowlist tightly scoped study widgets if the redesign intentionally keeps one loud case
- False positive risk: medium to high
- Maintenance cost: medium
- Expected value to the team: medium; valuable for review, but not stable enough to hard-fail early
- Classification: `useful but optional`

### 13. Shared Sheet Header Hierarchy Guard

- Category: typography discipline
- What it checks:
  - enforce that shared bottom-sheet headers use a stronger title role than their option-row titles
  - start with exact shared files such as `shared/widgets/dialogs/choice_bottom_sheet.dart`
- Why it matters:
  - the current shared sheet family is inconsistent: `ChoiceBottomSheet` uses `titleMedium`, while `StudyModeSheet` uses `titleLarge`
  - shared modal primitives should not flatten their own hierarchy
- How it might be implemented:
  - normalized `content_contract` rule on exact shared files after redesign
  - require a stronger header token such as `titleLarge` or `headlineMedium`
- False positive risk: low
- Maintenance cost: low
- Expected value to the team: medium; very useful once the new modal contract is decided
- Classification: `useful but optional`

### 14. Completion-Loudness Heuristic Guard

- Category: screen-level heuristic
- What it checks:
  - warn when one shared completion surface combines:
    - `SuccessIndicator`
    - `statNumberSm` or equivalent strongest type token used multiple times
    - multiple metric rows
    - a `PrimaryButton`
  - especially valuable for `SessionCompleteView`
- Why it matters:
  - the current completion screen problem is real, but it is a composition heuristic, not a universal truth
- How it might be implemented:
  - small Python guard, warning only
  - exact-file or shared-widget allowlist target
- False positive risk: medium
- Maintenance cost: medium
- Expected value to the team: medium for review support, low for hard enforcement
- Classification: `useful but optional`

## Guards That Are Not Worth Implementing

### A. “Too Many CTAs in a Screen”

- Why not:
  - CTA count depends too much on screen type
  - settings, study, onboarding, and detail screens naturally have different action densities
- Better alternative:
  - enforce specific anti-patterns like mixed CTA heights or `TextLinkButton` misuse instead
- Classification: `not worth implementing`

### B. “Too Many Accent Surfaces in a Screen”

- Why not:
  - counting primary or accent token usage per file will be noisy and easy to game
  - color maturity problems come from role misuse, not just count
- Better alternative:
  - guard color-role scope and specific status-color overuse patterns
- Classification: `not worth implementing`

### C. Generic Icon-to-Text Ratio Guard

- Why not:
  - static analysis cannot reliably infer rendered ratio from widget trees without a much heavier parser
  - the same icon size can be correct or wrong depending on padding and surface role
- Better alternative:
  - enforce known bad slot budgets like `balancedSlotWidth`, and keep icon hardcode bans in the existing system
- Classification: `not worth implementing`

### D. “Too Many Text Styles in One Widget Tree”

- Why not:
  - this would punish legitimate complex surfaces
  - file-level counting does not map cleanly to actual rendered hierarchy
- Better alternative:
  - protect high-value shared surfaces directly, such as sheets and completion views
- Classification: `not worth implementing`

## Recommended Implementation Order After Redesign

### Implement first

1. Raw Feature Tap Handler Guard
2. Rating-Color Scope Guard
3. Balanced Top-Bar Slot Allowlist Guard
4. Raw Prominent Material Control Guard
5. Shared Row Surface Ownership Guard
6. Screen Padding Drift Guard
7. Effective Row-Height Inflation Guard

These six guards target the highest-signal regressions from the audits and do not require speculative design scoring.

### Implement second

1. Scan-Heavy Row Variant Guard
2. Shared Sheet Entry-Point Guard
3. Mixed CTA Height Pair Guard
4. Shared Sheet Header Hierarchy Guard

These should land after the redesign defines the replacement variants and modal contracts.

### Keep as warning-only experiments

1. Section-Gap Overuse Guard
2. Full-Spectrum Status Coloring Guard
3. Completion-Loudness Heuristic Guard

These are useful review aids, but they are better as warnings than fail-the-build checks.

## Lightweight Guards That Could Be Added Now

These are the safest immediate additions if the team wants quick wins before a full redesign pass:

1. `no_raw_feature_tap_handlers`
   - simple policy rule
   - low engine cost
   - directly enforces repo rules
2. `top_bar_balanced_slot_allowlist`
   - simple policy rule
   - very low noise
   - guards a known proportion regression
3. `no_raw_prominent_material_controls`
   - simple policy rule
   - directly protects the repo rule against raw `ChoiceChip`, `SegmentedButton`, and `SwitchListTile`
   - currently low-noise because the repo does not appear to rely on those in feature UI
4. `study_rating_color_scope`
   - simple policy rule
   - should likely start as `warning` until existing non-study violations are cleaned up
5. `no_direct_feature_show_modal_bottom_sheet`
   - simple policy rule
   - should start with a short allowlist because current code still has deliberate bypasses

## Bottom Line

MemoX does not need abstract “design intelligence” in its guard system. It needs a tighter second layer of UI-specific protections on top of the existing hardcode and shared-widget rules.

The strongest candidates are the ones that:

- protect a known repeated regression from the audits
- fit the current guard engine cleanly
- stay narrow and path-scoped
- avoid pretending static analysis can judge overall beauty

The best next guards are not generic screen scores. They are contract guards around:

- interaction wrappers
- color-role boundaries
- shared-surface ownership
- compact spacing discipline
- row-height inflation
- a few known expensive shared-widget defaults

Those are realistic to maintain, realistic to explain in PRs, and likely to materially improve UI quality over time.
