# MemoX UI Execution Progress

## Current phase

Verified locally on `codex/fill-recall-study-layout` after a full re-check of
the 5 study-mode UX checklist. The requested study UX coverage is now complete
on this branch: the remaining work in this continuation was to reconcile notes
with the real code state, lock the last study regressions, and confirm the
final repo-wide verification pass stays green.

## Completed work

- re-checked the full 5-study-mode UX checklist against the live branch state
  instead of relying on older audit notes
- confirmed that the requested review, match, guess, recall, fill, and
  cross-mode items are now covered on this branch, with some items delivered
  through the chosen alternative from the earlier design options
- reconciled the progress and redesign summary markdown files with the actual
  implementation so they no longer report already-shipped study features as
  deferred
- closed the last remaining parity gap against the written study checklist by
  letting answered guess rounds advance on a broad tap target instead of only
  the explicit `Continue` link
- removed the extra utility-surface block around the deck-detail `Cards`
  section by letting `DeckCardsToolbar` inherit the page background instead of
  painting its own darker container shell
- removed the deck-detail `Cards` flag filter from the toolbar contract instead
  of hiding it locally, so the pinned cards toolbar now owns only section
  title, sort, and search
- fixed the vertical handoff between the pinned cards toolbar and the first
  `CardListTile` by removing the toolbar's duplicate bottom padding and letting
  the list-start sliver own the full `SpacingTokens.lg` gap below the search
  bar
- corrected the top-side balance of the deck-detail `Cards` section by reducing
  the standalone spacer above the pinned toolbar; the sticky toolbar still owns
  its own inset, so the section no longer double-counts breathing room above
  the title row
- replaced the old flagged-filter widget test with a spacing contract test
  that measures the first card container against the toolbar search bar, which
  locks the intended section rhythm instead of a removed control
- loaded the MemoX multi-agent workflow preset and repo execution rules
- inspected current worktree state to avoid overlapping or unrelated edits
- started the required progress log for this implementation workflow
- read the required source notes in order:
  - `ui_audit_report.md`
  - `ui_proportion_spacing_typography_audit.md`
  - `ui_color_audit.md`
  - `shared_widget_audit.md`
  - `ui_guard_candidates.md`
  - `ui_redesign_roadmap.md`
- frozen the likely remaining scope around shared compact geometry, browsing
  row cleanup, due/status semantics, and low-noise guard follow-up
- normalized `FolderDeckTile` onto the shared `AppCardListTile` and
  `AppTileGlyph` grammar instead of a raw `AppCard` row
- updated `DeckTile` to consume the narrowed `DeckTileSupporting` contract
- stepped deck supporting description text down from the base reading tier to
  the supporting tier for clearer deck-row hierarchy
- tightened the home screen transition rhythm by reducing the greeting-to-list
  break and tightening the section-label handoff
- normalized feature bottom-sheet entry points onto
  `context.showAppBottomSheet(...)` for:
  - `ChoiceBottomSheet`
  - `StudyModeSheet`
  - `BackupListSheet`
- made `ChoiceBottomSheet` scroll-safe for long option lists instead of
  spreading every option directly into one unconstrained `Column`
- rebuilt `DifficultCardsSection` rows away from nested generic `AppListTile`
  usage and removed the old warning-colored accuracy treatment
- added a `shared_widget_mapping` rule for `folder_deck_tile.dart`
- added a low-noise `balanced_top_bar_slot` guard to keep
  `balancedSlotWidth` limited to the current allowlisted headers
- added a low-noise `feature_bottom_sheet_entrypoint` guard to prevent raw
  `showModalBottomSheet(...)` from returning to feature presentation code
- added a focused widget test for `FolderDeckTile`
- added a focused widget test for long `ChoiceBottomSheet` option lists
- synced `home_screen_test.dart` to the new home section heading copy
- wrapped the `ChoiceBottomSheet` test launch in `unawaited(...)` so the
  analyzer stays clean after the shared bottom-sheet API cleanup
- fixed the pinned deck cards toolbar top inset in
  [deck_cards_toolbar.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar.dart)
  so the title/sort row no longer sticks to the toolbar edge on deck detail
- updated the deck cards toolbar extent formula to match the current compact
  button + search-bar composition instead of the older taller control contract
- added a focused widget test for `DeckCardsToolbar` top spacing and internal
  rhythm
- normalized `AppScaffold` bottom breathing-room precedence so screens with a
  FAB keep the same content baseline contract even when a bottom nav is present
- added a shared `fabContentClearance` contract in
  [app_scaffold.dart](/D:/workspace/memox/lib/shared/widgets/layout/app_scaffold.dart)
  to centralize the FAB-aligned bottom spacing formula
- added a focused `AppScaffold` widget test for the `FAB + bottom nav` case so
  the content baseline stays aligned to the FAB top edge
- re-ran targeted shared-layout, home, and theme-preview widget tests after the
  scaffold change
- re-ran `python tools/guard/run.py --scope all` after the final shared/test
  updates
- re-ran `flutter analyze` after the final shared/test updates
- lifted the pinned cards toolbar onto a stronger neutral surface tier and
  restored section-title hierarchy in
  [deck_cards_toolbar.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar.dart)
- added a pinned-state bottom divider in
  [deck_cards_toolbar_delegate.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar_delegate.dart)
  so the sticky toolbar separates from the card content when overlapping
- strengthened toolbar search contrast in
  [app_search_bar.dart](/D:/workspace/memox/lib/shared/widgets/inputs/app_search_bar.dart)
  by giving the toolbar variant an explicit border contract on top of the
  stronger fill tier
- rebuilt `CardListTile` onto a filled neutral card surface with a clearer
  border and replaced the expanded raw icon buttons with `AppEditDeleteMenu`
- added section spacing before the cards toolbar and increased card-row
  separators in
  [deck_detail_screen.dart](/D:/workspace/memox/lib/features/decks/presentation/screens/deck_detail_screen.dart)
- re-ran targeted deck toolbar, search bar, card tile, and deck detail tests
- re-ran `python tools/guard/run.py --scope features`
- re-ran `flutter analyze`
- re-ran targeted deck toolbar and deck detail widget tests
- normalized Settings inter-section rhythm in
  [settings_content_view.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_content_view.dart)
  by promoting peer-section gaps from `xl` to `sectionGap`
- rebuilt
  [settings_section_header.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_section_header.dart)
  onto the calmer `titleLarge` tier and aligned it to the settings card-content
  grammar instead of the raw group-card edge
- lifted
  [settings_group_card.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_group_card.dart)
  onto a visible neutral surface tier with a clearer outline so grouped settings
  sections stop disappearing into the dark-mode background
- collapsed the Appearance section into one grouped surface in
  [settings_appearance_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_appearance_section.dart)
  and rebalanced the theme-mode chooser into a stable three-column row with
  stronger card contrast
- upgraded settings stepper affordance by making the shared
  [icon_action_button.dart](/D:/workspace/memox/lib/shared/widgets/buttons/icon_action_button.dart)
  use a clearer neutral surface/border contract and by letting
  [settings_stepper_row.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_stepper_row.dart)
  inherit the restored 48dp target
- added focused regression coverage for settings grouping, settings hierarchy,
  and the shared icon-action control in:
  - [settings_section_grouping_test.dart](/D:/workspace/memox/test/features/settings/presentation/widgets/settings_section_grouping_test.dart)
  - [icon_action_button_test.dart](/D:/workspace/memox/test/shared/widgets/buttons/icon_action_button_test.dart)
- ran `dart run build_runner build --delete-conflicting-outputs`
- ran `flutter gen-l10n`
- ran `python tools/guard/run.py --scope all`
- ran `flutter analyze`
- ran `flutter test`
- updated the relevant phase summary notes:
  - `ui_fix_shared_widgets_summary.md`
  - `ui_fix_reference_screens_summary.md`
  - `ui_guards_implemented.md`
  - `ui_full_redesign_fix_pass.md`
- reversed `FillEngine` prompt generation so fill mode now expects the front
  side as the typed answer and uses the back side as the visible clue context
- removed the mixed-direction fallback in `FillEngine` so fill mode no longer
  alternates between “type the question” and “type the answer” depending on the
  example content
- remapped recall prompt/reveal widgets so recall now shows `card.back` during
  the prompt phase and reveals `card.front` as the complete answer
- updated fill domain, provider, and screen regression tests to lock the new
  answer-side contract
- updated recall screen regression tests to lock the corrected prompt/reveal
  mapping
- re-ran the focused fill/recall test suite after the study prompt-direction
  fix
- updated `study_screen_test.dart` so the app-level study screen contract now
  matches the corrected recall prompt side
- ran `python tools/guard/run.py --scope all` after the study prompt fix
- ran `flutter analyze` after the study prompt fix
- ran `flutter test` after the study prompt fix
- synced the study behavior fix into:
  - `ui_fix_reference_screens_summary.md`
  - `ui_full_redesign_fix_pass.md`
- re-verified the current Settings files and confirmed
  `SettingsSectionHeader` already uses `titleLarge` while
  `SettingsContentView` already uses `Gap.section()`, so those two requests did
  not need extra code churn
- changed `ThemeData.highlightColor` to transparent and enabled
  `InkSparkle.splashFactory` in `app_theme.dart` so shared Ink interactions no
  longer show a solid rectangular highlight inside rounded containers
- strengthened `IconActionButton` enabled-state outline opacity so stepper and
  other compact icon actions read as interactive more reliably in dark mode
- added a low-noise `inkwell_highlight_override` guard to prevent direct
  `highlightColor:` overrides from reintroducing rectangular press artifacts in
  shared/theme code
- updated focused theme and shared-button tests to lock the new press-feedback
  contract
- ran focused theme/settings/shared-button tests after the patch
- synced the shared press-feedback fix into:
  - `ui_fix_app_wide_summary.md`
  - `ui_fix_shared_widgets_summary.md`
  - `ui_guards_implemented.md`
  - `ui_full_redesign_fix_pass.md`
- reduced the animated blank-slot height in `FillPromptSentence` from
  `SpacingTokens.xxl` to `SpacingTokens.xl` so the missing-word pulse no longer
  wastes a full touch-target worth of vertical space
- tightened `FillFeedbackPanel` stack rhythm by reducing answer-to-diff dead
  space while keeping the stronger shared-button hierarchy for the accept
  action
- promoted the recall prompt label onto the shared `labelLarge` tier and kept
  the medium-length prompt fallback on the calmer `headlineMedium` bridge tier
- extended recall-mode widget coverage so the prompt label stays sentence case,
  the prompt card remains capped at 40% of a compact surface, and the writing
  field stays meaningfully above the lower edge
- re-ran `dart run build_runner build --delete-conflicting-outputs` on the
  final code state
- re-ran `flutter gen-l10n` on the final code state
- re-ran `python tools/guard/run.py --scope all` on the final code state
- re-ran `flutter analyze` on the final code state and cleared the one
  redundant-argument / unused-import follow-up in `RecallPromptCard`
- re-ran `flutter test` across the full repo on the final code state
- added review-mode rating guidance copy by wiring micro-hints into
  [review_rating_grid.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_grid.dart)
  and
  [review_rating_button.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_button.dart)
  so `Again/Hard/Good/Easy` now explain the intended recall quality without
  changing SRS behavior
- clarified fill-mode close-match decisions in
  [fill_feedback_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_feedback_panel.dart)
  with a consequence explainer and calmer action copy, then relaxed retry
  friction in
  [fill_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/fill_provider.dart)
  so the first retry immediately exposes hints and allows `Skip for now`
- added a dedicated wrong-answer explanation surface for guess mode in
  [guess_feedback_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_feedback_card.dart)
  and inserted it into
  [guess_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_round_view.dart)
  so wrong answers now show the correct term, definition, example, and hint
- exposed an explicit `Continue` affordance after answered guess questions
  while keeping the existing auto-advance logic intact for correct answers
- added recall self-rating guidance in
  [recall_rating_guidance.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_rating_guidance.dart)
  and mounted it from
  [recall_reveal_phase.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_reveal_phase.dart)
  so `Missed/Partial/Got it` now carry clearer criteria during self-assessment
- implemented a safe match-mode usability fix in
  [match_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/match_provider.dart)
  so tapping an already-selected term or definition clears that selection
- updated localized study copy in:
  - [app_en.arb](/D:/workspace/memox/l10n/app_en.arb)
  - [app_vi.arb](/D:/workspace/memox/l10n/app_vi.arb)
  - [app_ko.arb](/D:/workspace/memox/l10n/app_ko.arb)
- extended focused study regression coverage for:
  - review rating guidance
  - fill retry/skip and close-match copy
  - guess explanation + explicit continue
  - recall rating guidance and compact reveal flow
  - match deselection behavior
- re-ran `dart run build_runner build --delete-conflicting-outputs` after the
  study UX batch
- re-ran `flutter gen-l10n` after the study UX batch
- re-ran `python tools/guard/run.py --scope all` after the study UX batch
- re-ran `flutter analyze` after the study UX batch
- re-ran `flutter test` after the study UX batch
- added review keyboard shortcuts in
  [review_rating_shortcuts.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_shortcuts.dart)
  and mounted them from
  [review_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_round_view.dart)
  so review mode now supports keyboard-based reveal and 1-4 rating input
- extended guess mode with per-card skip tracking and a real skip consequence
  path in
  [guess_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/guess_provider.dart),
  then surfaced the state in
  [guess_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_round_view.dart)
  and
  [guess_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/guess_mode_screen.dart)
  through small-deck warnings, skip-limit hints, skipped-card summary, and a
  difficult-cards completion panel
- extended match mode with attempt-aware SRS persistence and clearer
  confirmation timing in
  [match_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/match_provider.dart),
  [match_item_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/match_item_card.dart),
  and
  [match_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/match_round_view.dart),
  including an explicit deselect hint and a difficult-cards completion panel
- extended recall mode with an `I don't know` fast path, stricter reveal
  gating, practice-missed session labeling, edit-from-comparison affordance,
  and a difficult-cards completion panel across:
  - [recall_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/recall_provider.dart)
  - [recall_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/recall_mode_screen.dart)
  - [recall_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_round_view.dart)
  - [recall_reveal_phase.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_reveal_phase.dart)
  - [recall_writing_area.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_writing_area.dart)
- extended fill mode fallback quality and keyboard ergonomics through
  definition/hint prompt generation in
  [fill_engine.dart](/D:/workspace/memox/lib/features/study/domain/fill/fill_engine.dart),
  `TextInputAction.done` wiring in
  [fill_answer_input.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_answer_input.dart),
  and example-coverage warnings in
  [fill_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/fill_mode_screen.dart)
  and
  [fill_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_round_view.dart)
- added a reusable completion-summary helper in
  [study_mistakes_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/study_mistakes_panel.dart)
  and reused it across review, guess, recall, and match completion views
- extended localized copy for the new study-mode warnings, practice labels,
  and difficult-card affordances in:
  - [app_en.arb](/D:/workspace/memox/l10n/app_en.arb)
  - [app_ko.arb](/D:/workspace/memox/l10n/app_ko.arb)
  - [app_vi.arb](/D:/workspace/memox/l10n/app_vi.arb)
- extended study-mode regression coverage for:
  - review keyboard shortcuts and difficult-card completion summary
  - guess small-deck warning, skipped-card path, and difficult-card summary
  - match deselect guidance and attempt-aware review persistence
  - recall missed-action flow, stricter reveal gate, edit affordance, and
    practice-missed restart
  - fill example-coverage warning and improved fallback prompt generation
- re-ran `dart run build_runner build --delete-conflicting-outputs` for the
  supplemental study-UX coverage pass
- re-ran `flutter gen-l10n` for the supplemental study-UX coverage pass
- re-ran `python tools/guard/run.py --scope all` for the supplemental
  study-UX coverage pass
- re-ran `flutter analyze` for the supplemental study-UX coverage pass
- re-ran targeted study-mode provider/screen tests for the supplemental
  coverage pass
- re-ran full `flutter test` after the targeted study-mode regression suite
- synced the supplemental study-UX coverage pass into:
  - `ui_fix_reference_screens_summary.md`
  - `ui_fix_shared_widgets_summary.md`
  - `ui_full_redesign_fix_pass.md`

## Files modified

- [.codex/notes/ui_execution_progress.md](/D:/workspace/memox/.codex/notes/ui_execution_progress.md)
- [home_screen.dart](/D:/workspace/memox/lib/features/folders/presentation/screens/home_screen.dart)
- [folder_deck_tile.dart](/D:/workspace/memox/lib/features/folders/presentation/widgets/folder_deck_tile.dart)
- [deck_tile.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile.dart)
- [deck_tile_supporting.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_tile_supporting.dart)
- [study_mode_sheet.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/study_mode_sheet.dart)
- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
- [rules.yaml](/D:/workspace/memox/tools/guard/policies/memox/rules.yaml)
- [choice_bottom_sheet.dart](/D:/workspace/memox/lib/shared/widgets/dialogs/choice_bottom_sheet.dart)
- [backup_list_sheet.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/backup_list_sheet.dart)
- [difficult_cards_section.dart](/D:/workspace/memox/lib/features/statistics/presentation/widgets/difficult_cards_section.dart)
- [home_screen_test.dart](/D:/workspace/memox/test/features/folders/presentation/screens/home_screen_test.dart)
- [folder_deck_tile_test.dart](/D:/workspace/memox/test/features/folders/presentation/widgets/folder_deck_tile_test.dart)
- [choice_bottom_sheet_test.dart](/D:/workspace/memox/test/shared/widgets/dialogs/choice_bottom_sheet_test.dart)
- [deck_cards_toolbar.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar.dart)
- [deck_cards_toolbar_test.dart](/D:/workspace/memox/test/features/decks/presentation/widgets/deck_cards_toolbar_test.dart)
- [app_scaffold.dart](/D:/workspace/memox/lib/shared/widgets/layout/app_scaffold.dart)
- [app_scaffold_test.dart](/D:/workspace/memox/test/shared/widgets/layout/app_scaffold_test.dart)
- [deck_cards_toolbar_delegate.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar_delegate.dart)
- [app_search_bar.dart](/D:/workspace/memox/lib/shared/widgets/inputs/app_search_bar.dart)
- [card_list_tile.dart](/D:/workspace/memox/lib/features/cards/presentation/widgets/card_list_tile.dart)
- [deck_detail_screen.dart](/D:/workspace/memox/lib/features/decks/presentation/screens/deck_detail_screen.dart)
- [app_search_bar_test.dart](/D:/workspace/memox/test/shared/widgets/inputs/app_search_bar_test.dart)
- [card_list_tile_test.dart](/D:/workspace/memox/test/features/cards/presentation/widgets/card_list_tile_test.dart)
- [settings_content_view.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_content_view.dart)
- [settings_section_header.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_section_header.dart)
- [settings_group_card.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_group_card.dart)
- [settings_appearance_section.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_appearance_section.dart)
- [settings_stepper_row.dart](/D:/workspace/memox/lib/features/settings/presentation/widgets/settings_stepper_row.dart)
- [icon_action_button.dart](/D:/workspace/memox/lib/shared/widgets/buttons/icon_action_button.dart)
- [settings_section_grouping_test.dart](/D:/workspace/memox/test/features/settings/presentation/widgets/settings_section_grouping_test.dart)
- [icon_action_button_test.dart](/D:/workspace/memox/test/shared/widgets/buttons/icon_action_button_test.dart)
- [.codex/notes/ui_fix_app_wide_summary.md](/D:/workspace/memox/.codex/notes/ui_fix_app_wide_summary.md)
- [.codex/notes/ui_full_redesign_fix_pass.md](/D:/workspace/memox/.codex/notes/ui_full_redesign_fix_pass.md)
- [.codex/notes/ui_fix_shared_widgets_summary.md](/D:/workspace/memox/.codex/notes/ui_fix_shared_widgets_summary.md)
- [.codex/notes/ui_fix_reference_screens_summary.md](/D:/workspace/memox/.codex/notes/ui_fix_reference_screens_summary.md)
- [fill_engine.dart](/D:/workspace/memox/lib/features/study/domain/fill/fill_engine.dart)
- [recall_prompt_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_prompt_card.dart)
- [recall_reveal_phase.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_reveal_phase.dart)
- [fill_engine_test.dart](/D:/workspace/memox/test/features/study/domain/fill/fill_engine_test.dart)
- [fill_provider_test.dart](/D:/workspace/memox/test/features/study/presentation/providers/fill_provider_test.dart)
- [fill_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/fill_mode_screen_test.dart)
- [recall_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/recall_mode_screen_test.dart)
- [study_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/study_screen_test.dart)
- [app_theme.dart](/D:/workspace/memox/lib/core/theme/app_theme.dart)
- [icon_action_button.dart](/D:/workspace/memox/lib/shared/widgets/buttons/icon_action_button.dart)
- [theme_extensions_test.dart](/D:/workspace/memox/test/core/theme/theme_extensions_test.dart)
- [policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
- [fill_prompt_sentence.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_prompt_sentence.dart)
- [fill_feedback_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_feedback_panel.dart)
- [recall_prompt_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_prompt_card.dart)
- [recall_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/recall_mode_screen_test.dart)
- [l10n/app_en.arb](/D:/workspace/memox/l10n/app_en.arb)
- [l10n/app_vi.arb](/D:/workspace/memox/l10n/app_vi.arb)
- [l10n/app_ko.arb](/D:/workspace/memox/l10n/app_ko.arb)
- [match_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/match_provider.dart)
- [guess_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_round_view.dart)
- [guess_feedback_card.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_feedback_card.dart)
- [recall_reveal_phase.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_reveal_phase.dart)
- [recall_rating_guidance.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/recall_rating_guidance.dart)
- [review_rating_button.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_button.dart)
- [review_rating_grid.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/review_rating_grid.dart)
- [match_provider_test.dart](/D:/workspace/memox/test/features/study/presentation/providers/match_provider_test.dart)
- [guess_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/guess_mode_screen_test.dart)
- [review_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/review_mode_screen_test.dart)
- [review_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/review_mode_screen.dart)
- [study_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/study_screen.dart)
- [recall_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/recall_provider.dart)
- [study_mistakes_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/study_mistakes_panel.dart)
- [fill_mistakes_panel.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/fill_mistakes_panel.dart)
- [guess_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/guess_mode_screen.dart)
- [match_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/match_mode_screen.dart)
- [recall_mode_screen.dart](/D:/workspace/memox/lib/features/study/presentation/screens/recall_mode_screen.dart)
- [review_provider.dart](/D:/workspace/memox/lib/features/study/presentation/providers/review_provider.dart)
- [recall_provider_test.dart](/D:/workspace/memox/test/features/study/presentation/providers/recall_provider_test.dart)
- [study_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/study_screen_test.dart)
- [guess_round_view.dart](/D:/workspace/memox/lib/features/study/presentation/widgets/guess_round_view.dart)
- [guess_mode_screen_test.dart](/D:/workspace/memox/test/features/study/presentation/screens/guess_mode_screen_test.dart)
- [deck_cards_toolbar.dart](/D:/workspace/memox/lib/features/decks/presentation/widgets/deck_cards_toolbar.dart)
- [deck_cards_toolbar_test.dart](/D:/workspace/memox/test/features/decks/presentation/widgets/deck_cards_toolbar_test.dart)

## Deferred items

- broad token remapping and large shared widget rewrites remain deferred unless
  the current code inspection shows a clearly safe central fix
- broader top-bar geometry compaction is still deferred; the current pass only
  locked the existing `balancedSlotWidth` footprint behind an allowlist guard
- a deeper `AppCardListTile` redesign is still deferred; this pass only
  eliminated one remaining feature-side bypass in `FolderDeckTile`
- `DifficultCardsSection` is calmer and denser now, but the broader statistics
  dashboard still needs a later pass to further reduce card-stack sameness
- broader statistics, home, and library layout propagation remains deferred to
  later focused screen passes
- deck-detail overview-to-toolbar spacing was not reopened in this hotfix; only
  the toolbar's own inset/extent contract was corrected
- actual `floatingActionButtonLocation` geometry was not changed in this pass;
  this fix only normalized the shared content baseline around the existing FAB
  placement contract
- no extra deck-detail sliver bottom padding was added in this pass because the
  shared `AppScaffold` FAB clearance already reserves more than `xxxl` space at
  the bottom edge
- none of the requested study-mode checklist items remain deferred on this
  branch; any further follow-up is optional polish rather than missing UX
  coverage
- richer statistics drill-down from the new recent-session summary remains a
  later enhancement if the team wants a full session-history screen
- smarter guess distractor sourcing from related decks remains optional because
  the current batch already covers the minimum-deck warning path

## Risks / regressions to watch

- the branch already contains broad UI edits from earlier redesign phases, so
  new changes must stay tightly scoped and consistent with those shared-layer
  decisions
- shared widget and theme files have the highest regression risk because they
  can affect multiple screens at once
- some roadmap items have already been partially implemented in this branch, so
  I need to verify current code before assuming an audit finding is still open
- folder-detail focused-deck highlighting now uses the shared card border path
  instead of the previous left accent stripe, so highlight clarity on-device
  should be watched in later visual review
- the new `balanced_top_bar_slot` guard is intentionally strict; if a future
  centered-title header truly needs that geometry, it must be explicitly
  allowlisted instead of silently reusing it
- the new feature bottom-sheet guard means any future sheet wrapper added in
  feature code should route through `context.showAppBottomSheet(...)` or a
  shared helper from the start
- deck toolbar compact localization should still be watched on-device if sort
  labels grow in future locales, because the extent is now matched more
  closely to the compact header contract
- if the design direction later requires the FAB itself to sit lower or overlap
  bottom navigation more aggressively, that should be handled as a separate
  `floatingActionButtonLocation` pass instead of piggybacking on body padding
- `CardListTile` now uses the shared overflow menu for edit/delete, so card
  actions are calmer but one tap deeper; if users need direct one-tap inline
  actions later, that should be designed as a shared pattern instead of
  reintroducing raw per-screen icon rows
- the Appearance section now assumes a stable three-column chooser on compact
  screens; this should be spot-checked on-device in longer locales to confirm
  the centered labels still read comfortably without awkward wrapping
- fill mode now consistently treats the front side as the typed answer, so any
  existing decks that implicitly relied on the old mixed-direction bug should
  be spot-checked on-device for content expectations
- recall now prompts from the back side and reveals the front side, so study
  copy and user expectations should be sanity-checked in the live flow after
  verification even though the provider logic is unchanged
- `InkSparkle` follows shape correctly, but Android/Desktop tap feel should
  still be spot-checked on-device in one rounded-card flow and one icon-button
  flow to confirm the new splash reads well in motion
- `IconActionButton` now uses a slightly stronger enabled outline, so any
  future variant that wants a quieter border should become an explicit variant
  instead of silently weakening the shared default again
- `FillPromptSentence` is now visibly denser, so long example sentences should
  be spot-checked on-device to confirm the underline slot still reads clearly
- `FillFeedbackPanel` now lands tighter to the diff block and relies more on
  the shared button hierarchy, so long localized action labels should still be
  checked once in a narrow viewport
- the recall prompt label is now sentence case and larger, so the live layout
  should be spot-checked with a tagged card to confirm the label, prompt, and
  tag still form a calm top cluster
- guess mode now keeps a manual `Continue` affordance visible alongside the
  delayed correct-answer advance path, so the live flow should be spot-checked
  once on-device to confirm the button does not feel redundant at short delays
- fill mode now exposes `Skip for now` on the first retry and auto-opens hints,
  so the team should confirm this is the desired pedagogy for harder spelling
  cards before propagating the pattern further
- recall guidance now introduces an additional explanatory block under the
  rating control, so very small screens should be spot-checked to confirm the
  reveal phase still feels compact enough
- match-mode deselection is now explicit through re-tapping the selected item,
  so the interaction should be visually smoke-tested to confirm users infer it
  without a separate hint
- review undo now rolls back the persisted review record and restores the prior
  screen state, so the completion-edge snackbar path should still be
  spot-checked on-device once before release
- card flagging now relies on an internal tag contract, so bulk tag editing or
  future tag cleanup code should avoid stripping
  [flashcard_flags.dart](/D:/workspace/memox/lib/features/cards/domain/support/flashcard_flags.dart)
  markers unintentionally
- active session resume, recent-session summaries, and “study next deck” are
  now wired, so future routing or statistics refactors should keep those
  cross-mode helpers in sync instead of regressing them silently

## Next step

Spot-check the updated deck-detail `Cards` section on-device to confirm the
lighter toolbar and single-owner spacing handoff read correctly, then prepare
the branch for review.
