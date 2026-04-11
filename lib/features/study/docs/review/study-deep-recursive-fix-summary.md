# Study Deep Recursive Fix Summary

## 1. Requirement baseline used

- Primary sources read before and during this pass:
  - `AGENTS.md`
  - `lib/features/study/docs/README.md`
  - `lib/features/study/docs/01_business_context.md`
  - `lib/features/study/docs/02_domain_model.md`
  - `lib/features/study/docs/03_session_lifecycle.md`
  - `lib/features/study/docs/04_mode_patterns.md`
  - `lib/features/study/docs/05_execution_rules.md`
  - `lib/features/study/docs/06_learning_lifecycle.md`
  - `lib/features/study/docs/07_use_cases_and_checklist.md`
  - `lib/features/study/docs/08_factory_pattern.md`
  - review reports under `lib/features/study/docs/review/**`
- Conservative runtime baseline used for the recursive pass:
  - The live runtime is still mode-first, not the generic multi-mode session engine described by the original docs.
  - `StudySession` persistence remains the current source of truth for study history rows.
  - `ActiveStudySessionSnapshot` remains the resumable runtime contract for active study state.
  - Direct entry continues to use the existing `StudyEntryStatus` contract in `study_entry_provider.dart`.
  - Existing tests are supporting evidence for the current runtime contract, not authority over the docs when they conflict.
- Confirmed behavior normalized from docs plus code for this pass:
  - Each active mode should expose an explicit action-state contract at runtime:
    - `modeState`
    - `allowedActions`
    - `currentItem`
    - `progress`
  - Resume surfaces should prefer the explicit snapshot progress contract when present.
  - The current runtime still completes one active mode at a time; no safe in-scope evidence supports forcing multi-mode execution in this pass.

## 2. Assumptions made and why they were necessary

- The current mode-first runtime is authoritative for safe local fixes.
  - Why: the generic session-engine contract in the docs still requires larger architectural work across repositories, providers, persistence, and navigation.
- Historical review artifacts were allowed to be corrected as documentation drift instead of treated as immutable evidence.
  - Why: several review docs still described already-fixed recall, fill, and match behavior and would otherwise keep reintroducing false mismatches into later passes.
- The active snapshot contract could be expanded conservatively without rewriting persistence or navigation.
  - Why: `ActiveStudySessionSnapshot` is already the feature-local resume boundary, so adding normalized runtime fields there was safer than forcing a database or route contract rewrite.
- `modePlan` persisted inside the active snapshot is limited to the current active mode only.
  - Why: persisting a broader recommended plan would imply unsupported multi-mode execution and create a false completion contract.
- `sessionType` remains deferred.
  - Why: the current runtime lets the user enter explicit modes directly, and no safe local rule exists to derive a truthful session type without inventing unsupported orchestration semantics.
- The recall progress contract should follow the pre-existing payload interpretation:
  - completed progress = `results.length - retryPendingCardIds.length`
  - Why: verification exposed that counting `totalCards - retryPending` falsely marked untouched cards as already resolved.
- A snapshot marked `sessionCompleted` or `modeState == completed` should not be surfaced as an active resumable session.
  - Why: the normalized snapshot contract now explicitly distinguishes completed state, so continuing to treat it as active created resume/conflict drift in hub and direct-entry flows.
- The review-mode undo toast and rollback path can be removed without replacing it.
  - Why: the behavior was implementation-only, not grounded in the study docs, and the current user request explicitly asked to remove it from review mode.
- Match mode should not expose a tap-again deselect affordance or hint once the user explicitly asked to remove it.
  - Why: the current request directly removed that interaction contract, so keeping the toggle behavior or its copy would preserve stale, ungrounded UI drift.
- Match board rows should keep a stable per-board height after settled pairs disappear.
  - Why: the board's pair count is fixed when the round is generated, and the user explicitly reported visible row stretching as a UI regression rather than intended adaptive behavior.

## 3. Iteration count

- Total coordinator iterations executed in this pass: `10`
- Recursive verification loops executed across the pass: `36`
  - initial baseline verification before edits
  - verification of the reverted `study_entry_provider` attempt
  - stale-review-doc rescan after docs cleanup
  - targeted data-layer test runs
  - full analyzer / test / guard verification for the initial pass
  - targeted provider-contract tests for the snapshot rewrite
  - analyzer pass for the snapshot rewrite
  - full `test/features/study` verification after the snapshot rewrite
  - guard pass after the snapshot rewrite
  - final rescan for remaining safe in-scope work
  - read-only subagent rescan for residual snapshot/resume drift
  - targeted entry and screen regression tests for the completed/stale snapshot batch
  - analyzer pass for the completed/stale snapshot batch
  - full `test/features/study` verification after the completed/stale snapshot batch
  - guard pass after the completed/stale snapshot batch
  - code generation and targeted review-mode verification for the undo-removal batch
  - analyzer pass for the undo-removal batch
  - full `test/features/study` verification after the undo-removal batch
  - guard pass after the undo-removal batch
  - final `undo` keyword rescan across `lib/features/study/**`
  - post-patch match deselect rescan that exposed an orphaned provider method
  - targeted l10n regeneration and match-mode verification for the deselect-removal batch
  - analyzer pass for the deselect-removal batch
  - full `test/features/study` verification after the deselect-removal batch
  - guard pass after the deselect-removal batch
  - final match deselect keyword rescan across `lib/features/study/**`, `test/features/study/**`, and `l10n/**`
  - targeted root-cause inspection for correct-match selections being scored as wrong
  - targeted provider and engine regression verification for the match-scoring batch
  - analyzer pass for the match-scoring batch
  - full `test/features/study` verification after the match-scoring batch
  - guard pass after the match-scoring batch
  - targeted layout inspection for remaining match cards stretching after a correct pair disappears
  - targeted screen regression verification for the match-layout batch
  - analyzer pass for the match-layout batch
  - full `test/features/study` verification after the match-layout batch
  - guard pass after the match-layout batch

## 4. Iteration details

### Iteration 1

#### Issues selected

- Potential same-container resume/reactivity gap around `study_entry_provider.dart`

#### Classification of each issue

- `consistency fix required by an already grounded fix`

#### Grounding source for each issue

- `lib/features/study/docs/06_learning_lifecycle.md`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`
- direct source inspection of `study_entry_provider.dart`, `study_screen.dart`, `study_hub_provider.dart`, and related resume tests

#### Root cause targeted

- The attempted fix targeted stale entry-state reads when active snapshot state changed inside the same provider container.

#### Files changed

- Attempted and then reverted:
  - `lib/features/study/presentation/providers/study_entry_provider.dart`
  - `test/features/study/presentation/providers/study_entry_provider_test.dart`

#### Tests changed

- Temporary provider test changes were attempted and then reverted with the production rollback.

#### Verification result

- The attempted change was not kept.
- Verification exposed instability and timeout risk in the proposed reactive entry rewrite, so the edit was fully reverted.
- After the revert, the baseline was re-established with:
  - `dart run build_runner build --delete-conflicting-outputs`
  - `flutter analyze lib/features/study test/features/study`
  - `flutter test test/features/study`
  - `python tools/guard/run.py --scope features`
- All four commands passed after the revert.

#### Newly exposed issues found after verification

- The deep summary file itself was stale and no longer matched the reverted runtime.
- Several review reports still described already-fixed recall, fill, and match behavior.
- The current mapper / datasource / repository contract still had no direct regression tests under `test/features/study/data/**`.

### Iteration 2

#### Issues selected

- Stale review-doc claims about recall retry behavior
- Stale review-doc claims about fill completion behavior
- Stale review-doc claims about grouped match-board behavior

#### Classification of each issue

- `consistency fix required by an already grounded fix`

#### Grounding source for each issue

- Current source inspection of:
  - `lib/features/study/presentation/providers/recall_provider.dart`
  - `lib/features/study/presentation/screens/fill_mode_screen.dart`
  - `lib/features/study/presentation/providers/match_provider.dart`
- Current tests proving those behaviors:
  - `test/features/study/presentation/providers/recall_provider_test.dart`
  - `test/features/study/presentation/screens/fill_mode_screen_test.dart`
  - `test/features/study/presentation/providers/match_provider_test.dart`
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`
- Later grounded fix summaries:
  - `lib/features/study/docs/review/study-business-fix-summary.md`
  - `lib/features/study/docs/review/study-ui-state-fix-summary.md`
  - `lib/features/study/docs/review/study-fix-execution-summary.md`

#### Root cause targeted

- Older review artifacts had not been updated after later grounded study fixes, so they still reported behaviors that no longer existed.

#### Files changed

- `lib/features/study/docs/review/study-compliance-checklist.md`
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`
- `lib/features/study/docs/review/study-normalized-requirement-review.md`
- `lib/features/study/docs/review/study-remediation-plan.md`

#### Tests changed

- None

#### Verification result

- Recursive rescan across `lib/features/study/docs/review/**` no longer found stale claims that:
  - recall ends in a separate post-completion missed-card practice path
  - fill completion exposes a practice-only action
  - match is truncated to a single visible board

#### Newly exposed issues found after verification

- The deep recursive summary still needed to be rewritten from scratch because it still described the reverted reactive-entry fix as live behavior.
- The data-layer regression gap remained open.

### Iteration 3

#### Issues selected

- Missing mapper regression coverage for the current persisted session contract
- Missing datasource regression coverage for the current persisted session contract
- Missing repository regression coverage for the current persisted session contract

#### Classification of each issue

- `test-aligned correction`

#### Grounding source for each issue

- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- `lib/features/study/docs/review/study-compliance-checklist.md`
- direct source inspection of:
  - `lib/features/study/data/mappers/study_session_mapper.dart`
  - `lib/features/study/data/datasources/study_local_datasource.dart`
  - `lib/features/study/data/repositories/study_repository_impl.dart`

#### Root cause targeted

- The current mode-first persistence contract had only thin use-case delegation tests and no direct regression protection at the mapper, datasource, or repository layer.

#### Files changed

- Added:
  - `test/features/study/data/mappers/study_session_mapper_test.dart`
  - `test/features/study/data/datasources/study_local_datasource_test.dart`
  - `test/features/study/data/repositories/study_repository_impl_test.dart`

#### Tests changed

- New mapper coverage:
  - persisted row -> entity mapping
  - explicit identifier / timestamp preservation
  - zero-id omission and automatic `startedAt` backfill
- New datasource coverage:
  - save inserts and reloads rows
  - save replaces rows when `id` is present
  - `watchAll()` ordering follows DAO order
- New repository coverage:
  - `startSession()` persists the current mode-first contract
  - `completeSession()` persists completion fields
  - `watchAll()` maps rows back to ordered entities

#### Verification result

- Initial targeted runs exposed only local test-harness issues:
  - `inInclusiveRange` was invalid for `DateTime`
  - `drift` introduced matcher-name collisions (`isNull`, `isNotNull`)
- Those harness issues were fixed inside the same iteration.
- Final verification passed:
  - `flutter test test/features/study/data`
  - `python tools/guard/run.py --scope test`
  - `flutter analyze lib/features/study test/features/study`
  - `flutter test test/features/study`

#### Newly exposed issues found after verification

- The generic active-session action-state contract was still entirely absent from the runtime and resume payload.

### Iteration 4

#### Issues selected

- `ActiveStudySessionSnapshot` still persisted only `deckId`, `mode`, optional `session`, and opaque `payload`
- No explicit `modeState`, `allowedActions`, `currentItem`, or normalized `progress` contract existed at runtime
- Resume surfaces still had to reconstruct progress from mode-specific payload shapes
- No regression tests covered the generic action-state contract across the five active study modes

#### Classification of each issue

- `documented mismatch`

#### Grounding source for each issue

- `lib/features/study/docs/02_domain_model.md`
- `lib/features/study/docs/05_execution_rules.md`
- `lib/features/study/docs/review/study-compliance-checklist.md`
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- direct source inspection of:
  - `lib/features/study/presentation/providers/active_study_session_store.dart`
  - `lib/features/study/presentation/providers/review_provider.dart`
  - `lib/features/study/presentation/providers/guess_provider.dart`
  - `lib/features/study/presentation/providers/recall_provider.dart`
  - `lib/features/study/presentation/providers/fill_provider.dart`
  - `lib/features/study/presentation/providers/match_provider.dart`
  - `lib/features/study/presentation/factories/study_mode_flow_factory.dart`
  - `lib/features/study/presentation/screens/study_screen.dart`
  - `lib/features/study/presentation/widgets/study_active_session_card.dart`

#### Root cause targeted

- The feature stored resumable state as mode-local opaque payloads only, so the docs-defined action-state contract could not be returned, resumed, or tested as a normalized runtime surface.

#### Files changed

- `lib/features/study/presentation/providers/active_study_session_store.dart`
- `lib/features/study/presentation/providers/review_provider.dart`
- `lib/features/study/presentation/providers/guess_provider.dart`
- `lib/features/study/presentation/providers/recall_provider.dart`
- `lib/features/study/presentation/providers/fill_provider.dart`
- `lib/features/study/presentation/providers/match_provider.dart`
- `lib/features/study/presentation/factories/study_mode_flow_factory.dart`
- `lib/features/study/presentation/screens/study_screen.dart`
- `lib/features/study/presentation/widgets/study_active_session_card.dart`
- `test/features/study/presentation/providers/active_study_session_store_test.dart`
- `test/features/study/presentation/providers/review_provider_test.dart`
- `test/features/study/presentation/providers/guess_provider_test.dart`
- `test/features/study/presentation/providers/recall_provider_test.dart`
- `test/features/study/presentation/providers/fill_provider_test.dart`
- `test/features/study/presentation/providers/match_provider_test.dart`

#### Tests changed

- Added store-level regression coverage for:
  - serialized `modePlan`
  - serialized `modeState`
  - serialized `allowedActions`
  - serialized `currentItem`
  - serialized `progress`
- Added per-mode provider regression coverage asserting that each mode now persists:
  - the current single-mode `modePlan`
  - a normalized `modeState`
  - explicit `allowedActions`
  - `currentItem`
  - `progress`

#### Verification result

- `dart format` passed on all changed files.
- Targeted provider/store verification passed:
  - `flutter test test/features/study/presentation/providers/active_study_session_store_test.dart test/features/study/presentation/providers/review_provider_test.dart test/features/study/presentation/providers/guess_provider_test.dart test/features/study/presentation/providers/recall_provider_test.dart test/features/study/presentation/providers/fill_provider_test.dart test/features/study/presentation/providers/match_provider_test.dart`
- `flutter analyze lib/features/study test/features/study` passed after cleaning new `info` diagnostics.
- Full study verification passed:
  - `flutter test test/features/study`
- `python tools/guard/run.py --scope features` passed with the same pre-existing `feature_completeness` warnings about empty feature subfolders outside the changed study logic.

#### Newly exposed issues found after verification

- The new recall contract test exposed that recall progress and `displayIndex` logic were internally inconsistent: untouched cards were being counted as already resolved at session start.

### Iteration 5

#### Issues selected

- Recall progress / `displayIndex` inconsistency exposed by the new contract assertions

#### Classification of each issue

- `regression fix`

#### Grounding source for each issue

- failing verification from Iteration 4
- direct source inspection of `lib/features/study/presentation/providers/recall_provider.dart`
- existing fallback progress logic in `lib/features/study/presentation/factories/study_mode_flow_factory.dart`

#### Root cause targeted

- `RecallStateX.resolvedCount` was derived from `totalCards - retryPendingCardIds.length`, which falsely treated untouched cards as completed and fed both progress and `displayIndex`.

#### Files changed

- `lib/features/study/presentation/providers/recall_provider.dart`

#### Tests changed

- No new test file was needed; the iteration used the contract test added in Iteration 4 as regression protection.

#### Verification result

- The recall contract logic was corrected so completed progress is now derived from resolved results rather than total untouched cards.
- Verification passed:
  - targeted provider/store tests
  - `flutter analyze lib/features/study test/features/study`
  - `flutter test test/features/study`
  - `python tools/guard/run.py --scope features`

#### Newly exposed issues found after verification

- No additional safely fixable in-scope issue was exposed after the final full verification pass.

### Iteration 6

#### Issues selected

- Completed active snapshots still surfaced as resumable on the hub and direct-entry resume prompt
- A matching stale snapshot was left behind when the requested deck no longer existed
- The background resume probe in `study_screen.dart` could throw independently of the main async entry flow

#### Classification of each issue

- Completed snapshot resume/conflict drift
  - `reviewed mismatch`
- Missing-container stale snapshot cleanup
  - `consistency fix required by an already grounded fix`
- Resume-probe exception handling
  - `regression fix`

#### Grounding source for each issue

- `lib/features/study/docs/02_domain_model.md`
- `lib/features/study/docs/06_learning_lifecycle.md`
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- read-only subagent findings from the recursive residual scan
- direct source inspection of:
  - `lib/features/study/presentation/providers/study_entry_provider.dart`
  - `lib/features/study/presentation/providers/study_hub_provider.dart`
  - `lib/features/study/presentation/screens/study_screen.dart`
  - `lib/features/study/presentation/widgets/study_active_session_card.dart`

#### Root cause targeted

- The normalized snapshot contract already carried `sessionCompleted` and `modeState`, but the entry, hub, and resume surfaces still treated every deserializable snapshot as active state.

#### Files changed

- `lib/features/study/presentation/providers/active_study_session_store.dart`
- `lib/features/study/presentation/providers/study_entry_provider.dart`
- `lib/features/study/presentation/providers/study_hub_provider.dart`
- `lib/features/study/presentation/screens/study_screen.dart`
- `lib/features/study/presentation/widgets/study_active_session_card.dart`
- `test/features/study/presentation/providers/study_entry_provider_test.dart`
- `test/features/study/presentation/screens/study_screen_test.dart`

#### Tests changed

- Added provider regression coverage for:
  - clearing a matching saved snapshot when the requested deck is missing
  - ignoring and clearing a completed saved snapshot during entry resolution
- Added screen regression coverage for:
  - clearing a completed active snapshot on the hub
  - refusing to resume a completed matching snapshot and falling back to the explicit refusal state
  - ignoring resume-probe exceptions while still rendering the requested mode
- Strengthened the existing stale-hub test to assert that the stale snapshot is actually removed from storage

#### Verification result

- `dart format` passed on all changed files.
- Targeted regression verification passed:
  - `flutter test test/features/study/presentation/providers/study_entry_provider_test.dart test/features/study/presentation/screens/study_screen_test.dart`
- `flutter analyze lib/features/study test/features/study` passed with no diagnostics.
- Full study verification passed:
  - `flutter test test/features/study`
- `python tools/guard/run.py --scope features` passed with the same pre-existing `feature_completeness` warnings about empty feature subfolders outside the changed study logic.
- Recursive final rescan across `lib/features/study/**` found no remaining active-session entry or hub surface that still treated completed snapshots as resumable.

#### Newly exposed issues found after verification

- No additional safely fixable in-scope issue was exposed after the completed/stale snapshot batch.

### Iteration 7

#### Issues selected

- Review mode still exposed an undocumented `Undo` toast and rollback path after rating a card
- Review provider state still carried undo-only fields and callback plumbing
- Review docs and tests would become stale if the undo path was removed only in the UI

#### Classification of each issue

- Review-mode undo removal
  - `reviewed mismatch`
- Provider/state cleanup required by the undo removal
  - `consistency fix required by an already grounded fix`
- Test and docs updates for the removed behavior
  - `test-aligned correction`

#### Grounding source for each issue

- direct user request on 2026-04-11 to remove the review-mode `Undo` function shown in the UI
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`
- direct source inspection of:
  - `lib/features/study/presentation/providers/review_provider.dart`
  - `lib/features/study/presentation/screens/review_mode_screen.dart`
  - `test/features/study/presentation/providers/review_provider_test.dart`
  - `test/features/study/presentation/screens/review_mode_screen_test.dart`

#### Root cause targeted

- Review mode still kept an implementation-only rollback path that was not part of the documented study contract and was only surfaced through the post-rating toast flow.

#### Files changed

- `lib/features/study/presentation/providers/review_provider.dart`
- `lib/features/study/presentation/providers/review_provider.freezed.dart`
- `lib/features/study/presentation/screens/review_mode_screen.dart`
- `test/features/study/presentation/providers/review_provider_test.dart`
- `test/features/study/presentation/screens/review_mode_screen_test.dart`
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-normalized-requirement-review.md`
- `lib/features/study/docs/review/study-remediation-execution-result.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`
- `lib/features/study/docs/review/study-remediation-plan.md`

#### Tests changed

- Replaced the provider undo regression with coverage that completed review clears the active snapshot after rating.
- Updated the review screen test to assert that rating no longer surfaces an `Undo` action.

#### Verification result

- `dart run build_runner build --delete-conflicting-outputs` passed after removing undo-only provider state.
- Targeted review-mode verification passed:
  - `flutter test test/features/study/presentation/providers/review_provider_test.dart test/features/study/presentation/screens/review_mode_screen_test.dart`
- `flutter analyze lib/features/study test/features/study` passed with no diagnostics.
- Full study verification passed:
  - `flutter test test/features/study`
- `python tools/guard/run.py --scope features` passed with the same pre-existing `feature_completeness` warnings about empty feature subfolders outside the changed study logic.
- Final keyword rescan across `lib/features/study/**` found no remaining `undoLastRating`, review undo toast, or review undo docs inside the study feature.

#### Newly exposed issues found after verification

- No additional safely fixable in-scope issue was exposed after the undo-removal batch.

### Iteration 8

#### Issues selected

- Match mode still cleared the current term or definition when the learner tapped the same selected card again
- Match round view still rendered a deselect hint that described the removed interaction
- Match review docs, l10n strings, and regression tests would become stale if the toggle removal stopped at provider logic only

#### Classification of each issue

- Match self-clear removal
  - `reviewed mismatch`
- UI, docs, and l10n cleanup required by the toggle removal
  - `consistency fix required by an already grounded fix`
- Regression-test updates for the removed behavior
  - `test-aligned correction`

#### Grounding source for each issue

- direct user request on 2026-04-11 to remove the match-mode "tap again to clear" behavior shown in the UI
- direct source inspection of:
  - `lib/features/study/presentation/providers/match_provider.dart`
  - `lib/features/study/presentation/widgets/match_round_view.dart`
  - `test/features/study/presentation/providers/match_provider_test.dart`
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`
  - `lib/features/study/docs/review/study-ui-and-state-flow-review.md`
- recursive rescan proving the remaining user-facing copy lived in:
  - `l10n/app_en.arb`
  - `l10n/app_ko.arb`
  - `l10n/app_vi.arb`

#### Root cause targeted

- Match mode still carried an implementation-only self-clear affordance in provider logic, UI copy, localized strings, and study review docs even after the user explicitly removed that behavior.

#### Files changed

- `lib/features/study/presentation/providers/match_provider.dart`
- `lib/features/study/presentation/widgets/match_round_view.dart`
- `test/features/study/presentation/providers/match_provider_test.dart`
- `test/features/study/presentation/screens/match_mode_screen_test.dart`
- `l10n/app_en.arb`
- `l10n/app_ko.arb`
- `l10n/app_vi.arb`
- regenerated by `flutter gen-l10n`:
  - `lib/l10n/generated/app_localizations.dart`
  - `lib/l10n/generated/app_localizations_en.dart`
  - `lib/l10n/generated/app_localizations_ko.dart`
  - `lib/l10n/generated/app_localizations_vi.dart`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`
- `lib/features/study/docs/review/study-deep-recursive-fix-summary.md`

#### Tests changed

- Replaced the provider regression that expected tap-again deselection with coverage that the selected term remains selected.
- Updated the match screen test to assert that selecting one side no longer surfaces the old deselect hint copy.

#### Verification result

- Immediate post-patch rescan exposed that `MatchSession.deselectItem()` had become an uncalled dead path after the UI affordance was removed, so it was deleted inside the same iteration before final verification.
- `flutter gen-l10n` passed after removing the dead `matchDeselectHint` key from the ARB files.
- Targeted match-mode verification passed:
  - `flutter test test/features/study/presentation/providers/match_provider_test.dart test/features/study/presentation/screens/match_mode_screen_test.dart`
- `python tools/guard/run.py --scope features` passed with the same pre-existing `feature_completeness` warnings about empty feature subfolders outside the changed study logic.
- `flutter analyze lib/features/study test/features/study` passed with no diagnostics.
- Full study verification passed:
  - `flutter test test/features/study`
- Final rescans confirmed:
  - no remaining `deselectItem` symbol usage across `lib/**` and `test/**`
  - no remaining `matchDeselectHint` key or localized copy in implementation, docs, or generated l10n outputs
  - the only remaining old English copy is the negative regression assertion in `test/features/study/presentation/screens/match_mode_screen_test.dart`

#### Newly exposed issues found after verification

- No additional safely fixable in-scope issue was exposed after the deselect-removal batch.

### Iteration 9

#### Issues selected

- Match mode could score a correct pair as wrong when the `matchEngineProvider` was recreated after board generation
- `MatchEngine` kept hidden `_currentGame` state even though the current board mapping already lived in `MatchState.game`
- Existing provider coverage did not protect the match flow against engine recreation or invalidation between two taps

#### Classification of each issue

- Correct pair being scored as wrong
  - `regression fix`
- Hidden engine-state cleanup required by the regression fix
  - `consistency fix required by an already grounded fix`
- Missing regression coverage for recreated engine instances
  - `test-aligned correction`

#### Grounding source for each issue

- direct user report on 2026-04-11 that match mode sometimes marked a correct selection as wrong
- direct source inspection of:
  - `lib/features/study/domain/match/match_engine.dart`
  - `lib/features/study/presentation/providers/match_provider.dart`
  - `lib/features/study/presentation/widgets/match_item_board.dart`
  - `lib/features/study/presentation/widgets/match_item_card.dart`
  - `lib/features/study/presentation/screens/match_mode_screen.dart`
- generated provider contract proving `matchEngineProvider` is auto-dispose:
  - `lib/features/study/presentation/providers/match_provider.g.dart`
- `lib/features/study/docs/04_mode_patterns.md`
- current review baseline in `lib/features/study/docs/review/study-ui-and-state-flow-review.md`

#### Root cause targeted

- Match validation depended on `MatchEngine._currentGame`, a hidden mutable field inside an auto-dispose provider instance, instead of validating against the persisted board mapping already stored in `MatchState.game.correctPairs`.

#### Files changed

- `lib/features/study/domain/match/match_engine.dart`
- `lib/features/study/presentation/providers/match_provider.dart`
- `test/features/study/domain/match/match_engine_test.dart`
- `test/features/study/presentation/providers/match_provider_test.dart`
- `lib/features/study/docs/review/study-deep-recursive-fix-summary.md`

#### Tests changed

- Updated the engine test so `checkMatch` validates against the explicit board mapping instead of hidden instance state.
- Added provider regression coverage proving a correct pair still succeeds after invalidating `matchEngineProvider(1)` between the two taps.

#### Verification result

- `dart format` passed on the changed engine, provider, and test files.
- Targeted match regression verification passed:
  - `flutter test test/features/study/domain/match/match_engine_test.dart test/features/study/presentation/providers/match_provider_test.dart`
- `python tools/guard/run.py --scope features` passed with the same pre-existing `feature_completeness` warnings about empty feature subfolders outside the changed study logic.
- `flutter analyze lib/features/study test/features/study` passed with no diagnostics.
- Full study verification passed:
  - `flutter test test/features/study`
- Final rescans confirmed:
  - no remaining `_currentGame` field or hidden engine-state dependency in `lib/features/study/**`
  - `checkMatch` is now only a pure comparison against the explicit `correctPairs` mapping
  - the new invalidation regression test covers the user-reported scoring failure path

#### Newly exposed issues found after verification

- No additional safely fixable in-scope issue was exposed after the match-scoring batch.

### Iteration 10

#### Issues selected

- Remaining match cards stretched vertically after a correct pair disappeared from the board
- Match board row layout re-apportioned the full available height based on the number of visible rows instead of the board's fixed pair count
- Existing screen coverage did not protect the UI against this post-match height jump

#### Classification of each issue

- Remaining cards stretching after pair removal
  - `regression fix`
- Match board layout cleanup required by the regression fix
  - `consistency fix required by an already grounded fix`
- Missing UI regression coverage for stable remaining-card height
  - `test-aligned correction`

#### Grounding source for each issue

- direct user report on 2026-04-11 with screenshot showing the remaining match cards expanding after matched pairs disappeared
- direct source inspection of:
  - `lib/features/study/presentation/widgets/match_item_board.dart`
  - `lib/features/study/presentation/widgets/match_item_card.dart`
  - `lib/features/study/presentation/screens/match_mode_screen.dart`
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`

#### Root cause targeted

- `MatchItemBoard` wrapped each visible row in `Expanded`, so once settled pairs were removed the remaining rows redistributed the entire board height and visually stretched the cards.

#### Files changed

- `lib/features/study/presentation/widgets/match_item_board.dart`
- `test/features/study/presentation/screens/match_mode_screen_test.dart`
- `lib/features/study/docs/review/study-deep-recursive-fix-summary.md`

#### Tests changed

- Added screen regression coverage asserting that a remaining match card keeps the same height after another correct pair disappears from the board.

#### Verification result

- `dart format` passed on the changed match-board widget and screen test.
- Targeted screen verification passed:
  - `flutter test test/features/study/presentation/screens/match_mode_screen_test.dart`
- `python tools/guard/run.py --scope features` passed with the same pre-existing `feature_completeness` warnings about empty feature subfolders outside the changed study logic.
- `flutter analyze lib/features/study test/features/study` passed with no diagnostics.
- Full study verification passed:
  - `flutter test test/features/study`
- Final layout rescan confirmed the board height is now derived from the board's fixed pair count rather than redistributed from the number of visible rows.

#### Newly exposed issues found after verification

- No additional safely fixable in-scope issue was exposed after the match-layout batch.

## 5. Deferred items

- Domain-level generic study-session aggregate beyond the active snapshot contract
- `sessionType` in the live runtime contract
- Full multi-mode `modePlan` execution
- Session-level completion only after the final mode of a multi-mode plan
- Unauthorized / no-access start contract beyond the existing missing-container and nothing-to-study checks
- Analytics / reporting event contract
- Explicit invalid-action / invalid-payload failure contract
- Timeout policy in guess and recall
- Match board-level failure threshold / retry semantics
- UI-wide migration to use `allowedActions` as the sole interaction gate
- Broader reactive `studyEntryProvider` rewrite

## 6. Why each deferred item was not safely fixable

- Domain-level generic session aggregate, live `sessionType`, full multi-mode execution, and final-mode-only completion
  - These still require cross-feature architectural work across persistence, repositories, navigation, and completion semantics, not a safe local study patch.
- Unauthorized / no-access contract
  - No learner/access boundary exists in the current feature-local repository and use-case contract.
- Analytics / reporting event contract
  - No feature-local analytics service or event transport exists in scope, so inventing one would widen architecture beyond a grounded fix.
- Explicit invalid-action / invalid-payload failure contract
  - The current mode providers still use silent guard returns; formalizing a failure envelope would widen provider APIs and UI handling.
- Timeout policy
  - The docs mention timeout branches, but the review set still treats duration, penalty, and remediation rules as not specific enough for a conservative patch.
- Match board-level failure threshold / retry semantics
  - Grouped-board progression is implemented, but the docs still do not define a concrete fail threshold or retry rule precise enough for a safe minimal change.
- UI-wide `allowedActions` adoption
  - Some visible controls still expose non-canonical local interactions such as skip, hint, and close-answer accept or reject. Forcing those into the canonical contract without clarified mapping would invent behavior.
- Broader reactive `studyEntryProvider` rewrite
  - The attempted local change became unstable during verification and was reverted; keeping it would have introduced ungrounded runtime behavior.

## 7. Cross-file consistency issues found and resolved

- Review reports now consistently describe the current recall retry behavior.
- Review reports now consistently describe the current fill completion surface.
- Review reports now consistently describe grouped match-board progression instead of a single-board truncation model.
- The study data layer now has aligned regression coverage across mapper, datasource, and repository for the current mode-first contract.
- All five active study providers now persist the same normalized snapshot contract fields:
  - `modePlan`
  - `modeState`
  - `allowedActions`
  - `currentItem`
  - `progress`
  - `sessionCompleted`
- Review provider, screen, tests, and review docs now consistently omit the removed undo behavior.
- Match provider, round view, localized copy, tests, and review docs now consistently omit the removed tap-again deselect behavior.
- Match engine and provider now both validate pairs against the explicit board mapping instead of hidden engine instance state.
- Match board layout now keeps a stable per-board row height instead of stretching remaining cards when pairs disappear.
- Resume surfaces now prefer normalized snapshot progress instead of requiring mode-specific payload parsing when the explicit contract is present.
- Recall progress and `displayIndex` now use the same resolved-result interpretation as the persisted progress snapshot.
- Entry, hub, resume prompt, and active-session card surfaces now agree that completed snapshots are not resumable state.
- Hub and direct-entry cleanup now both remove stale snapshots when the referenced deck or active-state contract is no longer valid.

## 8. Final remaining risks

- The feature still remains mode-first rather than session-engine-first.
- The persisted runtime contract is only partially aligned with the docs because `sessionType` and full session aggregation are still absent.
- `modePlan` inside the active snapshot is intentionally conservative and single-mode only.
- Widgets still do not consume `allowedActions` as their sole source of truth.
- Session-level completion, analytics, authorization, and timeout behavior remain unresolved at the product / architecture level.
- Match still lacks a docs-defined board-failure rule even though grouped progression is implemented.

## 9. Final alignment status with docs

- Improved and aligned for the current mode-first runtime:
  - review docs now match the current recall retry behavior
  - review docs now match the current fill completion behavior
  - review docs now match the current grouped match-board behavior
  - the current data-layer contract now has direct regression coverage
  - the active runtime now returns and persists a normalized per-mode snapshot contract with:
    - `activeMode` via `mode`
    - `modePlan` as the current single active mode
    - `modeState`
    - `allowedActions`
    - `currentItem`
    - `progress`
    - `sessionCompleted`
  - completed or stale snapshots no longer surface as active resumable sessions in the hub or direct-entry resume path
  - review mode no longer exposes the undocumented undo toast or rollback action after rating
  - match mode no longer clears a selected card or shows a deselect hint when the same card is tapped again
  - match mode now validates a selected pair against the persisted board mapping even if `matchEngineProvider` is recreated between taps
  - match mode now keeps remaining cards at a stable height after settled pairs collapse out of the board
- Still intentionally deferred relative to the original study docs:
  - domain-level generic session aggregate
  - `sessionType`
  - full multi-mode execution
  - final-mode session completion boundary
  - authorization / negative-path start contract
  - analytics and completion-time learning-state update
  - timeout contract
  - board-level match failure semantics
  - UI-wide action gating exclusively from `allowedActions`

## 10. Confirmation that no speculative enhancement was implemented

- Retained changes are grounded in the docs, review findings, current implementation drift, or verification failures:
  - stale review-document corrections
  - data-layer regression tests for the current persisted contract
  - normalized active-session snapshot fields for the current mode-first runtime
  - regression tests for that snapshot contract across all five study modes
  - the recall resolved-progress bug fix exposed by the new contract tests
  - removal of the undocumented review-mode undo path requested by the user
  - removal of the undocumented match-mode tap-again deselect path requested by the user
  - root-cause correction for match-mode pairs being scored against hidden engine state
  - root-cause correction for match-mode cards stretching after matched pairs disappear
- The active snapshot `modePlan` was kept to a one-step current-mode list specifically to avoid inventing unsupported multi-mode behavior.
- No new timeout rule, analytics behavior, authorization behavior, board-failure rule, or broader navigation contract was invented.
