# Study Scenario And Test Gap Analysis

Strict scenario-by-scenario review of `lib/features/study/**` against the markdown source of truth in `lib/features/study/docs/**`, with emphasis on missing implementation coverage and missing tests.

## 1. Scenarios extracted from docs

| ID | Scenario | Expected behavior from docs | Doc evidence |
| --- | --- | --- | --- |
| S01 | Start an eligible study session | Validate learner access and container, select eligible items, derive `sessionType`, build `modePlan`, snapshot items, set initial mode/item, and return the first generic session snapshot. | `lib/features/study/docs/03_session_lifecycle.md:27-36`, `lib/features/study/docs/07_use_cases_and_checklist.md:9-25`, `lib/features/study/docs/02_domain_model.md:77-89` |
| S02 | Refuse session start when nothing is eligible | Return `nothing to study` or equivalent instead of creating a session. | `lib/features/study/docs/03_session_lifecycle.md:21-25`, `lib/features/study/docs/07_use_cases_and_checklist.md:20-24` |
| S03 | Refuse session start for unauthorized learner or missing container | Handle no access, invalid learner/container, or session type not applicable as explicit alternative flows. | `lib/features/study/docs/03_session_lifecycle.md:11-20`, `lib/features/study/docs/07_use_cases_and_checklist.md:20-24` |
| S04 | Expose generic session snapshot and `allowedActions` | Every open or resume step should expose `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted`. | `lib/features/study/docs/02_domain_model.md:77-89`, `lib/features/study/docs/05_execution_rules.md:5-17` |
| S05 | Perform a valid study action | Run the generic pipeline: show current item, accept only legal action, evaluate, record attempt, update item state, and return updated snapshot. | `lib/features/study/docs/03_session_lifecycle.md:38-45`, `lib/features/study/docs/07_use_cases_and_checklist.md:33-55` |
| S06 | Reject invalid action, invalid payload, timeout, or interruption | Explicitly reject illegal actions and invalid answer payloads; define timeout/interruption handling. | `lib/features/study/docs/07_use_cases_and_checklist.md:57-60`, `lib/features/study/docs/05_execution_rules.md:7-17` |
| S07 | Retry failed items before a mode completes | Failed items remain incomplete, become retry-pending, and are revisited before the mode can complete. | `lib/features/study/docs/03_session_lifecycle.md:47-60`, `lib/features/study/docs/05_execution_rules.md:46-59` |
| S08 | Complete the full session after the final mode | Session completes only after final mode completion and no incomplete items remain under the completion rule. | `lib/features/study/docs/03_session_lifecycle.md:61-67`, `lib/features/study/docs/07_use_cases_and_checklist.md:71-95` |
| S09 | Finalize learning state, result summary, and analytics | After session completion, update long-term learning state, generate result summary, and emit analytics/reporting data. | `lib/features/study/docs/03_session_lifecycle.md:68-72`, `lib/features/study/docs/06_learning_lifecycle.md:75-98`, `lib/features/study/docs/02_domain_model.md:99-105` |
| S10 | Resume an active session | Restore current mode, current item, progress, and legal next actions from persisted session state. | `lib/features/study/docs/06_learning_lifecycle.md:40-50` |
| S11 | Reset the current mode | Clear current-mode progress and restart under a defined business policy. The docs require the scenario but do not fully fix the session-identity policy. | `lib/features/study/docs/06_learning_lifecycle.md:51-62`, `lib/features/study/docs/05_execution_rules.md:28-38` |
| S12 | Exit an in-progress session | Decide whether partial state is saved, whether partial analytics are written, and whether re-entry resumes or starts over. The docs require a policy but do not choose one. | `lib/features/study/docs/06_learning_lifecycle.md:63-74` |
| S13 | Review mode: reveal then self-rate | Present one card, allow reveal, record a rating, and queue failed items for retry. | `lib/features/study/docs/04_mode_patterns.md:39-63` |
| S14 | Guess mode: choose answer with remediation | Present multiple choices, handle wrong or skipped answers with remediation, handle weak distractor sets, and define timeout behavior. | `lib/features/study/docs/04_mode_patterns.md:95-116`, `lib/features/study/docs/04_mode_patterns.md:133-157` |
| S15 | Recall mode: attempt, reveal, self-assess | Support recall attempt, reveal, self-assessment, and define timeout/reveal-penalty behavior. | `lib/features/study/docs/04_mode_patterns.md:149-170`, `lib/features/study/docs/04_mode_patterns.md:181-208` |
| S16 | Fill mode: evaluate exact, normalized, close, and wrong answers | Define answer grading, retry/remediation, empty-input handling, normalization, and reveal-assist policy. | `lib/features/study/docs/04_mode_patterns.md:199-221`, `lib/features/study/docs/04_mode_patterns.md:230-260`, `lib/features/study/docs/05_execution_rules.md:63-78` |
| S17 | Match mode: board scoring and grouping | Handle correct/wrong matches, board completion, missing pairs, and oversized boards split into groups. | `lib/features/study/docs/04_mode_patterns.md:68-110` |
| S18 | Persist resumable session and session-item snapshots | Persist session items, prompt/answer snapshot, retry flags, attempts, and resumable progress independent from source-card mutation. | `lib/features/study/docs/02_domain_model.md:37-52`, `lib/features/study/docs/02_domain_model.md:91-97`, `lib/features/study/docs/06_learning_lifecycle.md:40-50` |
| S19 | Emit empty, unauthorized, and success UI states | Present an explicit refusal/empty state, an access-denied alternative flow, and a result summary on completion. | `lib/features/study/docs/03_session_lifecycle.md:21-25`, `lib/features/study/docs/07_use_cases_and_checklist.md:20-24`, `lib/features/study/docs/07_use_cases_and_checklist.md:77-84` |
| S20 | Resolve business behavior through factories | Resolve handlers by business keys such as `sessionType`, `activeMode`, `answerType`, and `resultType`, and fail fast when unsupported. | `lib/features/study/docs/08_factory_pattern.md:36-76`, `lib/features/study/docs/08_factory_pattern.md:94-127` |

Notes on doc ambiguity:
- `S11` reset policy is required, but whether the same session identity is preserved is not fixed by docs.
- `S12` exit policy is required, but save-partial and partial-analytics semantics are not fixed by docs.
- `S14` through `S17` require answer/remediation policies, but exact thresholds and penalties are partially open questions in `lib/features/study/docs/05_execution_rules.md:63-78`.
- Loading and offline UX are outside the docs' explicit scope; they are not first-class scenarios in the markdown.

## 2. Coverage found in implementation

| ID | Implementation coverage | Evidence |
| --- | --- | --- |
| S01 | `PARTIAL` | The hub computes `sessionType` and `modePlan` in `lib/features/study/domain/usecases/build_study_deck_recommendation.dart:27-58`, but actual start only persists `deckId` + `mode` through `lib/features/study/domain/usecases/start_study_session.dart:10-13` and `lib/features/study/data/repositories/study_repository_impl.dart:27-42`. No generic first snapshot is returned. |
| S02 | `PARTIAL` | Each mode refuses locally by returning empty state when no cards are available in `review_provider.dart:350-364`, `guess_provider.dart:398-415`, `recall_provider.dart:347-360`, `fill_provider.dart:518-530`, and `match_provider.dart:359-363`. There is no generic refusal result from the start-session use case. |
| S03 | `MISSING` | No learner/access/container validation exists in `lib/features/study/domain/repositories/study_repository.dart:4-13` or `lib/features/study/domain/usecases/start_study_session.dart:10-13`. `StudyRepositoryImpl.startSession` always creates a row in `lib/features/study/data/repositories/study_repository_impl.dart:27-42`. |
| S04 | `MISSING` | `ActiveStudySessionSnapshot` only stores `deckId`, `mode`, optional `session`, and opaque `payload` in `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`. No `allowedActions` or generic `modeState` contract exists. |
| S05 | `PARTIAL` | Each mode runs its own valid-action pipeline inside provider-local state machines, for example `review_provider.dart:130-240`, `guess_provider.dart:176-339`, `recall_provider.dart:95-267`, `fill_provider.dart:240-437`, and `match_provider.dart:170-271`. The generic session engine described by the docs is absent. |
| S06 | `PARTIAL` | Illegal or premature actions are mostly ignored by guard returns in `review_provider.dart:108-114`, `guess_provider.dart:179-185`, `recall_provider.dart:168-173`, `fill_provider.dart:244-259`, and `match_provider.dart:115-123`. Timeout handling is absent in guess and recall. |
| S07 | `PARTIAL` | Review, guess, and fill implement retry/remediation in `review_provider.dart:158-191`, `guess_provider.dart:208-219`, `guess_provider.dart:320-327`, and `fill_provider.dart:390-437`. Recall now keeps missed cards in-session until the retry is resolved in `recall_provider.dart:111-125` and `recall_provider.dart:220-259`. Match advances across grouped boards in `match_provider.dart:203-260`, but it still lacks a docs-defined board fail/retry contract. |
| S08 | `MISSING` | Each mode completes independently in `review_provider.dart:243-263`, `guess_provider.dart:291-310`, `recall_provider.dart:238-259`, `fill_provider.dart:368-388`, and `match_provider.dart:170-188`. `modePlan` is not executed as a session orchestrator. |
| S09 | `PARTIAL` | Result summaries exist per mode screen, for example `review_mode_screen.dart:157-217` and `guess_mode_screen.dart:103-178`. Long-term SRS updates happen per attempt in `review_provider.dart:268-283`, `guess_provider.dart:342-359`, `recall_provider.dart:274-290`, `fill_provider.dart:452-468`, and `match_provider.dart:283-299`. No analytics emitter is present. |
| S10 | `PARTIAL` | Resume restores mode-local payloads in `review_provider.dart:419-470`, `guess_provider.dart:489-546`, `recall_provider.dart:417-459`, and `fill_provider.dart:597-646`. The restored state does not include docs-defined `allowedActions`, `sessionType`, or `modePlan`. |
| S11 | `PARTIAL` | `StudyScreen` supports `Start over` by clearing the saved snapshot and restarting the current mode through `lib/features/study/presentation/screens/study_screen.dart:70-90` and `lib/features/study/presentation/factories/study_mode_flow_factory.dart:103-116`. No generic `RESET_CURRENT_MODE` action contract exists. |
| S12 | `PARTIAL` | Exit prompts are implemented in mode screens such as `review_mode_screen.dart:73-85` and `match_mode_screen.dart:74-85`. In-progress state is saved via mode-specific snapshot persistence in `review_provider.dart:402-417`, `guess_provider.dart:472-487`, `recall_provider.dart:400-415`, and `fill_provider.dart:580-595`. Partial analytics policy is not implemented. |
| S13 | `IMPLEMENTED` | Review reveal, rating, retry-on-`again`, and flagging are implemented in `lib/features/study/presentation/providers/review_provider.dart` with UI in `lib/features/study/presentation/widgets/review_round_view.dart:35-139`. |
| S14 | `PARTIAL` | Guess grading and remediation are implemented in `lib/features/study/presentation/providers/guess_provider.dart:176-339`, and weak distractor fallback exists in `lib/features/study/domain/guess/guess_engine.dart:38-81`. Timeout behavior is not implemented. |
| S15 | `PARTIAL` | Recall reveal, self-rating, and in-session retry resolution are implemented in `lib/features/study/presentation/providers/recall_provider.dart:95-267`. Timeout and reveal-penalty behavior are not implemented. |
| S16 | `PARTIAL` | Fill answer grading, close-answer accept/reject, retry, hint, and skip-after-retry are implemented in `lib/features/study/presentation/providers/fill_provider.dart:123-437` and `lib/features/study/domain/fill/fill_engine.dart:22-34`. The docs-defined generic action/snapshot contract is still absent. |
| S17 | `PARTIAL` | Match board generation, mistake counting, grouped-board progression, and completion are implemented in `lib/features/study/domain/match/match_engine.dart:25-63` and `lib/features/study/presentation/providers/match_provider.dart:170-271`. Oversized boards still cap at five pairs per board, but board-level failure and retry-pending semantics remain missing. |
| S18 | `PARTIAL` | Session persistence exists through `lib/features/study/data/repositories/study_repository_impl.dart:18-42` and `lib/features/study/data/mappers/study_session_mapper.dart:19-35`, but persisted shape is only a simple session row. Resumable state is stored separately as mode-specific payload in `active_study_session_store.dart:23-49`, and no session-item snapshots exist. |
| S19 | `PARTIAL` | Empty and success states exist across hub and mode screens, for example `study_hub_content.dart:17-23`, `review_mode_screen.dart:149-217`, `guess_mode_screen.dart:74-178`, `fill_mode_screen.dart:137-210`, and `match_mode_screen.dart:89-145`. Unauthorized/no-access state is not implemented. |
| S20 | `PARTIAL` | The only factory is `StudyModeFlowFactory` in `lib/features/study/presentation/factories/study_mode_flow_factory.dart:17-59`, which maps screens and restart/progress helpers. No session-type, evaluator, or result-presentation factory layer exists. |

Implementation-only scenarios not documented by the markdown:
- Review card flagging in `lib/features/study/presentation/providers/review_provider.dart`.
- Guess placeholder distractors and small-deck warning in `lib/features/study/domain/guess/guess_engine.dart:38-81` and `lib/features/study/presentation/widgets/guess_question_card.dart:9-48`.
- Fill close-answer accept/reject flow and example-quality warning in `lib/features/study/presentation/providers/fill_provider.dart:123-176` and `lib/features/study/presentation/screens/fill_mode_screen.dart:213-241`.
- Match timer, star rating, and combo UX in `lib/features/study/presentation/screens/match_mode_screen.dart:96-165`.

## 3. Coverage found in tests

| ID | Test coverage | Evidence | Gap |
| --- | --- | --- | --- |
| S01 | `PARTIAL` | `test/features/study/domain/usecases/start_study_session_test.dart:8-18` only verifies delegation of `deckId` + `mode`. `test/features/study/domain/usecases/build_study_deck_recommendation_test.dart:14-85` verifies `sessionType` and `modePlan` selection as recommendation metadata. | No test verifies full start-session orchestration or first generic snapshot. |
| S02 | `PARTIAL` | Empty UI is covered in `test/features/study/presentation/screens/study_screen_test.dart:36-57`, `test/features/study/presentation/screens/review_mode_screen_test.dart:230-254`, and equivalent mode empty states. | No use-case or repository test for explicit `nothing to study` refusal. |
| S03 | `NONE` | No inspected test references unauthorized, permission-denied, forbidden, or missing-container behavior. | Negative scenario fully untested. |
| S04 | `NONE` | No inspected test asserts `allowedActions`, generic `modeState`, or docs-defined session snapshot fields. | Structural contract untested. |
| S05 | `PARTIAL` | Mode-specific happy paths are covered in provider and screen tests, for example `review_provider_test.dart:129-195`, `guess_provider_test.dart:87-156`, `fill_provider_test.dart:38-159`, and `match_provider_test.dart:34-162`. | Generic perform-action contract is untested. |
| S06 | `PARTIAL` | Some guard behavior is indirectly covered, such as fill retry gating in `test/features/study/presentation/providers/fill_provider_test.dart:100-130`. | No explicit tests for invalid action rejection, invalid payload result, timeout, or interruption. |
| S07 | `PARTIAL` | Review retry is covered in `test/features/study/presentation/providers/review_provider_test.dart:129-162`; guess remediation in `guess_provider_test.dart:87-156`; fill retry in `fill_provider_test.dart:100-159`. | Recall and match retry semantics are not tested because the implementation does not provide doc-style retry loops. |
| S08 | `NONE` | No test covers execution of a multi-mode `modePlan` or completion only after the final mode. | High-risk gap. |
| S09 | `PARTIAL` | Per-mode completion summaries are tested in `review_mode_screen_test.dart:60-90`, `guess_mode_screen_test.dart:71-121`, `fill_mode_screen_test.dart:87-124`, `recall_provider_test.dart:133-158`, and `match_provider_test.dart:133-162`. SRS adapters are covered in `test/features/study/domain/srs/srs_engine_test.dart:10-228`. | No analytics/event tests and no completion-time learning-state aggregation tests. |
| S10 | `PARTIAL` | Resume/start-over UX is covered in `test/features/study/presentation/screens/study_screen_test.dart:260-366`, plus mode-level exit/resume tests in `review_mode_screen_test.dart:316-344`, `guess_mode_screen_test.dart:345-373`, `recall_mode_screen_test.dart:157-204`, `fill_mode_screen_test.dart:191-222`, and `match_mode_screen_test.dart:214-245`. | No test verifies restoration of docs-defined `allowedActions`, `modePlan`, or generic session snapshot fields. |
| S11 | `PARTIAL` | `Start over` UI flow is covered in `test/features/study/presentation/screens/study_screen_test.dart:305-313`. | No lower-level test for reset semantics, session identity, or attempt-clearing policy. |
| S12 | `PARTIAL` | Exit keeps snapshot and allows resume in `study_screen_test.dart:315-366` and mode-specific screen tests. | No tests for partial analytics policy or alternative exit semantics. |
| S13 | `STRONG` | Review provider and screen flows are covered in `test/features/study/presentation/providers/review_provider_test.dart` and `test/features/study/presentation/screens/review_mode_screen_test.dart`. | Flagging and interaction shortcuts are still tested, but they are not doc-backed scenarios. |
| S14 | `PARTIAL` | Guess provider and screen flows are covered in `test/features/study/presentation/providers/guess_provider_test.dart:30-156` and `test/features/study/presentation/screens/guess_mode_screen_test.dart:28-177`. Low-distractor fallback is covered in `test/features/study/domain/guess/guess_engine_test.dart:27-39`. | No timeout coverage. |
| S15 | `PARTIAL` | Recall reveal, self-rating, in-session retry retention, retry resolution, and restore are covered in `test/features/study/presentation/providers/recall_provider_test.dart:36-209` and `test/features/study/presentation/screens/recall_mode_screen_test.dart:29-204`. | No timeout or reveal-penalty tests. |
| S16 | `STRONG` | Fill engine coverage exists in `test/features/study/domain/fill/fill_engine_test.dart:8-65` and `test/features/study/domain/srs/fuzzy_matcher_test.dart:7-29`. Provider/screen coverage exists in `fill_provider_test.dart:38-159`, `fill_mode_screen_test.dart:29-222`, and `fill_submit_button_test.dart:10-28`. | No test for a docs-defined generic output contract or explicit invalid payload result. |
| S17 | `PARTIAL` | Match provider and engine coverage exists in `test/features/study/presentation/providers/match_provider_test.dart:34-207`, `test/features/study/presentation/screens/match_mode_screen_test.dart:170-248`, and `test/features/study/domain/match/match_engine_test.dart:9-32`. | No negative board-failure or retry-threshold test. |
| S18 | `PARTIAL` | Start/complete persistence delegation is covered in `start_study_session_test.dart:8-18` and `complete_study_session_test.dart:8-31`. Resume payload persistence is covered at screen level. | No repository/data-layer integration test for persisted session shape or session-item snapshots. |
| S19 | `PARTIAL` | Empty and success UI states are covered across hub and mode screen tests. | Unauthorized state and async error state are untested. |
| S20 | `NONE` | No inspected test covers factory resolution or fail-fast behavior for unsupported business keys. | Architectural contract untested. |

Tests that currently lock in behavior that diverges from docs:
- `test/features/study/domain/usecases/start_study_session_test.dart:8-18` and `test/features/study/domain/usecases/complete_study_session_test.dart:8-31` normalize a single-mode repository contract.
- `test/features/study/presentation/screens/study_screen_test.dart:121-227` expects direct entry into one requested mode rather than execution of `modePlan`.
- `test/features/study/presentation/providers/match_provider_test.dart:171-207` locks in grouped-board progression and eventual completion without a docs-defined board-failure threshold.

## 4. Missing implementation scenarios

Documented scenarios with no implementation:
- `S03` unauthorized learner / missing container refusal.
- `S04` generic session snapshot with `allowedActions`.
- `S08` multi-mode session executor over `modePlan`.
- `S20` business-key factory resolution beyond UI routing.

Documented scenarios with only partial implementation:
- `S01` session start orchestration exists only as recommendation + raw persistence; no generic first snapshot.
- `S02` nothing-to-study refusal exists only as mode-local empty state.
- `S05` perform-action pipeline exists only inside isolated mode providers.
- `S06` invalid-action guards exist, but no structured rejection contract; timeout/interruption paths are missing.
- `S07` retry loop exists only for review, guess, and fill; recall and match diverge.
- `S09` result summaries exist, but analytics and completion-time learning-state updates do not.
- `S10` resume restores opaque per-mode payloads, not docs-defined session state.
- `S11` reset exists as UI-only `Start over`, but not as a generic state action.
- `S12` exit saves mode-local state, but partial analytics and alternate exit policies are undefined.
- `S14` guess timeout behavior is missing.
- `S15` recall timeout and reveal-penalty behavior are missing.
- `S16` fill policy is implemented, but explicit invalid payload/result contract is absent.
- `S17` grouped-board flow and docs-style completion semantics are missing.
- `S18` persistence lacks session-item snapshots and a docs-defined resumable session aggregate.
- `S19` unauthorized UI state is missing.

Implemented scenarios not documented in markdown:
- Review card flagging.
- Guess placeholder distractors and small-deck warning.
- Fill manual close-answer accept/reject flow and example-quality warning.
- Match timer, combo, and star-rating UX.

## 5. Missing test scenarios

Documented scenarios with no tests:
- `S03` unauthorized learner / no-access / container-not-found start failures.
- `S04` generic session snapshot fields and `allowedActions`.
- `S08` multi-mode `modePlan` execution and final-session completion rule.
- `S20` factory resolution and fail-fast behavior.

Documented scenarios with only partial or weak tests:
- `S01` start-session orchestration: current tests cover only raw repository delegation.
- `S02` nothing-to-study: covered only as UI empty state, not as use-case outcome.
- `S06` invalid action / invalid payload / timeout / interruption: almost entirely untested.
- `S09` analytics emission and completion-time learning-state update: untested.
- `S10` resume of `allowedActions`, `modePlan`, and generic progress snapshot: untested.
- `S11` reset semantics below the UI button level: untested.
- `S12` exit analytics policy and resume-vs-new-session policy: untested.
- `S14` guess timeout path: untested.
- `S15` recall timeout/reveal penalty path: untested.
- `S17` match board-level failure and retry semantics: untested.
- `S18` repository/data-layer persistence of full session state: untested.
- `S19` unauthorized UI state and async error state: untested.

Implemented scenarios with no tests:
- Review flagging persistence side effects are only lightly covered and not validated beyond a provider-level count change.
- Implementation-only UX extras such as match timer/star presentation and some fill/review widget affordances have no direct business-logic justification tests.
- The current study data-layer contract is now covered under `test/features/study/data/**` for `study_local_datasource.dart`, `study_session_mapper.dart`, and `study_repository_impl.dart`.

Edge cases with no tests:
- Guess timeout converting to fail/skip/reveal.
- Recall reveal without typing plus any penalty policy.
- Fill empty input as a formal invalid payload or skip-equivalent outcome.
- Match oversized deck split into multiple grouped boards.
- Resume after partially completed retry round.
- Restart current mode while retries are pending.
- Learning-state update failure during completion.

Negative cases with no tests:
- Unauthorized learner.
- Container not found.
- Invalid action in current state.
- Invalid answer payload shape.
- Async provider failure rendering.
- Unsupported factory key failure.

## 6. Priority order

1. Add tests for the missing session contract: start-session result, generic snapshot, `allowedActions`, and `modePlan` execution. These are the highest-risk gaps because they expose the largest doc-versus-runtime mismatch.
2. Add negative-path tests for unauthorized access, missing container, invalid action, invalid payload, and timeout. These scenarios are explicitly documented and currently have no coverage.
3. Add tests for completion semantics: retry-pending items blocking completion, final-mode-only completion, and failure handling during learning-state update.
4. Add persistence tests for resumable session state. The feature currently persists only a simplified session row plus opaque mode payloads, and there are no data-layer tests guarding that behavior.
5. Add edge-case tests for recall timeout/reveal policy, guess timeout, match grouped boards, and resume/reset during remediation.
6. Decide whether implementation-only scenarios are product features or drift. After that decision, either add docs and tests for them or remove/rework them.

## 7. Suggested test names and target files

Existing test files to extend:
- `test/features/study/domain/usecases/start_study_session_test.dart`
  - `startStudySession_returnsNothingToStudy_whenNoEligibleItems`
  - `startStudySession_returnsUnauthorized_whenLearnerHasNoAccess`
  - `startStudySession_returnsContainerNotFound_whenDeckDoesNotExist`
  - `startStudySession_returnsInitialSnapshot_withSessionTypeModePlanAndAllowedActions`
- `test/features/study/domain/usecases/complete_study_session_test.dart`
  - `completeStudySession_appliesLearningStateOnlyAfterFinalModeCompletes`
  - `completeStudySession_returnsFailure_whenLearningStateUpdateFails`
  - `completeStudySession_blocksCompletion_whenRetryPendingItemsRemain`
- `test/features/study/presentation/screens/study_screen_test.dart`
  - `studyScreen_launchesModePlanExecution_insteadOfOnlyPrimaryMode`
  - `studyScreen_showsUnauthorizedState_whenStartSessionIsDenied`
  - `studyScreen_restoresAllowedActionsAndProgress_whenResumingSession`
  - `studyScreen_showsAsyncErrorState_whenHubProviderFails`
- `test/features/study/presentation/providers/guess_provider_test.dart`
  - `guessProvider_timesOutQuestion_andQueuesRemediation`
  - `guessProvider_rejectsSelection_whenActionIsNotAllowed`
- `test/features/study/presentation/providers/recall_provider_test.dart`
  - `recallProvider_timesOut_toRevealOrFail_accordingToPolicy`
  - `recallProvider_recordsRevealPenalty_whenLearnerRevealsWithoutAttempt`
  - `recallProvider_keepsFailedItemsRetryPending_beforeModeCompletion`
- `test/features/study/presentation/providers/fill_provider_test.dart`
  - `fillProvider_rejectsEmptyInput_withStructuredInvalidPayloadResult`
  - `fillProvider_restoresRetryPendingState_afterResume`
- `test/features/study/presentation/providers/match_provider_test.dart`
  - `matchProvider_splitsLargeDeckIntoMultipleBoards`
  - `matchProvider_doesNotCompleteMode_whileFailedBoardNeedsRetry`

New test files recommended:
- `test/features/study/domain/session/study_session_engine_test.dart`
  - `performAction_returnsUpdatedSnapshot_withAllowedActions`
  - `performAction_rejectsInvalidAction_forCurrentState`
  - `session_executesModePlan_untilFinalModeCompletes`
  - `session_marksItemRetryPending_untilRemediationResolves`
- `test/features/study/domain/session/study_session_snapshot_test.dart`
  - `openSession_snapshotContainsSessionTypeModePlanCurrentItemAndProgress`
  - `resumeSession_snapshotContainsRestoredAllowedActions`
- `test/features/study/domain/factories/study_factory_resolution_test.dart`
  - `sessionTypeFactory_failsFast_whenNoHandlerExists`
  - `resultPresenterFactory_resolvesByBusinessKey`
- `test/features/study/data/repositories/study_repository_impl_test.dart`
  - `startSession_persistsDocsDefinedSessionAggregate_forResume`
  - `completeSession_persistsCompletionStatusAndSummaryFields`
- `test/features/study/data/datasources/study_local_datasource_test.dart`
  - `watchAll_emitsUpdatedSession_whenCompletionStateChanges`
- `test/features/study/presentation/screens/study_error_states_test.dart`
  - `showsUnauthorizedView_whenAccessIsDenied`
  - `showsErrorView_whenSessionStartFails`
- `test/features/study/domain/analytics/study_analytics_contract_test.dart`
  - `emitsSessionStartedModeEnteredAndCompletedEvents`
  - `emitsRetryRevealAndCompletionRateMetrics`
