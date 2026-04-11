# Study Compliance Checklist

Strict compliance review of `lib/features/study/**` against the markdown source of truth in `lib/features/study/docs/**`.

## Highest-risk FAIL and PARTIAL items

- Item 1 `FAIL`: the implementation has no docs-defined study-session aggregate with `sessionType`, `modePlan`, `currentMode`, `currentItem`, `progress`, and `completion status`.
- Item 2 `FAIL`: the docs-defined generic session snapshot and `allowedActions` contract do not exist.
- Item 5 `FAIL`: long-term learning-state updates are not kept as a completion-time concern; they happen per attempt.
- Item 11 `FAIL`: session creation does not snapshot items and return a first generic session snapshot.
- Item 13 `FAIL`: there is no multi-mode session completion path; each mode completes independently.
- Item 17 `FAIL`: the system does not return `allowedActions` at each step.
- Item 26 `FAIL`: the permission / unauthorized path required by the docs is not implemented.
- Item 38 `FAIL`: persistence does not store the docs-defined session contract.
- Item 40 `FAIL`: tests do not cover the generic session contract, `allowedActions`, analytics, permission handling, or multi-mode execution.

## Compliance checklist

### Business rules

1. **[FAIL] Session aggregate shape**
Requirement: The study session shall carry `learner`, `session type`, `mode plan`, `current mode`, `current item`, `progress`, and `completion status`.
Doc evidence: `lib/features/study/docs/02_domain_model.md:31-45`.
Implementation evidence: `StudySession` only contains `id`, `mode`, `deckId`, timestamps, counts, and duration in `lib/features/study/domain/entities/study_session.dart:8-19`.
Test coverage: `test/features/study/domain/usecases/start_study_session_test.dart:8-18` and `test/features/study/domain/usecases/complete_study_session_test.dart:8-31` only exercise the simplified `mode` + `deckId` contract.

2. **[FAIL] Generic session snapshot contract**
Requirement: Opening or resuming a session shall return `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted`.
Doc evidence: `lib/features/study/docs/02_domain_model.md:113-125`.
Implementation evidence: `ActiveStudySessionSnapshot` only stores `deckId`, `mode`, optional `session`, and opaque `payload` in `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`. `StudyModeFlowFactory` resolves per-mode payload parsing instead of a generic session snapshot in `lib/features/study/presentation/factories/study_mode_flow_factory.dart:17-59`.
Test coverage: `test/features/study/presentation/screens/study_screen_test.dart:81-119` and `test/features/study/presentation/screens/study_screen_test.dart:260-366` only validate resume by `deckId` + `mode`.

3. **[FAIL] Session-item snapshot model**
Requirement: The session shall keep per-item snapshots with prompt/answer snapshot, metadata, sequence, mode completion, retry flag, and last outcome.
Doc evidence: `lib/features/study/docs/02_domain_model.md:47-63`.
Implementation evidence: There is no `SessionItem` symbol or equivalent feature-local entity. Per-mode snapshots are encoded as ad hoc maps in providers such as `review_provider.dart:384-400`, `guess_provider.dart:434-470`, `recall_provider.dart:382-398`, and `fill_provider.dart:550-578`.
Test coverage: No inspected test under `test/features/study/**` asserts a session-item snapshot contract.

4. **[PARTIAL] Attempt logging**
Requirement: Attempt-level interaction data shall be recorded for analytics, audit, progress review, debug, and reporting.
Doc evidence: `lib/features/study/docs/02_domain_model.md:65-77`, `lib/features/study/docs/02_domain_model.md:127-133`.
Implementation evidence: Each mode inserts review rows into `CardReviewsTable`, for example in `lib/features/study/presentation/providers/review_provider.dart:290-301`, `lib/features/study/presentation/providers/guess_provider.dart:366-379`, `lib/features/study/presentation/providers/recall_provider.dart:297-310`, `lib/features/study/presentation/providers/fill_provider.dart:475-489`, and `lib/features/study/presentation/providers/match_provider.dart:306-317`. There is still no generic attempt entity, no analytics event stream, and no feature-local audit model.
Test coverage: Mode tests assert review inserts, for example `test/features/study/presentation/providers/guess_provider_test.dart:148-156` and `test/features/study/presentation/providers/recall_provider_test.dart:66-72`.

5. **[FAIL] Long-term learning state is a completion-time concern**
Requirement: Session outcome is short-term; learning state is long-term and should be updated after completion rather than mixed into the in-session flow.
Doc evidence: `lib/features/study/docs/06_learning_lifecycle.md:30-37`, `lib/features/study/docs/07_use_cases_and_checklist.md:79-95`.
Implementation evidence: Card SRS fields are updated on each attempt inside mode providers before session completion, for example `review_provider.dart:268-283`, `guess_provider.dart:342-359`, `recall_provider.dart:274-290`, `fill_provider.dart:452-468`, and `match_provider.dart:283-299`.
Test coverage: `test/features/study/domain/srs/srs_engine_test.dart:169-228` validates per-attempt adapters, but no inspected test verifies a completion-time aggregation/update policy.

6. **[PARTIAL] Session type is a business policy**
Requirement: Session type shall drive item selection, mode plan, session length/difficulty, and completion rule.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:74-87`.
Implementation evidence: `BuildStudyDeckRecommendationUseCase` computes `sessionType` and `modePlan` in `lib/features/study/domain/usecases/build_study_deck_recommendation.dart:43-57`, but runtime execution still launches a single mode from `StudyScreen` in `lib/features/study/presentation/screens/study_screen.dart:97-99`. No completion-rule or difficulty policy is tied to `StudySessionType`.
Test coverage: `test/features/study/domain/usecases/build_study_deck_recommendation_test.dart:14-85` only verifies recommendation selection.

7. **[FAIL] Factory coverage for business behavior**
Requirement: The study feature shall resolve business behavior through factories for session type, mode plan, study mode, outcome evaluation, and result presentation, with fail-fast resolution.
Doc evidence: `lib/features/study/docs/08_factory_pattern.md:36-76`, `lib/features/study/docs/08_factory_pattern.md:128-160`.
Implementation evidence: The only factory is `StudyModeFlowFactory`, which resolves screen builders, progress parsing, and restart callbacks in `lib/features/study/presentation/factories/study_mode_flow_factory.dart:17-59`. No feature-local factory resolves session-type handlers, evaluators, or result presenters.
Test coverage: No inspected test asserts factory resolution beyond screen routing.

8. **[FAIL] Analytics and reporting contract**
Requirement: The feature shall emit analytics/reporting data such as session started/resumed/completed, mode entered/completed, item passed/failed/skipped, retry count, reveal usage, average time per item, and completion rate.
Doc evidence: `lib/features/study/docs/06_learning_lifecycle.md:75-104`.
Implementation evidence: The study feature persists session rows in `lib/features/study/data/repositories/study_repository_impl.dart:18-42` and per-item reviews in provider methods, but no analytics/event API or reporting emitter is present in the inspected `lib/features/study/**` files.
Test coverage: No inspected test under `test/features/study/**` verifies analytics/reporting events.

### User flow

9. **[FAIL] Eligibility check before session creation**
Requirement: Session creation shall check learner permission, eligible items, and applicable session type before a session is created.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:14-25`, `lib/features/study/docs/07_use_cases_and_checklist.md:11-25`.
Implementation evidence: `StartStudySessionUseCase` only forwards `deckId` and `mode` in `lib/features/study/domain/usecases/start_study_session.dart:10-13`, and `StudyRepositoryImpl.startSession` immediately inserts a session row in `lib/features/study/data/repositories/study_repository_impl.dart:27-42`. There is no learner or permission input in the feature-local session API.
Test coverage: `test/features/study/domain/usecases/start_study_session_test.dart:8-18` explicitly locks in the delegate-only contract.

10. **[PARTIAL] Nothing-to-study refusal**
Requirement: If no eligible item exists, the system shall refuse session creation with a clear `nothing to study` equivalent.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:22-25`.
Implementation evidence: Providers return empty per-mode state and skip session creation when card lists are empty in `review_provider.dart:350-364`, `guess_provider.dart:398-415`, `recall_provider.dart:347-360`, `fill_provider.dart:518-530`, and `match_provider.dart:359-363`. There is still no generic refusal result or reason on `StartStudySessionUseCase`.
Test coverage: Empty UI is covered in `test/features/study/presentation/screens/study_screen_test.dart:36-57` and `test/features/study/presentation/screens/review_mode_screen_test.dart:230-254`.

11. **[FAIL] Session creation returns the first generic session snapshot**
Requirement: Creating a session shall select items, snapshot them into the session, set the initial mode and item, and return the first session snapshot.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:27-36`.
Implementation evidence: Mode providers construct mode-local state after calling `startStudySessionUseCaseProvider`, for example `review_provider.dart:366-376`, `guess_provider.dart:417-426`, `recall_provider.dart:363-374`, and `fill_provider.dart:532-542`. The use case itself does not return a docs-defined snapshot.
Test coverage: No inspected use-case or provider test asserts a generic first-session snapshot contract.

12. **[PARTIAL] Retry loop before mode completion**
Requirement: Failed items shall remain incomplete, be marked retry-pending, and be revisited before the mode completes.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:49-60`, `lib/features/study/docs/05_execution_rules.md:54-73`.
Implementation evidence: Review re-queues `again` cards in `review_provider.dart:158-191`; guess re-queues wrong/skipped cards in `guess_provider.dart:208-219` and `guess_provider.dart:320-327`; fill keeps the same card in retry in `fill_provider.dart:288-290` and `fill_provider.dart:390-437`; recall now keeps missed cards in-session through `retryPendingCardIds` until the retry is resolved in `recall_provider.dart:111-125` and `recall_provider.dart:220-259`. Match now advances across grouped boards in `match_provider.dart:203-260`, but it still does not expose a docs-defined board fail or retry-pending contract.
Test coverage: `test/features/study/presentation/providers/review_provider_test.dart:129-162`, `test/features/study/presentation/providers/guess_provider_test.dart:87-156`, `test/features/study/presentation/providers/recall_provider_test.dart:160-209`, and `test/features/study/presentation/providers/match_provider_test.dart:73-162`.

13. **[FAIL] Session completion after final mode and no pending retry**
Requirement: The session shall complete only after the final mode completes and no retry-pending items remain.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:61-72`, `lib/features/study/docs/07_use_cases_and_checklist.md:73-95`.
Implementation evidence: Each mode completes its own `StudySession` independently in `review_provider.dart:243-263`, `guess_provider.dart:291-310`, `recall_provider.dart:238-259`, `fill_provider.dart:368-388`, and `match_provider.dart:170-188`. There is no multi-mode coordinator over `modePlan`.
Test coverage: `test/features/study/domain/usecases/complete_study_session_test.dart:8-31` only verifies repository delegation for a single passed-in session.

14. **[PARTIAL] Resume restores current mode, item, progress, and legal next actions**
Requirement: Resuming an active session shall restore current mode, current item, progress, and legal next actions.
Doc evidence: `lib/features/study/docs/06_learning_lifecycle.md:38-50`.
Implementation evidence: Per-mode restore paths recreate cards/current index/results in `review_provider.dart:419-470`, `guess_provider.dart:489-546`, `recall_provider.dart:417-459`, and `fill_provider.dart:597-646`. The feature does not restore a generic session with `sessionType`, `modePlan`, or explicit `allowedActions`.
Test coverage: `test/features/study/presentation/screens/study_screen_test.dart:260-366` covers resume prompting, not a generic restored-action contract.

15. **[PARTIAL] Reset current mode**
Requirement: The current mode can be restarted by clearing current-mode progress according to policy.
Doc evidence: `lib/features/study/docs/06_learning_lifecycle.md:51-62`, `lib/features/study/docs/05_execution_rules.md:32-38`.
Implementation evidence: `StudyScreen` clears the saved snapshot and reruns the current mode via `StudyModeFlowFactory.restartSession` in `lib/features/study/presentation/screens/study_screen.dart:70-90` and `lib/features/study/presentation/factories/study_mode_flow_factory.dart:103-116`. There is no explicit `RESET_CURRENT_MODE` action returned by state.
Test coverage: `test/features/study/presentation/screens/study_screen_test.dart:305-313` covers the `Start over` UI path.

16. **[PARTIAL] Exit policy**
Requirement: Exit behavior shall clearly determine whether partial state is saved, whether partial analytics are written, and whether re-entry resumes or opens a new session.
Doc evidence: `lib/features/study/docs/06_learning_lifecycle.md:63-74`.
Implementation evidence: Mode screens prompt for exit and simply pop on confirmation, for example `review_mode_screen.dart:73-85` and `match_mode_screen.dart:74-85`. Snapshot persistence keeps in-progress mode state until completion in `review_provider.dart:402-417`, `guess_provider.dart:472-487`, `recall_provider.dart:400-415`, and `fill_provider.dart:580-595`. No feature-local analytics or expiry policy is implemented.
Test coverage: Exit-resume persistence is covered by `test/features/study/presentation/screens/review_mode_screen_test.dart:316-344`, `test/features/study/presentation/screens/fill_mode_screen_test.dart:191-222`, and `test/features/study/presentation/screens/study_screen_test.dart:315-366`.

### Input and output behavior

17. **[FAIL] Each step returns explicit `allowedActions`**
Requirement: The system shall return the current state together with explicit legal actions so the UI does not infer workflow transitions on its own.
Doc evidence: `lib/features/study/docs/05_execution_rules.md:3-17`.
Implementation evidence: Mode providers expose ad hoc state objects without an `allowedActions` field, for example in `lib/features/study/presentation/providers/guess_provider.dart:115-174`, `lib/features/study/presentation/providers/recall_provider.dart:95-125`, `lib/features/study/presentation/providers/fill_provider.dart:240-306`, and `lib/features/study/presentation/providers/match_provider.dart:112-151`. UI widgets branch on local booleans and enums instead of consuming an explicit action contract.
Test coverage: No inspected test asserts an `allowedActions` response contract.

18. **[PASS] Review mode follows the documented reveal-and-rate flow**
Requirement: Review mode shall present one card, allow reveal, then record a quality rating that advances or retries according to the rating.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:39-63`.
Implementation evidence: Review reveal and rating flow is implemented through `revealAnswer`, `rateCard`, retry handling, and progression in `lib/features/study/presentation/providers/review_provider.dart:130-240`. The UI renders the front/back and rating actions in `lib/features/study/presentation/widgets/review_round_view.dart:35-139`.
Test coverage: `test/features/study/presentation/providers/review_provider_test.dart:129-195` and `test/features/study/presentation/screens/review_mode_screen_test.dart:60-162`.

19. **[PASS] Guess mode grades selections and applies remediation**
Requirement: Guess mode shall present multiple choices, grade the selection, and route wrong or skipped items through remediation before finalizing them.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:133-157`.
Implementation evidence: `selectOption`, `skipQuestion`, and wrong/skipped finalization are implemented in `lib/features/study/presentation/providers/guess_provider.dart:176-339`. The UI presents the prompt, options, and feedback in `lib/features/study/presentation/widgets/guess_round_view.dart:83-165`.
Test coverage: `test/features/study/presentation/providers/guess_provider_test.dart:87-156` and `test/features/study/presentation/screens/guess_mode_screen_test.dart:71-177`.

20. **[PARTIAL] Recall mode only partially matches the documented reveal/self-assessment flow**
Requirement: Recall mode shall support attempt, reveal, self-assessment, and the documented remediation/timeout handling.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:181-208`.
Implementation evidence: Reveal, missed marking, self-rating, and in-session retry handling exist in `lib/features/study/presentation/providers/recall_provider.dart:95-267`. The implementation does not expose docs-defined timeout handling or reveal-penalty behavior, but missed cards now remain retry-pending inside the same recall session until resolved.
Test coverage: `test/features/study/presentation/providers/recall_provider_test.dart:36-95` and `test/features/study/presentation/providers/recall_provider_test.dart:160-209`.

21. **[PARTIAL] Fill mode only partially matches the documented submit/retry/remediation contract**
Requirement: Fill mode shall evaluate typed answers, distinguish correct/close/wrong outcomes, expose retries, and apply the documented remediation path.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:230-260`.
Implementation evidence: Submit, close-answer handling, retry, skip, hint, and finalization are implemented in `lib/features/study/presentation/providers/fill_provider.dart:240-437` with feedback UI in `lib/features/study/presentation/widgets/fill_feedback_panel.dart:30-157`. The feature still operates as a mode-local workflow without a docs-defined generic outcome envelope or explicit legal-action contract.
Test coverage: `test/features/study/presentation/providers/fill_provider_test.dart:38-159` and `test/features/study/presentation/screens/fill_mode_screen_test.dart:29-189`.

22. **[PARTIAL] Match mode only partially matches the documented pass/fail/retry contract**
Requirement: Match mode shall build matching groups, score correct and wrong pairs, and integrate with the documented retry/completion rules.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:85-110`.
Implementation evidence: Board construction, correct/wrong handling, grouped-board progression, and completion are implemented in `lib/features/study/presentation/providers/match_provider.dart:170-271` and `lib/features/study/domain/match/match_engine.dart:25-63`. The implementation now advances across grouped boards, but it still completes once all generated pairs are matched and does not model a docs-defined board fail or retry-pending session contract.
Test coverage: `test/features/study/presentation/providers/match_provider_test.dart:73-162`.

### Validation rules

23. **[PASS] Fill answer evaluation policy is implemented**
Requirement: Fill evaluation shall normalize answers and distinguish exact, close, and wrong outcomes according to the documented evaluation policy.
Doc evidence: `lib/features/study/docs/05_execution_rules.md:74-96`, `lib/features/study/docs/04_mode_patterns.md:230-247`.
Implementation evidence: `FillEngine.evaluate` returns exact/close/wrong results in `lib/features/study/domain/fill/fill_engine.dart:22-34`, and normalization/fuzzy comparison are implemented in `lib/features/study/domain/fill/fuzzy_matcher.dart:22-45`.
Test coverage: `test/features/study/domain/fill/fill_engine_test.dart:55-65` and `test/features/study/domain/fill/fuzzy_matcher_test.dart:7-29`.

24. **[NOT SPECIFIED CLEARLY] The docs do not fully define synonym, reveal-penalty, or empty-input policy**
Requirement: Validation rules should state what counts as acceptable synonymy, whether reveal without attempt is penalized, and how empty input should be handled.
Doc evidence: `lib/features/study/docs/05_execution_rules.md:78-87` leaves answer-policy details at a question level rather than a final rule.
Implementation evidence: Fill submit gating and reveal behavior are implemented in `lib/features/study/presentation/providers/fill_provider.dart:244-259` and `lib/features/study/presentation/providers/recall_provider.dart:95-109`, but the docs do not define a strict contract to compare against.
Test coverage: `test/features/study/presentation/providers/recall_provider_test.dart:36-51` and `test/features/study/presentation/providers/fill_provider_test.dart:100-130` verify current product decisions, not a fully specified doc rule.

25. **[FAIL] Invalid action and invalid payload rejection is not modeled as a formal contract**
Requirement: Performing an action shall reject illegal actions or invalid payloads with a clear failure result.
Doc evidence: `lib/features/study/docs/07_use_cases_and_checklist.md:42-66`.
Implementation evidence: Providers use guard returns such as `review_provider.dart:108-114`, `guess_provider.dart:179-185`, `recall_provider.dart:168-173`, `fill_provider.dart:244-259`, and `match_provider.dart:115-123`, but these do not produce a docs-defined generic rejection result or error payload.
Test coverage: No inspected test verifies an invalid-action contract with explicit failure output.

### Error handling and edge cases

26. **[FAIL] Unauthorized or permission-denied flow is absent**
Requirement: Session start shall fail cleanly when the learner is not allowed to study, and the feature shall expose that refusal path.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:16-20`, `lib/features/study/docs/07_use_cases_and_checklist.md:26-30`.
Implementation evidence: Feature-local APIs do not accept a learner/permission context in `lib/features/study/domain/repositories/study_repository.dart:4-13` or `lib/features/study/domain/usecases/start_study_session.dart:10-13`, and `lib/features/study/data/repositories/study_repository_impl.dart:27-42` always creates a session row when invoked.
Test coverage: No inspected test references unauthorized, permission-denied, or forbidden paths.

27. **[NOT SPECIFIED CLEARLY] Error-state UI contract is not fully defined by the docs**
Requirement: If the feature expects explicit error surfaces, the docs should define what error UI states must exist and how they differ from empty states.
Doc evidence: The inspected docs define lifecycle failures but do not prescribe a concrete UI-state taxonomy for async failures under `lib/features/study/docs/**`.
Implementation evidence: Screens route async rendering through `AppAsyncBuilder` in `lib/features/study/presentation/screens/study_screen.dart:101-109`, `lib/features/study/presentation/screens/review_mode_screen.dart:39-70`, `lib/features/study/presentation/screens/guess_mode_screen.dart:28-50`, `lib/features/study/presentation/screens/recall_mode_screen.dart:41-72`, `lib/features/study/presentation/screens/fill_mode_screen.dart:45-78`, and `lib/features/study/presentation/screens/match_mode_screen.dart:29-71`, but there is no doc-defined behavior to judge these surfaces against.
Test coverage: No inspected test explicitly covers async error rendering or failure recovery.

28. **[PASS] Guess mode handles small choice sets**
Requirement: Guess mode shall still operate when a deck does not provide enough distractors by using a fallback strategy.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:142-146`.
Implementation evidence: `GuessEngine.generateOptions` injects placeholder distractors when there are too few cards in `lib/features/study/domain/guess/guess_engine.dart:38-81`.
Test coverage: `test/features/study/domain/guess/guess_engine_test.dart:27-39` and `test/features/study/presentation/screens/guess_mode_screen_test.dart:58-69`.

29. **[FAIL] Timeout handling is not implemented**
Requirement: Modes that allow timeout-driven failure or reveal shall implement that behavior explicitly.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:144-146`, `lib/features/study/docs/04_mode_patterns.md:194-196`, `lib/features/study/docs/07_use_cases_and_checklist.md:57-62`.
Implementation evidence: Guess only exposes manual skip in `lib/features/study/presentation/providers/guess_provider.dart:249-281`, and recall only exposes manual reveal and rating in `lib/features/study/presentation/providers/recall_provider.dart:95-195`. No timeout scheduler or timer-based transition exists in the inspected feature files.
Test coverage: No inspected test covers timeout-triggered transitions or timeout-specific failures.

30. **[PARTIAL] Large match sets now advance across grouped boards, but board-level fail/retry semantics remain missing**
Requirement: Match mode shall handle larger item sets by grouping or batching them according to the documented board constraints.
Doc evidence: `lib/features/study/docs/04_mode_patterns.md:93-99`.
Implementation evidence: `MatchEngine.generatePairs` still caps each round to five pairs in `lib/features/study/domain/match/match_engine.dart:25-63`, and `MatchProvider` now advances `boardIndex` / `completedPairCount` across grouped boards in `lib/features/study/presentation/providers/match_provider.dart:203-260`. The remaining gap is not grouping itself; it is the missing board-level fail/retry policy.
Test coverage: `test/features/study/domain/match/match_engine_test.dart:9-30`, `test/features/study/presentation/providers/match_provider_test.dart:171-207`, and `test/features/study/presentation/screens/match_mode_screen_test.dart:170-248`.

### State management

31. **[PARTIAL] Mode state is represented, but not through the generic docs-defined state model**
Requirement: Study execution shall move through a generic state model where each mode reports status, current item, progress, and completion outcome in a comparable structure.
Doc evidence: `lib/features/study/docs/05_execution_rules.md:18-26`.
Implementation evidence: Each mode has its own state object and booleans, for example in `lib/features/study/presentation/providers/guess_provider.dart:221-228`, `lib/features/study/presentation/providers/recall_provider.dart:176-185`, `lib/features/study/presentation/providers/fill_provider.dart:265-289`, and `lib/features/study/presentation/providers/match_provider.dart:245-270`. There is no shared state envelope spanning all modes.
Test coverage: Mode-local state behavior is tested, but no inspected test asserts a generic cross-mode state contract.

32. **[FAIL] Legal actions are inferred by UI instead of derived by the state machine**
Requirement: The system shall decide which actions are legal, and the UI shall render from that contract rather than reconstructing it.
Doc evidence: `lib/features/study/docs/05_execution_rules.md:9-17`.
Implementation evidence: Widgets infer available actions from local state flags in `lib/features/study/presentation/widgets/guess_round_view.dart:136-165`, `lib/features/study/presentation/widgets/recall_writing_area.dart:27-63`, `lib/features/study/presentation/widgets/review_round_view.dart:60-139`, and `lib/features/study/presentation/widgets/fill_round_view.dart:95-129`. No provider returns a normalized allowed-action set.
Test coverage: No inspected widget or provider test verifies a state-driven allowed-action contract.

### UI states

33. **[NOT SPECIFIED CLEARLY] Loading-state requirements are not explicit in the docs**
Requirement: If loading indicators or blocking states are required, the docs should specify when they appear and what they must show.
Doc evidence: The inspected docs describe lifecycle and flow semantics but do not prescribe concrete loading-state requirements under `lib/features/study/docs/**`.
Implementation evidence: Screens use `AppAsyncBuilder` for async loading in `lib/features/study/presentation/screens/study_screen.dart:101-109`, `lib/features/study/presentation/screens/review_mode_screen.dart:39-70`, `lib/features/study/presentation/screens/guess_mode_screen.dart:28-50`, `lib/features/study/presentation/screens/recall_mode_screen.dart:41-72`, `lib/features/study/presentation/screens/fill_mode_screen.dart:45-78`, and `lib/features/study/presentation/screens/match_mode_screen.dart:29-71`.
Test coverage: No inspected test covers loading-state rendering.

34. **[PARTIAL] Empty and nothing-to-study UI exists, but only per mode**
Requirement: When nothing is eligible to study, the feature shall present a clear empty or refusal state.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:22-25`.
Implementation evidence: The hub and mode screens render empty states in `lib/features/study/presentation/widgets/study_hub_content.dart:17-23`, `lib/features/study/presentation/screens/review_mode_screen.dart:149-154`, `lib/features/study/presentation/screens/guess_mode_screen.dart:74-80`, `lib/features/study/presentation/screens/recall_mode_screen.dart:110-116`, `lib/features/study/presentation/screens/fill_mode_screen.dart:137-143`, and `lib/features/study/presentation/widgets/match_round_view.dart:22-28`. The docs-defined generic refusal result is still absent.
Test coverage: `test/features/study/presentation/screens/study_screen_test.dart:36-57` and `test/features/study/presentation/screens/review_mode_screen_test.dart:230-254`.

35. **[PARTIAL] Success and completion UI is implemented per mode, not as a session-level result contract**
Requirement: Completion shall surface the final outcome after the session finishes, including the mode or session summary described by the docs.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:68-72`.
Implementation evidence: Completion summaries are rendered by each mode screen in `lib/features/study/presentation/screens/review_mode_screen.dart:157-217`, `lib/features/study/presentation/screens/guess_mode_screen.dart:103-178`, `lib/features/study/presentation/screens/recall_mode_screen.dart:118-197`, `lib/features/study/presentation/screens/fill_mode_screen.dart:145-210`, and `lib/features/study/presentation/screens/match_mode_screen.dart:89-145`. There is no session-level result presenter spanning a full `modePlan`.
Test coverage: `test/features/study/presentation/screens/review_mode_screen_test.dart:60-90`, `test/features/study/presentation/screens/guess_mode_screen_test.dart:71-121`, `test/features/study/presentation/providers/recall_provider_test.dart:133-158`, `test/features/study/presentation/screens/fill_mode_screen_test.dart:87-124`, and `test/features/study/presentation/providers/match_provider_test.dart:133-162`.

36. **[NOT SPECIFIED CLEARLY] Offline behavior is not defined by the docs**
Requirement: If offline handling is relevant, the docs should define whether offline is a supported distinct UI or error state.
Doc evidence: No inspected document under `lib/features/study/docs/**` defines offline-specific behavior.
Implementation evidence: The feature is local-first via `lib/features/study/data/datasources/study_local_datasource.dart:3-29` and does not expose offline-specific branches in the inspected `lib/features/study/**` files.
Test coverage: No inspected test covers offline behavior.

### Persistence behavior

37. **[PASS] Session start and completion persistence exists**
Requirement: The feature shall persist study sessions and mark them complete when the active mode or session is finished.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:27-36`, `lib/features/study/docs/03_session_lifecycle.md:61-72`.
Implementation evidence: Session rows are created and completed in `lib/features/study/data/repositories/study_repository_impl.dart:18-42` through `lib/features/study/data/datasources/study_local_datasource.dart:15-29`, with mapping in `lib/features/study/data/mappers/study_session_mapper.dart:19-35`.
Test coverage: `test/features/study/domain/usecases/start_study_session_test.dart:8-18` and `test/features/study/domain/usecases/complete_study_session_test.dart:8-31`.

38. **[FAIL] Persisted session shape does not match the docs-defined contract**
Requirement: Persistence shall retain the docs-defined session contract, including session type, mode plan, active mode, current item, progress, and resumable state.
Doc evidence: `lib/features/study/docs/02_domain_model.md:113-125`, `lib/features/study/docs/03_session_lifecycle.md:29-36`.
Implementation evidence: The persisted entity only stores a simplified session row in `lib/features/study/domain/entities/study_session.dart:8-19` and `lib/features/study/data/mappers/study_session_mapper.dart:19-35`. Resume state is stored separately as mode-specific payload in `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`, not as the docs-defined session aggregate.
Test coverage: `test/features/study/presentation/screens/study_screen_test.dart:81-119` and `test/features/study/presentation/screens/study_screen_test.dart:260-366` cover mode-specific snapshot resume only.

### Test coverage

39. **[PASS] Mode-specific domain logic and provider flows are covered**
Requirement: Where the implementation chooses per-mode behavior, tests should verify the main happy paths and core remediation rules.
Doc evidence: The docs describe deterministic per-mode rules in `lib/features/study/docs/04_mode_patterns.md`.
Implementation evidence: Domain algorithms are covered in `test/features/study/domain/fill/fill_engine_test.dart:8-65`, `test/features/study/domain/guess/guess_engine_test.dart:9-39`, `test/features/study/domain/match/match_engine_test.dart:9-32`, `test/features/study/domain/srs/fuzzy_matcher_test.dart:7-29`, and `test/features/study/domain/srs/srs_engine_test.dart:10-228`. Provider and screen flows are covered across `test/features/study/presentation/providers/*` and `test/features/study/presentation/screens/*`.
Test coverage: This item is itself satisfied by the inspected suite.

40. **[FAIL] Tests do not cover the generic session contract or several required failure paths**
Requirement: The docs imply coverage should exist for generic session execution, action legality, analytics/reporting, permission failure, and other critical session policies.
Doc evidence: `lib/features/study/docs/02_domain_model.md:113-125`, `lib/features/study/docs/05_execution_rules.md:3-45`, `lib/features/study/docs/06_learning_lifecycle.md:75-104`, and `lib/features/study/docs/07_use_cases_and_checklist.md:11-95`.
Implementation evidence: No inspected test under `test/features/study/**` covers a generic multi-mode executor, explicit `allowedActions`, invalid action rejection, unauthorized behavior, offline behavior, loading-state rendering, async error rendering, analytics events, or repository/data-layer persistence integration.
Test coverage: The absence is visible across the inspected suite; the closest tests are only minimal delegation tests in `test/features/study/domain/usecases/start_study_session_test.dart:8-18` and `test/features/study/domain/usecases/complete_study_session_test.dart:8-31`.

41. **[FAIL] Several tests lock in behavior that conflicts with the docs-derived contract**
Requirement: Tests should not normalize behavior that contradicts the docs-derived session contract.
Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:27-87`, `lib/features/study/docs/05_execution_rules.md:3-73`, and `lib/features/study/docs/06_learning_lifecycle.md:38-104`.
Implementation evidence: The suite locks in single-mode start/complete contracts in `test/features/study/domain/usecases/start_study_session_test.dart:8-18` and `test/features/study/domain/usecases/complete_study_session_test.dart:8-31`; direct mode launch instead of `modePlan` execution in `test/features/study/presentation/screens/study_screen_test.dart:121-227`; grouped-board progression rather than a docs-defined board fail/retry contract in `test/features/study/presentation/providers/match_provider_test.dart:171-207`; and mode-specific resume payloads in `test/features/study/presentation/screens/study_screen_test.dart:260-366`.
Test coverage: The cited tests actively encode the divergent behavior.

## Files inspected

Docs:
- `D:\workspace\memox\AGENTS.md`
- `D:\workspace\memox\lib\features\study\docs\01_overview.md`
- `D:\workspace\memox\lib\features\study\docs\02_domain_model.md`
- `D:\workspace\memox\lib\features\study\docs\03_session_lifecycle.md`
- `D:\workspace\memox\lib\features\study\docs\04_mode_patterns.md`
- `D:\workspace\memox\lib\features\study\docs\05_execution_rules.md`
- `D:\workspace\memox\lib\features\study\docs\06_learning_lifecycle.md`
- `D:\workspace\memox\lib\features\study\docs\07_use_cases_and_checklist.md`
- `D:\workspace\memox\lib\features\study\docs\08_factory_pattern.md`

Implementation:
- All inspected files under `D:\workspace\memox\lib\features\study\domain\`
- All inspected files under `D:\workspace\memox\lib\features\study\data\`
- All inspected files under `D:\workspace\memox\lib\features\study\presentation\`

Tests used as evidence:
- All inspected files under `D:\workspace\memox\test\features\study\domain\`
- All inspected files under `D:\workspace\memox\test\features\study\presentation\`
