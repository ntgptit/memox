# MemoX UI Audit Report

Date: 2026-04-07
Mode: Read-only code audit using the MemoX `ui-heavy` multi-agent workflow

## Scope

This audit reviews the current Flutter UI implementation in the codebase. It does not assume missing design-system foundations. MemoX already has:

- shared spacing, size, radius, color, and typography tokens
- app theme and shared text styles
- shared widgets for cards, list rows, buttons, navigation, feedback, and inputs

The main question is why the UI still reads as weak, inconsistent, crowded, flat, noisy, or unprofessional despite those foundations.

This report is based on code inspection. I could verify real widget structure, token values, and shared-widget usage. I could not verify runtime screenshots, device-specific rendering, localization overflow in every locale, or actual perceived contrast on device without running visual review.

## Observed Foundation Values

These values are important because most problems are not missing values, but weak mapping or weak usage:

- Screen padding by shell: `16 / 24 / 32` in `lib/core/responsive/screen_type.dart`
- Shared spacing tokens: `8 / 12 / 16 / 24 / 32 / 48`, plus semantic `cardPadding=16`, `screenPadding=24`, `sectionGap=32`, `fieldGap=20`
- Shared heights: `PrimaryButton=52`, `SecondaryButton=48`, `AppTextField=52`, `AppSearchBar=48`, `AppListTile=56` one-line and `72` two-line
- Shared card shell: `AppCard` default padding `16`
- Top-bar slot width: `TopBarIconButton.balancedSlotWidth = 96`
- Typography buckets: `48 / 32 / 24 / 20 / 16 / 14 / 12`

The design system inventory is present. The quality loss is mostly coming from token mapping, shared widget design limits, and repeated misuse of otherwise valid shared primitives.

## Findings

### Critical

#### 1. App-wide typography hierarchy is flattened by token mapping

- Screen or widget: `lib/core/theme/text_themes/app_text_theme.dart`, `lib/core/theme/text_themes/custom_text_styles.dart`, `lib/core/theme/tokens/typography_tokens.dart`
- What is wrong: too many roles resolve to the same size buckets. `titleMedium`, `titleSmall`, `bodyLarge`, and `bodyMedium` all land at `16px`. `headlineLarge`, `titleLarge`, and `statNumberSm` all land at `24px`.
- Why it weakens the UI: cards, rows, stats, helper blocks, and actions often read as equal-weight text groups. Screens feel flat when they should be layered, and loud when multiple `24px` roles appear on one surface.
- Visual principle violated: visual hierarchy
- Root cause: token mapping

#### 2. Study screens use conflicting compact gutters

- Screen or widget: `lib/features/study/presentation/widgets/review_round_view.dart`, `guess_round_view.dart`, `fill_round_view.dart`, `recall_round_view.dart`, compared with `lib/core/responsive/screen_type.dart`
- What is wrong: study round views hardcode `24dp` side padding while compact shell padding is `16dp`.
- Why it weakens the UI: switching between study modes changes the edge rhythm by 50%. The app no longer feels like one disciplined system.
- Visual principle violated: layout rhythm
- Root cause: shared widget usage

#### 3. Deck detail spends the first viewport on chrome instead of content

- Screen or widget: `lib/features/decks/presentation/screens/deck_detail_screen.dart`, `deck_detail_header.dart`, `deck_detail_overview.dart`, `deck_stats_grid.dart`, `deck_cards_toolbar.dart`
- What is wrong: the compact header expands to about `228dp`, the stats grid uses `84dp` tiles, the overview stacks actions, and the pinned toolbar is `104dp` tall before the actual card list settles in.
- Why it weakens the UI: the screen feels top-heavy and overbuilt. Users land in a wall of chrome, not in the core deck content.
- Visual principle violated: content priority, component proportion
- Root cause: shared widget usage, token mapping

#### 4. Session completion screens make every element feel primary

- Screen or widget: `lib/shared/widgets/feedback/session_complete_view.dart`
- What is wrong: the title uses a strong `24px` stat style, row values also use the same strong `24px` stat style, gaps repeat at `24dp`, and the primary CTA follows immediately in the same emphasis range.
- Why it weakens the UI: the completion state has no clean focal point. Outcome, recap values, and next action all compete.
- Visual principle violated: emphasis hierarchy
- Root cause: shared widget design, token mapping

### Major

#### 5. Statistics reads like a stack of equal-weight report cards

- Screen or widget: `lib/features/statistics/presentation/widgets/statistics_content_view.dart`, `statistics_header.dart`, `statistics_period_tabs.dart`, `streak_hero_card.dart`
- What is wrong: five peer sections are separated with repeated `32dp` section gaps, tabs are `48dp` tall but indicate selection with only a `3px` underline, and the hero mixes a `48px` number, `24px` label, and accent icon on one line.
- Why it weakens the UI: the page lacks a true focal hierarchy. Everything feels equally important and equally boxed.
- Visual principle violated: page-level hierarchy, layout rhythm
- Root cause: token mapping, shared widget usage

#### 6. Settings rows are oversized and make the whole screen feel bloated

- Screen or widget: `lib/features/settings/presentation/widgets/settings_choice_row.dart`, `settings_action_row.dart`, `settings_stepper_row.dart`, `settings_notifications_section.dart`, `lib/shared/widgets/buttons/app_pressable.dart`
- What is wrong: rows intended to be compact become about `76dp` tall because `12dp` vertical padding wraps a child that already enforces `52dp` minimum height.
- Why it weakens the UI: settings feels heavy, overpadded, and slower to scan than it needs to be.
- Visual principle violated: component proportion, density
- Root cause: shared widget design, shared widget usage

#### 7. Dialogs and sheets are structurally consistent but aesthetically weak

- Screen or widget: `lib/features/decks/presentation/widgets/create_deck_dialog.dart`, `lib/features/folders/presentation/widgets/create_folder_dialog.dart`, `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`, `lib/shared/widgets/buttons/primary_button.dart`, `secondary_button.dart`
- What is wrong: compact modal forms chain repeated `20dp` field gaps, many action pairs place a `52dp` primary button beside a `48dp` secondary button, and some sheets use a `16px` title against `16px` option rows.
- Why it weakens the UI: modals feel tall, generic, and mechanically assembled instead of precise and deliberate.
- Visual principle violated: CTA hierarchy, modal hierarchy, vertical rhythm
- Root cause: shared widget design, token mapping

#### 8. Study answer states overuse color and visual effects

- Screen or widget: `lib/features/study/presentation/widgets/guess_option_button.dart`, `review_rating_button.dart`, `fill_answer_input.dart`
- What is wrong: success, warning, and rating colors are escalated into full fills, borders, text, and icons at the same time. Guess options are `72dp` tall and visually heavier than the post-answer CTA.
- Why it weakens the UI: the screens feel noisy and toy-like rather than fast and confident. Visual emphasis goes to state color instead of task flow.
- Visual principle violated: color restraint, action hierarchy
- Root cause: token mapping, shared widget usage

#### 9. Deck and folder browsing cards are over-assigned

- Screen or widget: `lib/features/decks/presentation/widgets/deck_tile.dart`, `deck_tile_supporting.dart`, `lib/features/folders/presentation/widgets/folder_tile.dart`, `folder_deck_tile.dart`, `lib/shared/widgets/lists/app_card_list_tile.dart`
- What is wrong: the same list item shell carries title, subtitle, tags, due pill, mastery, menu, reorder handle, and highlight states. The same deck also appears with different leading grammars in deck lists and folder detail.
- Why it weakens the UI: library browsing feels crowded, repetitive, and visually inconsistent across surfaces that should feel related.
- Visual principle violated: grouping, consistency
- Root cause: shared widget usage

#### 10. Search breaks the app’s compact rhythm without gaining clarity

- Screen or widget: `lib/features/search/presentation/screens/search_screen.dart`, `search_result_list.dart`, `search_result_tile.dart`, `lib/shared/widgets/lists/app_list_tile.dart`
- What is wrong: search disables shell padding, then reintroduces `24dp` fixed gutters on compact; result rows inherit the `72dp` two-line path for simple title/subtitle results.
- Why it weakens the UI: the screen reads looser and taller than the rest of the app, but does not become cleaner or more premium.
- Visual principle violated: layout rhythm, density
- Root cause: shared widget usage, token mapping

#### 11. AppCard has become the default answer for too many different surface types

- Screen or widget: `lib/shared/widgets/cards/app_card.dart`, used widely in `home_greeting_card.dart`, `deck_stats_grid.dart`, `settings_group_card.dart`, `streak_hero_card.dart`, and study widgets
- What is wrong: one neutral outlined card shell is used for heroes, prompt cards, stat tiles, menu stacks, list rows, and summary blocks.
- Why it weakens the UI: the app feels visually repetitive and low-contrast. Surface hierarchy exists technically, but not compositionally.
- Visual principle violated: surface hierarchy
- Root cause: shared widget design

### Moderate

#### 12. Top bars and breadcrumbs spend too much compact-space budget

- Screen or widget: `lib/shared/widgets/navigation/top_bar_icon_button.dart`, `study_top_bar.dart`, `breadcrumb_bar.dart`, `inline_text_link_button.dart`
- What is wrong: `96dp` balanced slots and visually tall breadcrumb links consume too much space for minor navigation content.
- Why it weakens the UI: important titles get squeezed while secondary affordances feel oversized.
- Visual principle violated: component proportion
- Root cause: shared widget design

#### 13. Home screen spacing does not match actual content importance

- Screen or widget: `lib/features/folders/presentation/screens/home_screen.dart`
- What is wrong: a lightweight greeting card gets a full `32dp` break before a weak `12px` section label and list header.
- Why it weakens the UI: spacing suggests stronger hierarchy than the content actually carries. The page feels padded instead of composed.
- Visual principle violated: spacing hierarchy
- Root cause: token mapping, shared widget usage

#### 14. Settings grouping is mechanically organized but visually bureaucratic

- Screen or widget: `lib/features/settings/presentation/widgets/settings_group_card.dart`, `settings_section_header.dart`, `settings_content_view.dart`
- What is wrong: section headers are small uppercase labels, cards drop all internal padding, and dividers are inserted after every child. Combined with large row heights and repeated `32dp` section gaps, the page becomes “label / card / divider / row / divider / row.”
- Why it weakens the UI: the structure looks systematic but not refined. It reads like a settings scaffold rather than a designed screen.
- Visual principle violated: grouping, rhythm
- Root cause: shared widget design, shared widget usage

#### 15. Some numeric proportions are technically consistent but aesthetically off

- Screen or widget: `lib/features/decks/presentation/widgets/deck_tile_due_pill.dart`, `deck_stats_grid.dart`, `lib/features/statistics/presentation/widgets/mastery_donut_chart_section.dart`
- What is wrong: due pills are visually small next to mastery rings and menu targets, stat tiles are tall relative to the amount of information they carry, and some chart centers are not emphasized enough for the footprint they occupy.
- Why it weakens the UI: the app feels awkward rather than polished. Components do not look intentionally tuned to their content.
- Visual principle violated: local proportion
- Root cause: token mapping

### Minor

#### 16. Shared sheet family is inconsistent

- Screen or widget: `lib/features/decks/presentation/widgets/study_mode_sheet.dart`, `lib/shared/widgets/dialogs/choice_bottom_sheet.dart`
- What is wrong: the study mode sheet uses a stronger `24px` title, but the generic choice sheet uses `16px`, while both rely on similar list primitives and outer padding.
- Why it weakens the UI: modal surfaces do not feel governed by one strong rule set.
- Visual principle violated: component consistency
- Root cause: shared widget design, shared widget usage

#### 17. Home greeting action feels visually smaller than its tap area

- Screen or widget: `lib/features/folders/presentation/widgets/home_greeting_card.dart`, `lib/shared/widgets/buttons/text_link_button.dart`, `app_pressable.dart`
- What is wrong: a small `14px` link sits inside a shared `48dp` minimum pressable area inside a card that otherwise carries very light content.
- Why it weakens the UI: the card feels taller than its information load.
- Visual principle violated: local proportion
- Root cause: shared widget design

## Top 10 Highest-Impact UI Problems

1. Flattened typography hierarchy caused by overloaded `16px` and `24px` mappings.
2. Conflicting compact gutters between shell-level `16dp` and local `24dp`.
3. Deck detail front-loading header, stats, actions, and toolbar before actual content.
4. Session completion screens making title, stats, and CTA all feel primary.
5. Statistics stacking too many same-weight cards with repeated `32dp` gaps.
6. Settings rows inflating to `76dp` and making the whole screen feel bloated.
7. Dialogs and sheets using weak title hierarchy plus mismatched CTA heights.
8. Study answer states overusing color and container emphasis.
9. Deck and folder browsing cards carrying too many responsibilities in one shell.
10. AppCard being reused as the default visual answer for too many surface types.

## Repeated Anti-Patterns Across Multiple Screens

- Many semantic text roles resolve to the same size bucket, especially `16px` title/body pairs and `24px` title/value pairs.
- Large spacing tokens such as `sectionGap=32` are used between peer blocks, not only between major layout bands.
- Shared `48dp` minimum pressable affordances are applied to visually small text-link and breadcrumb content, making minor controls feel oversized.
- The same neutral card shell is reused across heroes, list rows, stat tiles, settings groups, and prompt surfaces.
- Compact screens often disable scaffold padding and then reintroduce fixed `24dp` gutters locally.
- Accent, success, warning, and rating colors are escalated from indicators into full containers, borders, text, and icons simultaneously.
- Similar content types, especially decks, are rendered with materially different local grammars across different screens.

## Redesign Priorities

### 1. App-wide mapping and shared-layer fixes first

- `lib/core/theme/text_themes/app_text_theme.dart`
- `lib/core/theme/text_themes/custom_text_styles.dart`
- `lib/shared/widgets/cards/app_card.dart`
- `lib/shared/widgets/lists/app_card_list_tile.dart`
- `lib/shared/widgets/lists/app_list_tile.dart`
- `lib/shared/widgets/navigation/top_bar_icon_button.dart`
- `lib/shared/widgets/navigation/breadcrumb_bar.dart`
- `lib/shared/widgets/buttons/inline_text_link_button.dart`
- `lib/shared/widgets/feedback/session_complete_view.dart`

These files define the visual grammar that keeps repeating. Centralized changes here will remove multiple downstream inconsistencies at once.

### 2. Representative screen patterns to redesign next

- Deck detail: `deck_detail_screen.dart`, `deck_detail_header.dart`, `deck_detail_overview.dart`, `deck_cards_toolbar.dart`
- Statistics: `statistics_content_view.dart`, `statistics_period_tabs.dart`, `streak_hero_card.dart`
- Settings: `settings_content_view.dart`, `settings_group_card.dart`, `settings_choice_row.dart`, `settings_action_row.dart`
- Study answer states: `guess_option_button.dart`, `review_rating_button.dart`, `fill_answer_input.dart`
- Library rows: `deck_tile.dart`, `deck_tile_supporting.dart`, `folder_tile.dart`, `folder_deck_tile.dart`
- Search: `search_screen.dart`, `search_result_tile.dart`

### 3. Screen patterns that should be split or simplified

- Tall detail pages that stack hero + stats + actions + pinned utilities before content
- Card rows that try to serve as summary, metadata, action host, and progress dashboard at once
- Settings menu stacks where oversized rows, repeated dividers, and weak section headers combine into bureaucratic rhythm
- Stateful answer controls that use color as the primary emphasis tool instead of hierarchy and flow

## Reusable Guard Ideas

These are realistic guard candidates tied directly to repeated issues found in the codebase. They are proposals only; no guard implementation is included in this pass.

### Spacing discipline

- Flag feature screens that set `applyHorizontalPadding: false` and also apply root-level `24dp` horizontal padding on compact layouts.
- Flag repeated sibling use of `SpacingTokens.sectionGap` or `Gap.section()` when the children are peer `AppCard`-like blocks.
- Flag modal forms that chain `SpacingTokens.fieldGap` three or more times inside one `AppDialog`.

### Component height consistency

- Flag row wrappers whose effective height exceeds a threshold because vertical padding wraps a child that already enforces a minimum height.
- Flag text-only controls with `minHeight >= 72dp`.
- Flag side-by-side dialog action sets that mix default `PrimaryButton` and `SecondaryButton` heights.

### Typography hierarchy discipline

- Flag components where the primary title and supporting body text resolve to the same font-size bucket.
- Flag sheet or dialog headers where header size is less than or equal to option-row title size.
- Flag completion or stats surfaces where multiple prominent text elements share the same strongest text style on one surface.

### Icon-to-text ratio checks

- Flag row or navigation contexts where `Icon` uses the default size next to `14-16px` text without an explicit sizing decision.
- Flag related list-row components that use materially different leading grammars for the same entity type.

### Color usage quality

- Flag full-container usage of success, warning, and rating colors outside a small approved widget list.
- Flag components that apply state color simultaneously to container fill, border, text, and icon unless they are explicitly whitelisted.

## Final Assessment

MemoX does not primarily suffer from missing tokens, missing theme primitives, or lack of shared widgets. It suffers from:

- weak token mapping
- overgeneralized shared surface primitives
- repeated misuse of valid shared widgets
- oversized compact components
- overuse of loud state color
- insufficient hierarchy between titles, support text, metadata, and actions

The safest high-impact path is not a per-screen patch spree. It is a controlled redesign of a small number of shared mappings and shared primitives, followed by targeted updates to representative screens that currently amplify those weaknesses.
