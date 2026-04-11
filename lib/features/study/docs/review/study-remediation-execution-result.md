## 1. Completed action items

- `Low-risk quick win 1: Stop overstating modePlan in the hub until runtime supports it`
  - Implemented as recommendation-only UI wording instead of executable-session wording.
  - Evidence:
    - `lib/features/study/presentation/widgets/study_recommendation_card.dart`
    - `l10n/app_en.arb`
    - `l10n/app_vi.arb`
    - `l10n/app_ko.arb`

- `Low-risk quick win 4: Add missing negative-path tests now`
  - Implemented for the safe branches already introduced in code.
  - Added direct tests for:
    - study entry refusal on empty eligibility
    - saved-snapshot bypass of entry refusal
    - recall retry-pending restore and second-miss finalization
    - match grouped-board restore and final grouped-board completion
  - Evidence:
    - `test/features/study/presentation/providers/study_entry_provider_test.dart`
    - `test/features/study/presentation/providers/recall_provider_test.dart`
    - `test/features/study/presentation/providers/match_provider_test.dart`
    - `test/features/study/presentation/screens/match_mode_screen_test.dart`

- `Required code change 5: Align retry and completion semantics with the documented session rules`
  - Completed only for the bounded high-drift parts that were explicitly targeted as safe:
    - recall now keeps missed cards in-session until retry resolution
    - match now spans grouped boards instead of truncating after one board
    - fill no longer opens a post-completion `practice mistakes` sub-run
  - Evidence:
    - `lib/features/study/presentation/providers/recall_provider.dart`
    - `lib/features/study/presentation/screens/recall_mode_screen.dart`
    - `lib/features/study/domain/match/match_engine.dart`
    - `lib/features/study/presentation/providers/match_provider.dart`
    - `lib/features/study/presentation/providers/fill_provider.dart`
    - `lib/features/study/presentation/screens/fill_mode_screen.dart`

- `Required test change 5: Rewrite tests that currently encode divergent product behavior`
  - Updated tests that previously locked in the old drift:
    - recall no longer assumes post-completion practice flow
    - match no longer assumes first-board completion for larger decks
    - study recommendation copy no longer implies full `modePlan` execution
  - Evidence:
    - `test/features/study/presentation/providers/recall_provider_test.dart`
    - `test/features/study/presentation/screens/recall_mode_screen_test.dart`
    - `test/features/study/presentation/providers/match_provider_test.dart`
    - `test/features/study/presentation/screens/match_mode_screen_test.dart`
    - `test/features/study/presentation/screens/study_screen_test.dart`

## 2. Partially completed action items

- `Required code change 2: Replace mode-local start with a real start-session orchestration boundary`
  - Partially completed by adding presentation-layer start gating for `nothingToStudy` and `containerNotFound`.
  - What is done:
    - direct mode entry checks deck existence and eligible cards before mode UI starts
    - direct route now shows explicit refusal UI instead of falling into mode-local empties
  - What remains:
    - `StartStudySessionUseCase` is still delegate-only
    - `StudyRepository.startSession` still returns only a persisted row
    - no domain-level first-session snapshot is returned
  - Evidence:
    - `lib/features/study/presentation/providers/study_entry_provider.dart`
    - `lib/features/study/presentation/screens/study_screen.dart`
    - `lib/features/study/domain/usecases/start_study_session.dart`
    - `lib/features/study/domain/repositories/study_repository.dart`

- `Required code change 3: Turn modePlan into executable session state or remove it from user-facing runtime`
  - Partially completed by removing overstated runtime claims from UI.
  - What is done:
    - recommendation card now frames `modePlan` as recommendation metadata
    - CTA starts with the primary mode only
  - What remains:
    - runtime is still single-mode and does not execute `modePlan`
  - Evidence:
    - `lib/features/study/presentation/widgets/study_recommendation_card.dart`
    - `lib/features/study/presentation/screens/study_screen.dart`
    - `lib/features/study/domain/usecases/build_study_deck_recommendation.dart`

- `Required code change 8: Add explicit refusal and error states to the study entry and mode flows`
  - Partially completed.
  - What is done:
    - explicit UI exists for `nothingToStudy`
    - explicit UI exists for `containerNotFound`
  - What remains:
    - no unauthorized/no-access branch
    - no structured invalid-action state
    - no timeout/interruption state
  - Evidence:
    - `lib/features/study/presentation/screens/study_screen.dart`
    - `lib/features/study/presentation/providers/study_entry_provider.dart`

- `Required test change 3: Add session-level UI and navigation tests`
  - Partially completed.
  - What is done:
    - direct-route refusal UI coverage
    - current-mode resume wording/start-over coverage
  - What remains:
    - no test for multi-mode `modePlan` execution
    - no unauthorized UI coverage
    - no normalized session-resume coverage
  - Evidence:
    - `test/features/study/presentation/screens/study_screen_test.dart`

- `Required test change 4: Add negative-path tests for invalid action, invalid payload, timeout, and interruption`
  - Partially completed.
  - What is done:
    - negative start-gating branches are now covered
    - recall retry-pending restore/finalization branches are covered
  - What remains:
    - no timeout tests
    - no interruption tests
    - no structured invalid-action / invalid-payload contract tests
  - Evidence:
    - `test/features/study/presentation/providers/study_entry_provider_test.dart`
    - `test/features/study/presentation/providers/recall_provider_test.dart`

- `Required doc change 4: Document or remove implementation-only UX behaviors`
  - Partially completed through code removal only.
  - What is done:
    - removed undocumented fill post-completion `practice mistakes` loop
    - earlier remediation had already removed undocumented recall post-completion practice flow
  - What remains:
    - no markdown sync was applied to existing docs
    - other implementation-only UX remains, such as review flagging and guess small-deck warning
  - Evidence:
    - `lib/features/study/presentation/providers/fill_provider.dart`
    - `lib/features/study/presentation/screens/fill_mode_screen.dart`

## 3. Deferred action items

- `Required code change 1: Introduce a docs-aligned session aggregate and snapshot contract`
  - Deferred because it requires a structural runtime contract change across domain, persistence, and resume behavior.

- `Required code change 4: Normalize legal actions and state transitions across modes`
  - Deferred because it requires a cross-mode state contract and coordinated provider/screen rewrite.

- `Required code change 6: Separate resumable session persistence from per-mode opaque payloads`
  - Deferred because it implies snapshot-shape migration risk and broader persistence redesign.

- `Required code change 7: Move analytics and long-term learning-state writes behind an explicit finalization boundary`
  - Deferred because it would alter SRS/statistics semantics across all study modes.

- `Required code change 9: Replace the current UI-only factory with business-key resolution where the docs require it`
  - Deferred because the repo still has no agreed session-engine runtime contract to resolve against.

- `Required test change 1: Replace the simple start/complete use-case tests with contract-level session tests`
  - Deferred because the underlying domain contract was not fully rewritten in this safe pass.

- `Required test change 2: Add persistence and resume tests for the docs-defined snapshot shape`
  - Deferred because the docs-defined snapshot shape does not yet exist in code.

- `Required test change 6: Add analytics contract tests`
  - Deferred because no analytics contract or emitter was introduced.

- `Required doc changes 1, 2, 3, and 5`
  - Deferred because they require product/architecture decisions the current codebase does not yet settle:
    - whether docs are target architecture or future-state notes
    - completion-time vs per-attempt learning-state updates
    - timeout/reveal-penalty/board-threshold policies
    - analytics event contract

- `High-risk changes needing caution`
  - Deferred in this pass:
    - persistence-schema and snapshot-shape migration
    - session coordinator introduction
    - moving long-term learning-state writes away from per-attempt updates
  - These remain beyond the safe bounded scope that stayed inside the existing mode-first architecture.

## 4. Files changed

- Source
  - `l10n/app_en.arb`
  - `l10n/app_vi.arb`
  - `l10n/app_ko.arb`
  - `lib/features/study/domain/match/match_engine.dart`
  - `lib/features/study/presentation/factories/study_mode_flow_factory.dart`
  - `lib/features/study/presentation/providers/fill_provider.dart`
  - `lib/features/study/presentation/providers/match_provider.dart`
  - `lib/features/study/presentation/providers/recall_provider.dart`
  - `lib/features/study/presentation/providers/study_entry_provider.dart`
  - `lib/features/study/presentation/screens/fill_mode_screen.dart`
  - `lib/features/study/presentation/screens/recall_mode_screen.dart`
  - `lib/features/study/presentation/screens/study_screen.dart`
  - `lib/features/study/presentation/widgets/study_active_session_card.dart`
  - `lib/features/study/presentation/widgets/study_recommendation_card.dart`
- Generated
  - `lib/features/study/presentation/providers/match_provider.freezed.dart`
  - `lib/features/study/presentation/providers/match_provider.g.dart`
  - `lib/features/study/presentation/providers/recall_provider.freezed.dart`
  - `lib/features/study/presentation/providers/recall_provider.g.dart`
  - `lib/features/study/presentation/providers/study_entry_provider.g.dart`
- Tests
  - `test/features/study/presentation/providers/match_provider_test.dart`
  - `test/features/study/presentation/providers/recall_provider_test.dart`
  - `test/features/study/presentation/providers/study_entry_provider_test.dart`
  - `test/features/study/presentation/screens/fill_mode_screen_test.dart`
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`
  - `test/features/study/presentation/screens/recall_mode_screen_test.dart`
  - `test/features/study/presentation/screens/study_screen_test.dart`

## 5. Tests added or updated

- Added
  - `test/features/study/presentation/providers/study_entry_provider_test.dart`
- Updated
  - `test/features/study/presentation/providers/recall_provider_test.dart`
  - `test/features/study/presentation/providers/match_provider_test.dart`
  - `test/features/study/presentation/screens/fill_mode_screen_test.dart`
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`
  - `test/features/study/presentation/screens/recall_mode_screen_test.dart`
  - `test/features/study/presentation/screens/study_screen_test.dart`

## 6. Follow-up notes

- Safe execution reached the low-risk and bounded high-drift items first, as recommended by the remediation plan:
  - recommendation honesty
  - direct start refusal
  - recall/match retry/completion drift
  - targeted negative-path tests
- Verification on the resulting state:
  - `flutter test test/features/study` passed
  - `python tools/guard/run.py --scope features` passed
  - `flutter analyze` reports only one pre-existing `info` outside study scope at `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart:62`
- The largest remaining gaps all depend on one unresolved architectural decision from the remediation plan:
  - whether `lib/features/study/docs/**` remains a target session-engine contract that the runtime must adopt, or whether those docs should be narrowed to the current mode-first product.
