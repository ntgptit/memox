# MemoX Proportion, Spacing, and Typography Audit

Date: 2026-04-07  
Method: Read-only code audit using the MemoX `ui-heavy` multi-agent workflow

## Scope and Verification Limits

This report audits the current Flutter UI implementation for measurable visual quality issues. It focuses on:

- screen padding
- vertical rhythm
- typography hierarchy
- component height and internal balance
- card composition
- CTA strength and action hierarchy

It is based on code inspection of real screens, widgets, tokens, and shared components. I could verify actual values, layout structure, and token usage. I could not verify runtime screenshots, device-specific text wrapping, or live contrast perception on device in this pass.

## Baseline Values Found in the Codebase

These values already exist, so the main issue is not missing tokens. The issue is how they are mapped and used.

- Shell horizontal padding: `16 / 24 / 32` in `lib/core/responsive/screen_type.dart`
- Spacing tokens: `2 / 4 / 8 / 12 / 16 / 24 / 32 / 48`
- Semantic spacing:
  - `cardPadding = 16`
  - `screenPadding = 24`
  - `sectionGap = 32`
  - `fieldGap = 20`
  - `buttonGap = 8`
  - `chipGap = 8`
- Heights:
  - `PrimaryButton = 52`
  - `SecondaryButton = 48`
  - `AppTextField = 52`
  - `AppSearchBar = 48`
  - `AppListTile = 56` one-line, `72` two-line
  - `touchTarget = 48`
  - `deck toolbar = 104`
  - `study top-bar side slot = 96`
- Typography buckets: `48 / 32 / 24 / 20 / 16 / 14 / 12`

## Findings

## Critical

### 1. Study screens break compact padding discipline

- Screen or widget: `review_round_view`, `guess_round_view`, `fill_round_view`, `recall_round_view`
- Actual values found:
  - compact shell gutter is `16`
  - these study screens use `24` side padding
  - `match_round_view` follows the responsive compact rule instead
- Recommended range: compact content screens should usually stay in the `16-20` range unless the whole screen intentionally uses a wider editorial layout
- What is wrong: different study modes use different edge rhythms on the same device class
- Why it weakens the UI: switching modes changes the perceived width, density, and scan flow even though the user is still in the same study system
- Classification: poor rhythm, too loose

### 2. Deck detail front-loads too much vertical mass before content

- Screen or widget: `deck_detail_screen`, `deck_detail_header`, `deck_detail_overview`, `deck_cards_toolbar`, `deck_stats_grid`
- Actual values found:
  - compact header expands to about `228`
  - compact stat tiles land around `84`
  - primary CTA is `52`
  - secondary text-link still reserves `48`
  - pinned toolbar is `104`
  - first viewport spends roughly `650-700` vertical pixels before the user reaches card rows
- Recommended range: compact utility bands should usually live closer to `56-72` unless the screen is intentionally hero-led
- What is wrong: header, summary, stats, actions, and toolbar all stack at the top with similar prominence
- Why it weakens the UI: the deck feels secondary to its own chrome, so the screen reads as slow, crowded, and overbuilt
- Classification: poor grouping, poor rhythm, too loose

### 3. Typography hierarchy is technically valid but visually flattened

- Screen or widget: `app_text_theme`, `custom_text_styles`, repeated across deck, statistics, session complete, and list surfaces
- Actual values found:
  - `titleMedium`, `titleSmall`, `bodyLarge`, and `bodyMedium` all resolve to `16`
  - `headlineLarge`, `titleLarge`, and `statNumberSm` all resolve to `24`
  - many card titles and body blocks are effectively `16 / 16`
- Recommended range: within one component, title vs support text should usually separate by at least one bucket, commonly `20/16`, `16/14`, or `24/16`
- What is wrong: too many semantic roles occupy the same size tier
- Why it weakens the UI: titles, descriptions, stats, and actions blend together, so screens feel flat or uniformly loud
- Classification: poor hierarchy

### 4. Session completion screens make too many elements “primary”

- Screen or widget: `session_complete_view`
- Actual values found:
  - outer padding `24`
  - title uses strong `24` stat style
  - row values also use the same `24` stat style
  - vertical breaks repeat at `24`
  - primary CTA follows in the same strong field
- Recommended range: one dominant `24` focal element per completion surface; row values should usually step down to `16-20`
- What is wrong: title, stats, and action all share near-primary emphasis
- Why it weakens the UI: completion screens do not land a clean hierarchy and feel visually noisy instead of resolved
- Classification: poor hierarchy, poor grouping

## Major

### 5. Statistics uses `32` section spacing between too many peer blocks

- Screen or widget: `statistics_content_view`
- Actual values found:
  - top padding `24`
  - bottom padding `48`
  - `Gap.section()` repeated `5` times
  - peer sections are all card-like blocks with similar visual weight
- Recommended range: `32` is strong for hero-to-section breaks; peer content sections usually read cleaner in the `20-24` range
- What is wrong: equal-weight sections are spaced like major narrative chapters
- Why it weakens the UI: the screen feels padded and report-like rather than focused and readable
- Classification: poor rhythm, too loose

### 6. Settings rows are effectively `76` high

- Screen or widget: `settings_choice_row`, `settings_action_row`, `settings_stepper_row`, notification rows
- Actual values found:
  - vertical padding `12 + 12`
  - child min height `52`
  - effective minimum height is about `76`
- Recommended range: single-line settings rows generally feel strongest around `56-64`
- What is wrong: the row shell is much taller than the content needs
- Why it weakens the UI: settings becomes bloated before it feels premium
- Classification: too loose, poor ratio

### 7. Search uses medium-style gutters and tall rows on compact layouts

- Screen or widget: `search_screen`, `search_result_list`, `search_result_tile`, `app_list_tile`
- Actual values found:
  - screen disables shell padding
  - root search-bar padding is `24`
  - result-list horizontal padding is `24`
  - result rows use the `72` two-line path
- Recommended range:
  - compact search gutters: usually `16-20`
  - simple search hits: usually `56-64`
- What is wrong: compact search is wider and taller than the rest of the app without being more editorial or more informative
- Why it weakens the UI: the screen feels loose and inconsistent
- Classification: too loose, poor rhythm, poor ratio

### 8. Guess answer options are larger and louder than the next action

- Screen or widget: `guess_option_button`, `guess_round_view`
- Actual values found:
  - option min height `72`
  - answer text `20`
  - prefix text `14`
  - action below is a text-link only `8` beneath the answer stack
- Recommended range: short answer options generally read better around `56-64` unless they truly need multi-line breathing room
- What is wrong: the answer surface is visually stronger than the control that moves the flow forward
- Why it weakens the UI: action hierarchy is inverted; the screen feels noisy instead of confident
- Classification: poor ratio, poor hierarchy

### 9. Dialog forms are too vertically generous for compact modals

- Screen or widget: `create_deck_dialog`, `create_folder_dialog`
- Actual values found:
  - input height `52`
  - field gap `20`
  - label-to-control gaps often only `8`
  - multiple `20` jumps are chained in one compact modal
- Recommended range: compact modal field spacing usually feels stronger at `12-16`
- What is wrong: the form rhythm alternates between roomy and tight without hierarchy benefit
- Why it weakens the UI: dialogs grow tall quickly and feel mechanically spaced
- Classification: too loose, poor rhythm

### 10. Dialog CTA pairs use height mismatch as the main hierarchy signal

- Screen or widget: `create_deck_dialog`, `create_folder_dialog`, shared confirm dialogs
- Actual values found:
  - primary button default height `52`
  - secondary button default height `48`
  - both appear side by side in modal actions
- Recommended range: paired modal actions generally feel cleaner at one shared height, with hierarchy expressed by fill and border treatment
- What is wrong: the primary action looks swollen rather than intentionally dominant
- Why it weakens the UI: the CTA system reads inconsistent and slightly accidental
- Classification: poor ratio, poor hierarchy

### 11. Deck browsing cards carry too many responsibilities

- Screen or widget: `deck_tile`, `deck_tile_supporting`, `app_card_list_tile`, `folder_tile`, `folder_deck_tile`
- Actual values found:
  - outer card padding `16`
  - leading gap `16`
  - title-to-subtitle gap `4`
  - supporting block gap `12`
  - cards may contain title, subtitle, due pill, mastery, tags, menu, reorder handle, and highlight state
  - title and description often resolve to `16 / 16`
- Recommended range: browsing rows should usually keep one clear primary row and one lighter support band
- What is wrong: too much information is packed into one shared shell without enough typographic stepping
- Why it weakens the UI: library browsing feels crowded, repetitive, and hard to scan
- Classification: poor grouping, poor hierarchy, too dense

### 12. Statistics tabs occupy `48` height but signal selection weakly

- Screen or widget: `statistics_period_tabs`
- Actual values found:
  - tab height `48`
  - label size `16`
  - selected state uses a `3` high underline
- Recommended range: a `48` control usually needs a stronger selected-state change than a `3` underline if the rest of the surface is quiet
- What is wrong: the control claims touch size but not enough visual authority
- Why it weakens the UI: the filter looks understated and secondary even though it changes the whole dashboard
- Classification: poor hierarchy, poor ratio

## Moderate

### 13. Streak hero mixes too many high-emphasis elements on one line

- Screen or widget: `streak_hero_card`
- Actual values found:
  - main stat `48`
  - icon at default hero-adjacent scale
  - label `24`
  - only `12` below before secondary wrap content
- Recommended range: hero stats usually read strongest when the main number is isolated more clearly from label and decoration
- What is wrong: the hero number shares space with another strong text tier and an accent icon
- Why it weakens the UI: the hero feels busy instead of commanding
- Classification: poor ratio, poor hierarchy

### 14. Study top bar spends too much width on side slots

- Screen or widget: `study_top_bar`, `top_bar_icon_button`
- Actual values found:
  - left slot `96`
  - right slot `96`
  - title and progress count share the center of a `56` bar
- Recommended range: compact top bars should minimize slot reservation unless the sides carry equally important controls
- What is wrong: the title area is squeezed even though the central information is more important than the side affordances
- Why it weakens the UI: the top bar feels overframed and underfocused
- Classification: poor ratio

### 15. Settings section rhythm is too uniform once row height is already oversized

- Screen or widget: `settings_content_view`, `settings_group_card`
- Actual values found:
  - top padding `24`
  - section gap `32`
  - group cards remove internal padding and insert dividers between every row
- Recommended range: once rows exceed `64`, section gaps usually read better closer to `24`
- What is wrong: oversized rows plus large section gaps produce a bureaucratic pace
- Why it weakens the UI: the screen feels systematic but visually heavy
- Classification: poor rhythm, too loose

### 16. Shared sheets use inconsistent title hierarchy

- Screen or widget: `choice_bottom_sheet`, `study_mode_sheet`
- Actual values found:
  - generic choice-sheet title `16`
  - study-mode sheet title `24`
  - both use similar outer padding and list primitives
- Recommended range: shared sheet families should have a consistent header rule, especially when row titles remain `16`
- What is wrong: similar sheet patterns do not follow one clear title scale
- Why it weakens the UI: the modal system feels ungoverned
- Classification: poor hierarchy

### 17. Home screen rhythm overstates a weak transition

- Screen or widget: `home_screen`, `home_greeting_card`
- Actual values found:
  - greeting card
  - full `32` break
  - then a `12` uppercase section label with `12` below
- Recommended range: after a lightweight greeting card, the transition to the main list usually reads stronger in the `16-24` range unless a true hero is present
- What is wrong: a big gap lands before a weak label, not before a strong content change
- Why it weakens the UI: the page feels padded rather than composed
- Classification: poor rhythm, poor hierarchy

## Current UI Value Patterns Found in the App

| Pattern | Current values found | Where it appears | Read |
| --- | --- | --- | --- |
| Compact shell gutter | `16` | app shell default | Strong baseline |
| Manual compact gutters | `24` | study screens, search | Main cross-screen inconsistency |
| Major section spacing | `32` | statistics, settings, home | Overused between peer blocks |
| Form field gap | `20` | create folder, create deck, study form stacks | Too loose for compact modals |
| Primary button height | `52` | shared | Fine individually |
| Secondary button height | `48` | shared | Fine individually, weak when paired against `52` |
| Text field height | `52` | shared | Strong baseline |
| Search bar height | `48` | shared | Strong baseline |
| One-line row height | `56` | shared list rows | Strong baseline |
| Two-line row height | `72` | shared list rows and search results | Often too tall for simple content |
| Settings row effective height | about `76` | settings rows | Bloated |
| Deck toolbar height | `104` | deck detail | Oversized |
| Study top-bar side slot | `96` each side | study top bar | Too expensive on compact |
| Typography buckets used most | `16`, `24` | app-wide | Main hierarchy flattening point |
| Common flattened text pair | `16 / 16` | deck cards, some action cards | Visually flat |

## Proportion Issues That Most Damage Perceived Quality

- The app uses two different compact gutter systems at once: shell `16` and manual `24`.
- Large `32` section spacing is applied too often between peer blocks, not only between major layout bands.
- Shared typography roles collapse into the same `16` and `24` buckets, flattening hierarchy.
- Deck detail spends far too much vertical space on summary chrome before showing actual content.
- Settings rows are oversized for their information density.
- Search rows are too tall for simple result content.
- Dialog action hierarchy relies on height mismatch instead of clean visual priority.
- Study answer surfaces are larger and louder than the next-step CTA.
- Shared cards often try to be header, metadata host, progress surface, and action surface at the same time.
- Top bars and breadcrumb affordances consume more compact-space budget than their informational importance justifies.

## Sizing and Spacing Rules to Normalize First

1. Normalize compact horizontal padding.
   - Pick one default for compact content screens, ideally `16-20`.
   - Stop mixing shell `16` with local `24` in study and search.

2. Normalize section spacing.
   - Reserve `32` for hero-to-section transitions.
   - Use `20-24` for peer content sections.

3. Normalize title/support text stepping inside components.
   - Avoid `16 / 16` title-body pairs.
   - Make shared component rules prefer at least one bucket of separation.

4. Normalize modal form spacing.
   - Reduce compact form field gaps from `20` toward `12-16`.
   - Keep label-to-control gaps consistent.

5. Normalize paired CTA heights.
   - Dialog action pairs should share one height.
   - Hierarchy should come from fill, border, and placement, not from `52` vs `48`.

6. Normalize oversized compact rows.
   - Bring settings single-line rows down toward `56-64`.
   - Reduce simple result rows from `72` toward `56-64`.

7. Normalize compact utility bands.
   - Cap pinned toolbars and breadcrumb/header affordances so they do not dominate the first viewport.

## Future Guard Opportunities

These are realistic, automatable guard ideas based on repeated issues in the codebase.

### Spacing discipline

- Flag feature screens that set `applyHorizontalPadding: false` and also add root-level `24` horizontal padding on compact layouts.
- Flag repeated sibling use of `sectionGap` or `Gap.section()` when the children are peer `AppCard`-like blocks.
- Flag compact dialogs that chain `fieldGap` three or more times in one form.

### Component height consistency

- Compute effective row height when a wrapper adds vertical padding around a child that already enforces `minHeight`.
- Flag text-only controls with `minHeight >= 72`.
- Flag side-by-side dialog action sets that mix default `PrimaryButton` and `SecondaryButton` heights.
- Flag compact pinned toolbars whose computed height exceeds a threshold such as `72-88`.

### Typography hierarchy discipline

- Flag components where the primary title and supporting body resolve to the same font-size bucket.
- Flag sheets or dialogs whose header title size is less than or equal to option-row title size.
- Flag completion or stats surfaces where multiple prominent text elements use the same strongest style token.

### Icon-to-text ratio checks

- Flag row or navigation contexts where `Icon` size is implicit while adjacent text is `14-16`.
- Flag related list-row components for the same entity type when their leading icon/container grammars diverge materially.

## Final Assessment

MemoX’s visual weakness is not coming from missing tokens or a missing theme system. It is coming from:

- inconsistent compact padding usage
- overuse of large spacing bands
- flattened text-role mapping
- oversized compact rows and utility bands
- overloaded card shells
- weak CTA differentiation
- loud state color treatment in study flows

The safest high-impact path is not screen-by-screen patching. It is to normalize a small set of shared spacing, height, and typography rules first, then redesign a few representative screens that currently amplify those proportional problems.
