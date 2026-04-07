# MemoX Shared Widget Audit

## Scope

- Read-only audit.
- Feature-side scope: `lib/features/**/presentation/**`.
- Shared-layer references: `lib/shared/widgets/**`.
- Numeric defaults cited only when they are enforced by shared widgets through token-backed constraints.
- This audit assumes MemoX already has tokens, theme foundations, and a shared widget layer; the review is about weak shared-widget design, weak variant strategy, and poor usage patterns on top of those foundations.

## Executive Summary

MemoX does not have a missing shared-widget problem. It has a shared-widget shape problem.

The biggest quality loss comes from:

1. `AppCard` and `AppCardListTile` being broad enough to absorb too many unrelated jobs.
2. `AppPressable` acting as a generic interaction substrate for rows, inline links, tabs, and pseudo-buttons, which makes density and hierarchy drift.
3. `TextLinkButton`, `InlineTextLinkButton`, `ChoiceBottomSheet`, and `AppDialog` being too generic to enforce strong visual roles.
4. Feature screens stretching shared widgets past their intended use instead of using narrower variants.

The result is not missing consistency. It is visually repetitive consistency with weak hierarchy.

## Shared Widget Design Problems

| Widget | How it is currently used | Why the current design hurts UI quality | Redesign type needed |
| --- | --- | --- | --- |
| `AppCard` | Used as the default surface in `home_greeting_card.dart`, `deck_detail_overview.dart`, `deck_stats_grid.dart`, `settings_group_card.dart`, `settings_database_card.dart`, `difficult_cards_section.dart`, `streak_hero_card.dart`, `fill_feedback_panel.dart`, `guess_question_card.dart`, `review_card_face.dart`, and `review_rating_button.dart`. The shared API allows `backgroundColor`, `borderColor`, `borderRadius`, and `leftBorderColor`. | One shell is carrying hero cards, banners, stat cards, settings groups, prompts, feedback panels, and list rows. Reuse is high, but the visual grammar is too uniform, so screens look repetitive and low-resolution. The optional accent stripe and border overrides also encourage ad hoc emphasis instead of semantic surface tiers. | Smaller scope; decomposition into more focused widgets; stricter API |
| `AppCardListTile` | Used by `folder_tile.dart` and `deck_tile.dart` as a ready-made card row with `leading`, `title`, `subtitle`, `trailing`, and optional `supporting`. It always wraps itself in `AppCard`. | This widget combines row layout and card surface ownership. That makes it too rigid for simple card rows and too weak for richer entity cards. `DeckTile` stretches it with due pills, edit menu, reorder handle, and a full supporting metrics block; `FolderTile` uses a different trailing grammar; `FolderDeckTile` bypasses it entirely and rebuilds a raw `AppCard` row. | Smaller scope; stricter API; decomposition into more focused widgets |
| `TextLinkButton` | Used as a tertiary action in `home_greeting_card.dart`, `deck_detail_overview.dart`, `difficult_cards_section.dart`, `guess_round_view.dart`, `fill_feedback_panel.dart`, `fill_prompt_card.dart`, `card_editor_view.dart`, and as the secondary action in `session_complete_view.dart`. It defaults to primary-colored text and composes `AppPressable`. | One interaction pattern is standing in for inline toggles, tertiary actions, secondary navigation, retry actions, and soft confirmation choices. Because it inherits `AppPressable`, it also carries a `48dp` minimum touch target even when the visual role is tiny. The result is repeated accent links with weak action hierarchy. | New variant; stricter API; different visual hierarchy |
| `InlineTextLinkButton` | Used by `BreadcrumbBar` for breadcrumb segments. It enforces `SizeTokens.touchTarget` (`48dp`) even when not interactive. | Breadcrumbs are semantically inline navigation, but this primitive behaves like a full-height control. That makes breadcrumb lines visually bulkier than their role. | New variant; smaller scope; different default spacing |
| `TopBarIconButton` | Used across `home_screen.dart`, `folder_detail_screen.dart`, `deck_detail_header.dart`, and `study_top_bar.dart`. The default button is `48x48`, and `balancedSlotWidth` is `96dp`. | The widget is technically reusable, but its slot model is expensive. Once it is combined with `TopBarActionRow`, `TopBarBackButton`, or `StudyTopBar`, header chrome consumes too much width and pushes content toward a cramped center. | Stricter API; new variant; different default spacing |
| `SessionCompleteView` | Reused by `review_mode_screen.dart`, `guess_mode_screen.dart`, `match_mode_screen.dart`, `recall_mode_screen.dart`, and `fill_mode_screen.dart`. It always renders the same success indicator, title, stats list, primary button, and optional secondary text link. | This is a single completion grammar for five different study modes. It keeps business logic clean, but visually it makes all session endings feel the same and equally loud. The widget is too opinionated in structure and too unopinionated in hierarchy. | New variant; decomposition into more focused widgets; different visual hierarchy |
| `ChoiceBottomSheet` | Used by `folder_type_chooser_sheet.dart`, settings choice flows, and `statistics_practice_action.dart`. It always renders a handle, `titleMedium` title, and a list of `AppListTile` options. | This is not flexible enough to cover richer selection contexts, but still generic enough to be used for them. The strongest evidence is `study_mode_sheet.dart`, which bypasses it entirely and rolls its own stronger title and richer leading visuals. | New variant; smaller scope; different visual hierarchy |

## Shared Widget API Problems

| Widget | How it is currently used | Why the current API hurts UI quality | Redesign type needed |
| --- | --- | --- | --- |
| `AppPressable` | Used directly by `settings_choice_row.dart`, `settings_action_row.dart`, `_SettingsSwitchRow` in `settings_notifications_section.dart`, `statistics_period_tabs.dart`, `fill_submit_button.dart`, and indirectly through `TextLinkButton` and `ExpandableTile`. Its default constraint is `SizeTokens.touchTarget` (`48dp`), and it allows arbitrary `padding`, `constraints`, `color`, and radius overrides. | The API is too broad. It can represent a row, a pill, an inline action, a tab, or a pseudo-button, so feature code keeps inventing new layouts on top of it. The minimum touch target is good for accessibility, but once outer padding or an already-sized child is added, the effective height balloons. | Stricter API; smaller scope |
| `AppDialog` | Used by `create_deck_dialog.dart`, `create_folder_dialog.dart`, and delete/confirm flows. The shared contract is only `title`, `content`, and `actions`. | The API is too thin to enforce dialog rhythm. Feature screens hand-build form spacing, section labels, and CTA pairs inside the dialog shell, which is why create/edit dialogs drift into tall, mechanically assembled layouts. | New variant; stricter API; different default spacing |
| `AppListTile` | Used by `search_result_tile.dart`, `backup_list_sheet.dart`, `difficult_cards_section.dart`, `study_mode_sheet.dart`, and theme preview samples. The shared contract only allows string `title` and `subtitle`, and it flips between `56dp` and `72dp` min heights based on subtitle presence. | This API is good for plain menu rows, but weak for nuanced hierarchy. It is too narrow to support richer title blocks and too tall when screens use it for simple results or sheet options. That makes it easy to apply in the wrong contexts because it always “works,” even when the visual density is wrong. | New variant; smaller scope; stricter API |
| `AppTextField` | Used by `card_editor_view.dart`, `create_deck_dialog.dart`, and `create_folder_dialog.dart`. The shared API exposes border, fill, padding, prefix/suffix, and decoration-level overrides. | The control is centralized, but the API is permissive enough to encourage local styling drift in the future. It is a utility wrapper, not a strongly bounded visual component. | Stricter API |
| `PrimaryButton` and `SecondaryButton` | Paired side by side in `create_deck_dialog.dart` and `create_folder_dialog.dart`. `PrimaryButton` defaults to `52dp`; `SecondaryButton` defaults to `48dp`. | The shared API makes single-button usage easy, but there is no contract for paired CTAs. In modals, the mismatch makes the primary button look swollen rather than intentionally dominant. | Stricter API; new variant |
| `AppSwitchTile` and `AppCardSwitchTile` | Used in `card_editor_view.dart` and settings sections. `AppSwitchTile` already enforces `SizeTokens.listItemCompact` (`52dp`), while `AppCardSwitchTile` adds `AppCard` plus extra padding. | The base widget is reasonable, but the API split is incomplete. Feature code still wraps the base switch tile in additional pressables and padding, so the shared contract is not strong enough to prevent bloated rows. | Stricter API; different default spacing |

## Shared Widget Usage Problems

| Widget | How it is currently used | Why the current usage hurts UI quality | Redesign type needed |
| --- | --- | --- | --- |
| `AppCardListTile` | `DeckTile` in `deck_tile.dart` uses it for a dense entity card with due pill, edit/delete menu, reorder handle, and `DeckTileSupporting` metrics. | The widget is being stretched beyond a simple card-row job. It now carries too much information and too many affordances inside one fixed layout. | New variant; decomposition into more focused widgets |
| `AppCard` | `FolderDeckTile` in `folder_deck_tile.dart` bypasses the shared deck-card row pattern and hand-builds its own row directly inside `AppCard`. | The app now has two deck row grammars: `DeckTile` based on `AppCardListTile` and `FolderDeckTile` based on raw `AppCard`. Both are valid, but together they weaken consistency across folders and decks. | Smaller scope; decomposition into more focused widgets |
| `AppListTile` | `SearchResultTile` in `search_result_tile.dart` uses `AppListTile` for folder, deck, and card hits, always with subtitle-driven tall rows. | Search results are simpler and more scan-dependent than menu rows. Reusing the generic list tile inflates every result to the `72dp` two-line pattern and flattens result hierarchy. | New variant; different default spacing |
| `AppPressable` + `AppSwitchTile` | `_SettingsSwitchRow` in `settings_notifications_section.dart` wraps `AppSwitchTile` inside `AppPressable` with `16dp` horizontal and `12dp` vertical padding. `SettingsChoiceRow` and `SettingsActionRow` apply the same pattern around a `52dp` min-height child. | The pressable wrapper is adding density on top of a child that already owns density. This compounds into bloated settings rows and divider-heavy stacks. | Stricter API; different default spacing |
| `TextLinkButton` | `GuessRoundView` uses it for skip/continue, `FillFeedbackPanel` uses two colored text links for accept/reject, `HomeGreetingCard` uses it for “Review now,” and `DeckDetailOverview` uses it for “Choose study mode.” | The same tertiary action widget is being used for navigation, quiet continuation, retry, and split decision controls. That makes action hierarchy inconsistent across study, home, and deck flows. | New variant; stricter API |
| `ChoiceBottomSheet` | `FolderTypeChooserSheet` and statistics practice flows use `ChoiceBottomSheet`, but `StudyModeSheet` bypasses it and hand-builds a stronger sheet with `titleLarge`, emoji bubbles, and chevrons. | This is a direct signal that the shared sheet is being used for some jobs and abandoned for others because it is too weak. The current usage pattern fractures modal consistency. | New variant; different visual hierarchy |
| `SessionCompleteView` | All study modes reuse the same completion shell, while mode-specific screen files inject different stats and optional extra copy. | The shared shell keeps implementation simple, but visually it over-normalizes distinct completion experiences. Review completion is the clearest example because mode-specific colored stats and extra summary text are still forced into one generic stack. | New variant; decomposition into more focused widgets |
| `AppListTile` + `ExpandableTile` + `AppCard` | `DifficultCardsSection` uses an `AppCard` containing `ExpandableTile`, then renders a list of `AppListTile`s plus a `TextLinkButton`. `CardListTile` does something similar for cards. | Multiple generic shared widgets are being nested to fabricate richer structures. This compounds spacing, chevrons, dividers, and card shells into layouts that feel assembled rather than designed. | Decomposition into more focused widgets |
| `TopBarIconButton` | `StudyTopBar` reserves `96dp` on both sides using `TopBarIconButton.balancedSlotWidth`; `HomeScreen` and `FolderDetailScreen` stack multiple icon buttons inside `TopBarActionRow`. | The shared header control is being used as if every action needs the same generous slot contract. On compact widths, that makes the header feel action-heavy and pushes content into a narrow middle band. | Stricter API; new variant |

## Missing Variant Problems

| Widget family | Current evidence | Why the missing variant hurts UI quality | Redesign type needed |
| --- | --- | --- | --- |
| Card surfaces | `AppCard` is used for heroes, stat tiles, settings groups, banners, prompts, and feedback panels. | One base card shell is doing too much semantic work. Shared usage stays consistent but visually monotone. | New variant; decomposition into more focused widgets |
| Card rows vs flat rows | `AppCardListTile` is the only card-row primitive, while `AppListTile` is the flat-row primitive. `FolderDeckTile` hand-rolls its own third pattern. | The app needs a clear middle layer between “simple menu row” and “rich entity card.” Without it, screens either overload `AppCardListTile` or rebuild card rows from scratch. | New variant |
| Tertiary actions | `TextLinkButton` and `InlineTextLinkButton` are covering quiet CTA, inline link, breadcrumb, and navigation-arrow jobs. | Different semantic action roles collapse into one accent-text pattern. | New variant; stricter API |
| Modal selection sheets | `ChoiceBottomSheet` is used for simple choices, but `StudyModeSheet` bypasses it because it needs stronger hierarchy and richer option visuals. | The modal system has no explicit distinction between action list, simple choice list, and rich selection sheet. | New variant |
| Dialog forms | `AppDialog` is only a shell, so `CreateDeckDialog` and `CreateFolderDialog` manually compose form rhythm and action bars. | The app has centralized dialog chrome but no centralized form-dialog behavior. | New variant; stricter API |
| Header actions | `TopBarIconButton` only exposes slot width and alignment, which is too coarse. | Header actions need compact, balanced, and maybe destructive/emphasized variants instead of one slot model. | New variant |
| Completion patterns | `SessionCompleteView` is reused for every study mode. | Mode-specific end states do not have shared semantic variants, only shared structure. | New variant; decomposition into more focused widgets |
| Search controls | `AppSearchBar` is used as a full-screen search control in `search_screen.dart` and as a toolbar control in `deck_cards_toolbar.dart`. | Search at screen level and search inside a pinned toolbar do not have the same visual job, but they share one primitive. | New variant |

## Top Shared Widgets That Most Hurt Visual Quality

1. `AppCard`
2. `AppCardListTile`
3. `AppPressable`
4. `TextLinkButton`
5. `ChoiceBottomSheet`
6. `AppDialog`
7. `TopBarIconButton`
8. `SessionCompleteView`
9. `AppListTile`
10. `AppSwitchTile` / `AppCardSwitchTile`

## Which Widgets Should Be Redesigned First

1. `AppCard` and `AppCardListTile` together. This is the biggest source of surface monotony and overloaded entity rows.
2. `AppPressable`, `TextLinkButton`, and `InlineTextLinkButton` together. These currently blur the boundary between inline action, tertiary CTA, row pressable, and tab.
3. `AppDialog` and `ChoiceBottomSheet` together. Modal structure is shared, but modal behavior is not.
4. `TopBarIconButton` and `TopBarBackButton`. Header action spacing is too expensive.
5. `SessionCompleteView`. The current universal success stack is visually repetitive across study modes.
6. `AppListTile`. It needs explicit separation between menu rows, sheet choices, and search-result rows.

## Which Widgets Should Gain Explicit Variants

- `AppCard`: hero/stat card, message/banner card, settings group surface, prompt/feedback surface
- `AppCardListTile`: simple entity card row, rich entity card row, reorderable card row
- `TextLinkButton`: quiet tertiary CTA, navigational text action with arrow, panel action
- `InlineTextLinkButton`: true inline link, breadcrumb segment
- `AppDialog`: confirm dialog, destructive confirm dialog, compact form dialog
- `ChoiceBottomSheet`: simple choice list, rich selection sheet, action sheet
- `TopBarIconButton`: compact slot, balanced slot
- `SessionCompleteView`: review-style summary, lightweight done state, practice summary
- `AppSearchBar`: page search, toolbar search
- `AppListTile`: flat settings/menu row, search hit row, sheet option row

## Usage Patterns To Ban Or Discourage

- Do not let shared row primitives self-own their card shell for new work. A row should not decide it is a card by default.
- Do not use `AppCardListTile` once a row needs supporting metrics, badges, menus, reorder handles, and highlight states all at once. That needs a dedicated richer variant.
- Do not build deck or folder entity rows from raw `AppCard` when a shared entity-row primitive exists or should exist.
- Do not use `TextLinkButton` for split decision controls inside feedback panels or confirmation areas.
- Do not use `InlineTextLinkButton` for breadcrumb-like navigation if the visual role is smaller than a `48dp` control.
- Do not wrap a shared row that already enforces a minimum height inside another `AppPressable` with additional vertical padding.
- Do not use `AppListTile` as the default answer for search hits or rich sheet options.
- Do not reach for `TopBarIconButton.balancedSlotWidth` by default. Use it only where preserving centered title geometry is essential.
- Do not bypass shared sheet primitives with ad hoc `showModalBottomSheet` layouts unless the missing variant has been acknowledged and added to the shared layer.

## Realistic Future Guards

- Guard: flag any shared row widget under `lib/shared/widgets/**` that instantiates `AppCard` directly. This enforces the repo rule that rows should not self-own card shells.
- Guard: flag `AppPressable` wrappers whose child subtree already contains `ConstrainedBox(minHeight: SizeTokens.listItemCompact)` or `AppSwitchTile`. This catches duplicated row height ownership.
- Guard: flag side-by-side `PrimaryButton` and `SecondaryButton` usage when both use default heights and `fullWidth: false`. This catches mismatched CTA pairs in dialogs.
- Guard: flag `TextLinkButton` usage inside widgets whose names end with `Card`, `Panel`, or `Banner` when more than one `TextLinkButton` appears in the same immediate action cluster. This is a low-noise proxy for panel action misuse.
- Guard: flag `AppListTile` usage inside `search`, `statistics`, and `backup` presentation paths when the row includes subtitle-only metadata and no explicit variant marker. This would force review of tall generic rows in scan-heavy contexts.
- Guard: flag `TopBarIconButton.balancedSlotWidth` outside an allowlist such as `StudyTopBar` and the shared back-button wrapper.
- Guard: flag direct `showModalBottomSheet` usage in feature presentation files unless the file imports a shared sheet primitive or is explicitly allowlisted. This keeps sheet grammar centralized.

## Verification Limits

- This audit is based on source code and shared-widget contracts.
- It can verify structure, enforced sizing, surface ownership, and repeated usage patterns.
- It cannot fully verify runtime text wrapping, localization expansion, platform-specific switch rendering, or device-specific visual balance without running the app and reviewing screenshots.
