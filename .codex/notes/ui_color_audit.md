# MemoX UI Color Audit

Date: 2026-04-07  
Method: Read-only code audit using the MemoX `ui-heavy` multi-agent workflow

## Scope and Diagnostic Framing

MemoX already has color tokens, theme foundations, and shared widgets. The main question is not whether a palette exists. The question is whether the current UI still looks immature because color is mapped and used poorly.

This audit focuses on:

- accent color discipline
- surface layering
- text contrast hierarchy
- status color usage
- component-level color misuse

This report is based on code inspection of actual theme files, shared widgets, and feature widgets. I could verify token values, theme mapping, and concrete color behavior. I could not verify live contrast perception, device rendering, or runtime screenshots in this pass.

## System-Level Diagnosis

MemoX has a broad semantic palette:

- primary seed is indigo: `#5C6BC0`
- success and mastery lean teal/green
- warning and hard states lean amber
- error and again states lean rose

The palette itself is usable, but the app is not exercising enough restraint.

Two systemic issues are driving the color problems:

1. Neutral surface separation is weak.
   - `lightSurface = #FAFAFA`
   - `surfaceDimLight = #F5F5F5`
   - card background defaults to `surface`
   - scaffold background also uses `surface`
   - `surfaceTint` is disabled
   - shadow is effectively disabled
   - outline is only `8%` alpha

2. Accent and status colors are often promoted from indicators into containers, borders, text, and icons at the same time.

That combination creates a UI that is both flat and noisy:

- flat because most neutral surfaces barely separate
- noisy because saturated colors are spent too freely on local state and small components

## Grouped Findings

## Overuse of Accent

### 1. Primary color is used on too many minor “selected” or “active” states

- Screen or widget: `statistics_period_tabs`, `settings_appearance_section`, `selectable_card`, `reorder_mode_banner`, `deck_tile`, `folder_deck_tile`, `navigationBarTheme`
- What color behavior is wrong:
  - selected tabs use primary text plus primary underline
  - selected theme cards use primary border plus primary-tinted background
  - selectable cards use primary border plus primary-tinted fill
  - reorder banner uses primary border and primary icon
  - deck and folder deck highlights use primary borders or left stripes
  - selected bottom-nav icons use primary
- Why it hurts perceived quality: primary loses editorial importance when it is applied to too many small local states. Instead of one clear brand accent, the app becomes dotted with blue highlights everywhere.
- What should change:
  - more neutral: passive selected cards, hint banners, and low-stakes highlights
  - more subtle: minor filter and selection treatments
  - more prominent: keep primary for navigation current state, one dominant CTA, and one focal stat per screen

### 2. Statistics mixes multiple saturated accents in the same viewport

- Screen or widget: `streak_hero_card`, `mastery_donut_chart_section`, `weekly_bar_chart_section`
- What color behavior is wrong:
  - streak hero combines primary for the main number with mastery color for the fire icon on a tinted container
  - mastery donut uses saturated mastery-high teal, mastery-mid amber, and neutral variant in one compact data block
  - weekly chart highlights “today” in primary while other statistics surfaces already use primary elsewhere
- Why it hurts perceived quality: the dashboard feels color-busy rather than composed. There is no single accent anchor.
- What should change:
  - more neutral: surrounding hero/support surfaces
  - more subtle: secondary chart accents and supporting icons
  - more prominent: one primary focal data point at a time

### 3. Text-link actions default to accent color too often

- Screen or widget: `text_link_button`, `inline_text_link_button`, repeated in deck detail, difficult cards, fill feedback, greeting cards, and breadcrumbs
- What color behavior is wrong: text links default to primary or switch to primary on active/hover states, even when the action is secondary or informational.
- Why it hurts perceived quality: too many blue inline actions compete with true primary actions and create a scattered accent field.
- What should change:
  - more neutral: secondary inline actions, breadcrumbs, tertiary choices
  - more prominent: only the most important inline action on a surface

## Poor Surface Layering

### 4. Screen background and card surfaces are too close in tone

- Screen or widget: `app_theme`, `app_card`
- What color behavior is wrong:
  - scaffold background uses `surface`
  - cards also default to `surface`
  - `surfaceTint` is transparent
  - shadow is transparent
  - borders rely on `outline` at only `8%` alpha
- Why it hurts perceived quality: content containers do not clearly separate from the page canvas. The app looks flat, washed out, and slightly cheap.
- What should change:
  - more prominent: neutral separation between page background, cards, sheets, and utility surfaces
  - more subtle: outlines should support layering, not be the only layer signal

### 5. Many container variants are used inconsistently, not by clear depth role

- Screen or widget: `info_bar`, `mode_chip`, `app_switch_tile`, `streak_hero_card`, `mastery_bar`, `mastery_ring`
- What color behavior is wrong:
  - `surfaceContainerHighest` appears in info bars, chip emoji bubbles, progress tracks, and hero cards
  - `surfaceDim` is used for inputs and switch cards
  - `surfaceContainerLow` appears in reorder banners
- Why it hurts perceived quality: neutral container tiers do not map to a stable meaning like “background,” “supporting surface,” or “elevated utility surface.”
- What should change:
  - more neutral: establish one clear role for each surface container tier
  - more subtle: avoid using the same container color for unrelated semantics

### 6. Settings grouping depends on very faint dividers instead of clear container contrast

- Screen or widget: `settings_group_card`, `settings_content_view`, `app_switch_tile`
- What color behavior is wrong:
  - settings groups remove card padding
  - internal dividers use only `6%` alpha
  - switch cards use `surfaceDim` plus a subtle border
- Why it hurts perceived quality: the screen looks bureaucratic and flat at the same time. Groups are visible structurally but not visually persuasive.
- What should change:
  - more prominent: container contrast between group surface and page surface
  - more subtle: dividers should support grouping, not carry grouping by themselves

## Weak Contrast Hierarchy

### 7. `onSurfaceVariant` is doing too much work

- Screen or widget: `settings_section_header`, `breadcrumb_bar`, `empty_state_view`, `deck_tile`, `folder_tile`, `app_switch_tile`, `app_list_tile`, shared navigation and metadata surfaces
- What color behavior is wrong: the same muted variant tone is used for subtitles, metadata, breadcrumbs, section headers, icons, helper copy, and some data-adjacent labels.
- Why it hurts perceived quality: the secondary hierarchy compresses into one muddy middle layer. Some content becomes too faint, while other “secondary” content is still too close to body text.
- What should change:
  - more neutral: true metadata and helper text
  - more prominent: section headers and current breadcrumb states when they organize navigation
  - more subtle: low-value icons and passive metadata

### 8. Labels and values sometimes share the same color emphasis

- Screen or widget: `session_complete_view`, `difficult_cards_section`
- What color behavior is wrong:
  - session stat labels inherit `stat.valueColor` when present
  - difficult-card accuracy can turn strong red while surrounding content remains neutral
- Why it hurts perceived quality: labels stop behaving like structure and start competing with the values they should support.
- What should change:
  - more neutral: labels and supporting descriptions
  - more prominent: the actual metric or result value

### 9. Status chips color both the indicator and the text

- Screen or widget: `status_chip`
- What color behavior is wrong: the status dot is colored, and the chip text is also colored with the same status hue inside a bordered neutral shell.
- Why it hurts perceived quality: metadata becomes louder than it should be, especially when several chips appear together.
- What should change:
  - more neutral: chip text
  - more prominent: keep the dot as the main status signal

## Status Color Noise

### 10. Guess options use full success and warning surfaces, not just status cues

- Screen or widget: `guess_option_button`
- What color behavior is wrong:
  - correct answers get full success fill, success border, white text, and a success icon
  - wrong selections get full warning fill, warning border, white text, and a warning icon
  - selected-but-unanswered uses `primaryContainer`
- Why it hurts perceived quality: status treatment dominates the whole control. The component feels loud and game-like instead of precise.
- What should change:
  - more neutral: answer containers
  - more subtle: borders and secondary icon signals
  - more prominent: reserve full-color emphasis for the one final state that truly matters

### 11. Review rating buttons spend four saturated colors on one decision cluster

- Screen or widget: `review_rating_button`
- What color behavior is wrong: each rating button uses its own accent color as border and tinted background, and preview text is also colored to match.
- Why it hurts perceived quality: the control cluster becomes a wall of colored micro-cards instead of one calm decision area.
- What should change:
  - more neutral: the button containers
  - more subtle: preview text
  - more prominent: keep color mostly in a small indicator, selected state, or one text role

### 12. Fill mode spreads rating colors across too many surfaces at once

- Screen or widget: `fill_answer_input`, `fill_feedback_panel`, `fill_diff_text`, `fill_submit_button`
- What color behavior is wrong:
  - input border changes to rating colors
  - correct icon uses rating color
  - feedback cards add colored left borders
  - accept/reject links become green and red
  - diff text uses green/red emphasis
- Why it hurts perceived quality: one study state can show several colored cues at once. The screen becomes visually noisy.
- What should change:
  - more neutral: input shell and feedback container
  - more subtle: left-border and inline text emphasis
  - more prominent: one single success/error signal per feedback block

### 13. Destructive feedback often uses “ratingAgain” instead of the error role

- Screen or widget: `toast`, `app_edit_delete_menu`, `app_slidable_row`, `error_view`
- What color behavior is wrong:
  - error toast background uses `customColors.ratingAgain`
  - delete menu item uses `ratingAgain`
  - swipe-to-delete background uses `ratingAgain`
  - error view icon uses `ratingAgain`
- Why it hurts perceived quality: a study-specific rating color is leaking into global destructive/error semantics. That weakens role clarity and makes the palette feel improvised.
- What should change:
  - more neutral: non-destructive shared feedback surfaces
  - more subtle: use error accent where needed without borrowing study-rating language
  - more prominent: destructive semantics should consistently map to the error role

## Component-Level Color Misuse

### 14. Streak hero uses double-accent emphasis on one line

- Screen or widget: `streak_hero_card`
- What color behavior is wrong: the main number is primary, the fire icon is mastery-colored, and the container is already a raised neutral variant.
- Why it hurts perceived quality: the hero uses multiple accent signals for one idea, which makes it feel noisy rather than premium.
- What should change:
  - more neutral: either the hero icon or the hero stat
  - more prominent: choose one focal accent only

### 15. Statistics tabs are too weak, while other components are too loud

- Screen or widget: `statistics_period_tabs`
- What color behavior is wrong: selected state relies on primary text and a thin primary underline, while surrounding screens already spend primary more aggressively elsewhere.
- Why it hurts perceived quality: the color system feels inconsistent. Some controls shout; this one whispers.
- What should change:
  - more neutral: inactive tab treatment can stay muted
  - more prominent: selected state needs a stronger but still controlled emphasis, such as a subtle pill/container shift

### 16. Due counts are colored like warnings even when they are just metadata

- Screen or widget: `deck_tile_due_pill`
- What color behavior is wrong: due counts use `ratingHard` amber as both text color and tinted fill.
- Why it hurts perceived quality: “due” is treated like “warning” by default, so list rows carry unnecessary urgency.
- What should change:
  - more neutral: standard due-count presentation
  - more prominent: only escalate into warning color when the state is genuinely urgent

### 17. Reorder mode banner is styled like an active callout

- Screen or widget: `reorder_mode_banner`
- What color behavior is wrong: passive instructional content gets a tinted container, primary border, and primary icon.
- Why it hurts perceived quality: the banner competes with real actions instead of behaving like subdued guidance.
- What should change:
  - more neutral: banner icon and border
  - more subtle: treat reorder mode as utility state, not as a feature highlight

## Top Color Problems Harming the App’s Visual Maturity

1. Neutral surface separation is too weak because scaffold, card, and many containers sit too close to the same `surface` tier.
2. Primary is overused for minor selection, utility, and highlight states, not just for major emphasis.
3. Study flows spend too many saturated status colors at once on fills, borders, text, and icons.
4. Status and destructive semantics are not cleanly separated from study-rating colors.
5. Secondary contrast hierarchy is muddy because `onSurfaceVariant` is reused too broadly.
6. Several components are color-loud while others are color-timid, so the app lacks a consistent emphasis ladder.
7. Shared widgets often rely on accent color to create interest because neutral layering is too weak.

## Color Decisions That Should Be Normalized App-Wide First

1. Normalize neutral surface hierarchy.
   - Separate page background, card surfaces, input surfaces, utility surfaces, and sheets more clearly.
   - Stop relying on `surface` plus a faint outline as the default for everything.

2. Normalize primary-color policy.
   - Reserve primary for current navigation state, the dominant CTA, and one focal highlight per screen.
   - Remove primary from passive banners, low-stakes selection cards, and minor utility states where possible.

3. Normalize status-color policy.
   - Status colors should begin as indicators, not as full containers.
   - Avoid using the same status color on fill, border, text, and icon simultaneously unless that component is explicitly designed as a strong alert state.

4. Normalize destructive mapping.
   - Destructive and error semantics should use the error role consistently.
   - Study rating colors should stay inside study semantics.

5. Normalize secondary contrast hierarchy.
   - Rebalance how `onSurface`, `onSurfaceVariant`, helper text, metadata, and section headers are mapped so they form a clearer ladder.

## Shared Widgets Most in Need of Color Behavior Redesign

- `AppCard`
  - Current issue: too little neutral separation from the page canvas, so many features resort to accent borders and stripes for emphasis.

- `TextLinkButton` and `InlineTextLinkButton`
  - Current issue: default accent behavior makes too many tertiary actions blue.

- `StatusChip`
  - Current issue: chip text is as colorful as the status indicator.

- `Toast`
  - Current issue: uses fully saturated status backgrounds and maps error to `ratingAgain`.

- `AppEditDeleteMenu` and `AppSlidableRow`
  - Current issue: destructive color behavior uses study-rating red instead of the shared error role.

- `ModeChip` and `SelectableCard`
  - Current issue: selected-state treatment leans too quickly into primary-tinted surfaces and borders.

## Future Automatable Guard Ideas

These are realistic proposals tied to repeated issues in the codebase. No guard is implemented in this pass.

### Excessive accent usage

- Flag components that apply `primary` to both container/background and border in the same state, especially when the same component also colors text or icon with primary.
- Flag screens/components that use primary-colored icons, borders, and highlighted containers together in one small surface.

### Contrast policy violations

- Flag shared components whose background defaults to `surface` while their border uses only a very low-alpha outline and there is no stronger surface tier applied.
- Flag components where label and value are both explicitly colored with the same semantic color variable.
- Flag uses of `onSurfaceVariant` for section headers or structurally important labels when no stronger nearby contrast tier exists.

### Status color overuse

- Flag full-container usage of `success`, `warning`, `ratingAgain`, `ratingHard`, `ratingGood`, or `ratingEasy` outside a short approved list.
- Flag components that simultaneously apply the same status color to fill, border, text, and icon.

### Invalid color-role mapping

- Flag destructive actions or error states that use `ratingAgain` instead of `colorScheme.error` or a dedicated destructive role.
- Flag warning-style colors used for neutral metadata patterns such as routine due counts unless an urgency threshold is present.

## Final Assessment

MemoX’s color system is not missing tokens. It is missing restraint and clearer hierarchy.

The biggest app-wide color problems are:

- flat neutral surfaces
- over-spent primary accent
- study-specific status colors leaking into global semantics
- weak separation between secondary text roles
- color being used as a substitute for hierarchy instead of supporting it

The safest high-impact path is to redesign shared color behavior first, especially in `AppCard`, text-link actions, status feedback, destructive actions, and selected-state components. After that, the feature screens that are currently color-noisy will become much easier to rebalance without inventing a parallel design system.
