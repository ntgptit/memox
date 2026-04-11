# 1. Docs discovered

## Normative source docs used for requirement normalization

- `lib/features/study/docs/README.md`
  - Declares the doc set as a generic, BA-first `study engine` spec and gives the intended reading order and mapping to implementation concerns (`README.md:3-35`).
- `lib/features/study/docs/01_business_context.md`
  - Defines product goals, glossary, actors, and the minimum business capabilities for the study engine (`01_business_context.md:32-123`).
- `lib/features/study/docs/02_domain_model.md`
  - Defines the business entities, their relationships, the generic session snapshot, and the data that should be recorded during and after study (`02_domain_model.md:31-135`).
- `lib/features/study/docs/03_session_lifecycle.md`
  - Defines eligibility, session creation, active learning, retry handling, session completion, and session types (`03_session_lifecycle.md:3-96`).
- `lib/features/study/docs/04_mode_patterns.md`
  - Defines the business goal, inputs, actions, grading intent, completion rule, and alternative flows for review, match, guess, recall, and fill modes (`04_mode_patterns.md:3-260`).
- `lib/features/study/docs/05_execution_rules.md`
  - Defines the action-state contract, generic mode states, generic actions and outcomes, and the retry/remediation model (`05_execution_rules.md:3-78`).
- `lib/features/study/docs/06_learning_lifecycle.md`
  - Defines the learning-state update model, resume/reset/exit, and analytics/reporting expectations (`06_learning_lifecycle.md:3-103`).
- `lib/features/study/docs/07_use_cases_and_checklist.md`
  - Defines the start-session, perform-action, and complete-session use cases, including alternative flows (`07_use_cases_and_checklist.md:3-95`).
- `lib/features/study/docs/08_factory_pattern.md`
  - Defines where factory resolution should exist and the fail-fast rule for missing implementations (`08_factory_pattern.md:36-190`).

## Non-normative or secondary docs that were still read

- `lib/features/study/docs/09_adoption_template.md`
  - This is a generic adoption template for other projects, not a MemoX-specific product contract, but it reinforces the eight core concepts the study feature is expected to model (`09_adoption_template.md:3-47`).
- `lib/features/study/docs/review/study-compliance-checklist.md`
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-remediation-plan.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`

These `docs/review/*.md` files are prior analysis artifacts, not source-of-truth requirements. They were read because the task required recursive markdown discovery, but the normalized requirement model below is grounded in `README.md` and `01` through `08`, with `09` treated as generic meta guidance.

# 2. Normalized requirements

## Feature goals

1. The feature is meant to be a `study engine`, not just a single quiz screen. It should choose content, run one bounded study session, collect reliable learning signals, decide retry/completion, update long-term learning state, and expose result/analytics data (`01_business_context.md:34-45`, `01_business_context.md:107-123`).
2. The primary product goals are stronger long-term recall, less mistimed or redundant study, measurable progress evidence, and automated decisions about what should be learned, reviewed, or repeated (`01_business_context.md:46-60`).
3. The docs explicitly separate business rules from UI layout, framework, API, and schema details. The requirement model is therefore behavior-first and contract-first (`01_business_context.md:25-30`, `README.md:23-35`).

## Business rules

1. A `Study Session` is a core business aggregate and should carry at least `learner`, `session type`, `mode plan`, `current mode`, `current item`, `progress`, and `completion status` (`02_domain_model.md:31-45`).
2. A `Session Item` must snapshot the learning item inside the session so the session does not depend on source data mutating mid-run. It should carry prompt snapshot, answer snapshot, sequence, mode-completion state, retry flag, and last outcome (`02_domain_model.md:47-64`).
3. An `Attempt` is a first-class business record used for analytics, audit, progress review, debugging, and reporting (`02_domain_model.md:65-77`).
4. A generic open-or-resume contract should return a session snapshot containing `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted` (`02_domain_model.md:113-125`).
5. A session must not be created unless the learner is eligible, the container is valid, and at least one item is eligible to study. If no eligible item exists, the system should refuse to create the session and return `nothing to study` or equivalent (`03_session_lifecycle.md:14-25`, `07_use_cases_and_checklist.md:11-35`).
6. When a session is created, the system must select items, determine `sessionType`, determine `modePlan`, snapshot items into the session, set the initial mode/item, and return the first session snapshot (`03_session_lifecycle.md:27-36`, `07_use_cases_and_checklist.md:17-25`).
7. The system should always enforce an action-state contract: at any moment the user may perform only actions valid for the current state, and the UI should not infer the flow on its own (`05_execution_rules.md:3-17`).
8. Failure and retry are explicit business concepts. A failed item is not complete in the current mode, becomes retry-pending, and must be revisited before the mode completes (`03_session_lifecycle.md:49-60`, `05_execution_rules.md:47-70`).
9. A session completes only when the final mode completes and there are no unresolved items left under that session's completion rule (`03_session_lifecycle.md:61-72`, `07_use_cases_and_checklist.md:67-95`).
10. Session outcome is a short-term signal. Long-term learning-state update is a separate concern and should not be silently collapsed into per-attempt logic unless the product explicitly chooses that policy (`06_learning_lifecycle.md:7-37`).
11. Business logic selection should be resolved by business-key factories such as `sessionType`, `activeMode`, `answerType`, and `resultType`, with fail-fast behavior if an implementation is missing (`08_factory_pattern.md:36-60`, `08_factory_pattern.md:128-160`).

## User flows

1. Start session:
   - learner chooses container
   - system checks eligibility
   - system selects eligible items
   - system determines `sessionType`
   - system determines `modePlan`
   - system creates session and returns the first current item/snapshot
   (`07_use_cases_and_checklist.md:5-35`, `03_session_lifecycle.md:14-36`).
2. Perform action in active mode:
   - user performs one legal action
   - system validates the action
   - system evaluates outcome
   - system records the attempt
   - system updates session-item state
   - system returns the next session snapshot
   (`07_use_cases_and_checklist.md:36-65`, `03_session_lifecycle.md:38-47`).
3. Retry handling:
   - unresolved items move into retry-pending
   - when the first pass ends, the mode either opens a retry loop or completes
   (`03_session_lifecycle.md:49-60`, `05_execution_rules.md:47-70`).
4. Complete session:
   - once final-mode completion rules are satisfied, the system aggregates final outcomes, updates long-term learning state, produces result summary, and emits analytics/reporting signals
   (`03_session_lifecycle.md:68-72`, `07_use_cases_and_checklist.md:67-95`, `06_learning_lifecycle.md:75-103`).
5. Resume session:
   - an active session can be resumed
   - current mode, current item, progress, and allowed actions must be restored correctly
   (`06_learning_lifecycle.md:38-50`).
6. Reset current mode:
   - the current mode can be restarted from the beginning
   - current-mode progress and attempts may be cleared depending on policy
   (`06_learning_lifecycle.md:51-62`, `05_execution_rules.md:30-37`).
7. Exit session:
   - the feature must define whether partial state is saved, whether partial analytics are written, and whether re-entry resumes or starts a new session
   (`06_learning_lifecycle.md:63-74`).
8. Per-mode flows:
   - review: show item, user self-rates remembered or retry, record outcome, go next (`04_mode_patterns.md:28-63`)
   - match: generate pairs, user matches, system checks completeness/accuracy, record outcome, next or retry (`04_mode_patterns.md:75-110`)
   - guess: show prompt and choices, user selects answer, system grades, record outcome, go next (`04_mode_patterns.md:123-157`)
   - recall: show prompt only, reveal by user action or timeout, self-assess remembered or retry, record outcome, go next (`04_mode_patterns.md:170-208`)
   - fill: user types answer, system grades exact/close/wrong, correct goes next, wrong goes to retry or reveal by policy (`04_mode_patterns.md:220-260`)

## Validations

1. Session start validation must cover valid learner, valid learning container, and at least one eligible item (`07_use_cases_and_checklist.md:11-15`, `03_session_lifecycle.md:16-20`).
2. Action execution validation must ensure the session is active, a current item exists, and the action is inside `allowedActions` (`07_use_cases_and_checklist.md:42-47`, `05_execution_rules.md:7-17`).
3. Invalid action and invalid answer payload are explicit alternative flows and should be rejected as such, not treated as undefined behavior (`07_use_cases_and_checklist.md:57-65`).
4. Fill-mode evaluation requires an explicit answer policy, including how exact, normalized, close, and wrong answers are classified (`04_mode_patterns.md:226-253`).
5. Guess mode requires a choice set with a valid correct answer and reasonable distractors (`04_mode_patterns.md:129-146`).
6. Recall mode requires a defined reveal policy (`04_mode_patterns.md:176-188`).
7. Match mode requires that the content can be represented as pairs or grouped boards (`04_mode_patterns.md:81-98`).

## Edge cases

1. No eligible item exists: return `nothing to study` and do not create a session (`03_session_lifecycle.md:22-25`, `07_use_cases_and_checklist.md:26-35`).
2. Learner is unauthorized or the container does not exist: explicit alternative flow on start (`07_use_cases_and_checklist.md:26-35`).
3. Invalid action in current state: explicit rejection path (`07_use_cases_and_checklist.md:57-65`).
4. Invalid answer payload: explicit rejection path (`07_use_cases_and_checklist.md:57-65`).
5. Timeout or interruption: explicit alternative flow for perform-action and mode-specific alternatives in guess and recall (`07_use_cases_and_checklist.md:57-65`, `04_mode_patterns.md:142-147`, `04_mode_patterns.md:192-197`).
6. Fill-mode special cases: empty input, partially correct input, normalized-correct but exact-wrong input, reveal-assisted input (`04_mode_patterns.md:242-248`).
7. Match-mode special cases: missing pairs, wrong matches, large boards split into smaller groups (`04_mode_patterns.md:93-103`).

## UI states

1. Session-entry loading, success, and error are implied because session start and hub/recommendation data are async concerns (`03_session_lifecycle.md:14-36`, `README.md:23-35`).
2. `nothing to study` or equivalent empty/refusal state is explicitly required when no eligible items exist (`03_session_lifecycle.md:22-25`).
3. An active study state must render the current item in the current mode and expose only legal actions (`03_session_lifecycle.md:38-47`, `05_execution_rules.md:7-17`).
4. A retry-pending/retry-loop state is required when failures remain after the first pass (`03_session_lifecycle.md:49-60`, `05_execution_rules.md:47-70`).
5. A completion/result-summary state is required after session completion (`03_session_lifecycle.md:68-72`, `07_use_cases_and_checklist.md:77-84`).
6. Resume, reset-current-mode, and exit are required business surfaces even though exact layout is intentionally unspecified (`06_learning_lifecycle.md:38-74`, `01_business_context.md:25-30`).
7. Unauthorized or inaccessible-container state is required at study start, even though the docs do not define the exact UI treatment (`07_use_cases_and_checklist.md:26-35`).

## State transitions

1. Generic mode states are `INITIALIZED`, `IN_PROGRESS`, `WAITING_FEEDBACK`, `RETRY_PENDING`, and `COMPLETED` (`05_execution_rules.md:18-26`).
2. Generic legal actions are `SUBMIT_ANSWER`, `REVEAL_ANSWER`, `MARK_REMEMBERED`, `RETRY_ITEM`, `GO_NEXT`, and `RESET_CURRENT_MODE` (`05_execution_rules.md:28-38`).
3. Generic outcomes are `PASSED`, `FAILED`, and `SKIPPED` (`05_execution_rules.md:39-45`).
4. After a failed item, the system transitions the item to retry-pending instead of directly completing it (`03_session_lifecycle.md:49-60`, `05_execution_rules.md:54-70`).
5. Resume must restore both progress and legal next actions, which means the state transition model must be reconstructible from persisted data (`06_learning_lifecycle.md:44-50`).

## Data flow

1. Input data:
   - learner
   - learning container
   - eligible learning items
   (`01_business_context.md:94-105`, `03_session_lifecycle.md:16-20`).
2. Session-creation output:
   - session aggregate
   - session items
   - first session snapshot
   (`02_domain_model.md:31-64`, `03_session_lifecycle.md:27-36`).
3. Per-action writes:
   - attempt record
   - session-item state update
   - updated session snapshot
   (`02_domain_model.md:65-77`, `07_use_cases_and_checklist.md:48-65`).
4. Completion-time writes:
   - final item outcomes
   - long-term learning-state update
   - result summary
   - analytics/reporting events
   (`03_session_lifecycle.md:68-72`, `06_learning_lifecycle.md:75-103`, `07_use_cases_and_checklist.md:77-95`).

## Testable scenarios

1. Create a session successfully with a valid learner/container and eligible items.
2. Refuse session start when nothing is eligible.
3. Refuse session start for unauthorized learner or missing container.
4. Return a generic session snapshot with `allowedActions`.
5. Reject invalid actions and invalid payloads.
6. Open a retry loop when failed items remain.
7. Complete the full session only after final-mode completion.
8. Resume an active session with correct mode/item/progress/actions restored.
9. Apply mode-specific behavior for review, match, guess, recall, and fill.
10. Emit long-term update and analytics only at the defined completion boundary.

# 3. Implementation summary

## Domain and data

- The runtime domain model is mode-first and minimal. `StudySession` is a small persistence entity with `id`, `mode`, `deckId`, timestamps, counts, and duration, but no `sessionType`, `modePlan`, `currentMode`, `currentItem`, `progress`, or `completion status` (`lib/features/study/domain/entities/study_session.dart:7-23`).
- `StudyRepository` exposes only `watchAll()`, `startSession(deckId, mode)`, and `completeSession(session)` (`lib/features/study/domain/repositories/study_repository.dart:4-13`).
- `StartStudySessionUseCase` and `CompleteStudySessionUseCase` only delegate to the repository; they do not encode eligibility, refusal reasons, or a snapshot contract (`lib/features/study/domain/usecases/start_study_session.dart:5-13`, `lib/features/study/domain/usecases/complete_study_session.dart:4-10`).
- `StudyRepositoryImpl` just saves a `StudySession` row through `StudyLocalDataSource`; there is no feature-local persistence for session items, attempts, or a normalized session snapshot (`lib/features/study/data/repositories/study_repository_impl.dart:18-47`, `lib/features/study/data/datasources/study_local_datasource.dart:3-29`, `lib/features/study/data/mappers/study_session_mapper.dart:5-36`).
- The feature does contain reusable mode engines:
  - `FillEngine` for answer grading and prompt generation (`lib/features/study/domain/fill/fill_engine.dart:16-133`)
  - `GuessEngine` for shuffling and distractor generation (`lib/features/study/domain/guess/guess_engine.dart:13-81`)
  - `MatchEngine` for board generation and pair checking (`lib/features/study/domain/match/match_engine.dart:9-67`)
  - `SRSEngine` for long-term scheduling decisions (`lib/features/study/domain/srs/srs_engine.dart:19-220`)

## Recommendation and hub

- `BuildStudyDeckRecommendationUseCase` derives `sessionType` and `modePlan` from current card status and due dates (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:21-101`).
- `study_hub_provider.dart` builds deck recommendations and loads the currently active saved snapshot (`lib/features/study/presentation/providers/study_hub_provider.dart:11-90`).
- `StudyHubContent` renders an entry surface with:
  - empty state when there are no recommendations and no active session
  - active-session card when a saved snapshot exists
  - recommendation card plus deck picker for further decks
  (`lib/features/study/presentation/widgets/study_hub_content.dart:10-49`).

## Session persistence and navigation

- `ActiveStudySessionStore` stores exactly one saved session snapshot in SharedPreferences or memory under `active_study_session_v1`. That snapshot carries only `deckId`, `mode`, optional `StudySession`, and arbitrary mode-specific `payload` (`lib/features/study/presentation/providers/active_study_session_store.dart:11-117`).
- `StudyScreen` has two entry modes:
  - hub mode when `deckId` and `mode` are absent
  - direct routing to one mode screen when `deckId` and `mode` are present
  (`lib/features/study/presentation/screens/study_screen.dart:15-111`).
- `StudyScreen` also implements a per-mode resume/start-over prompt by comparing the route's `(deckId, mode)` with the saved snapshot (`lib/features/study/presentation/screens/study_screen.dart:44-91`).
- `StudyActiveSessionCard` resumes or clears the one saved per-mode snapshot and calculates progress from mode-specific payload shape (`lib/features/study/presentation/widgets/study_active_session_card.dart:15-85`).

## Mode execution

- `StudyModeFlowFactory` is a presentation-layer resolver that maps a single `StudyMode` to:
  - a screen widget
  - a progress extractor for the mode's payload
  - a restart callback
  (`lib/features/study/presentation/factories/study_mode_flow_factory.dart:15-116`).
- Each mode owns its own provider/state machine and its own start/complete flow:
  - review: `review_provider.dart`
  - guess: `guess_provider.dart`
  - recall: `recall_provider.dart`
  - fill: `fill_provider.dart`
  - match: `match_provider.dart`
- Each provider persists and restores its own payload shape into `ActiveStudySessionStore`, and each provider calls `completeStudySessionUseCase` when that single mode decides it is complete (`review_provider.dart:243-263`, `guess_provider.dart:291-310`, `recall_provider.dart:238-259`, `fill_provider.dart:368-388`, `match_provider.dart:170-188`).

# 4. Matches

1. The implementation does recognize the concepts of `sessionType` and `modePlan` at the recommendation layer. `BuildStudyDeckRecommendationUseCase` computes both from deck/card state (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:43-81`). This is narrower than the docs, but it does match the requirement that session type and mode plan exist as business concepts.
2. The feature implements all five documented study modes with separate mode-specific logic, screens, and widgets:
   - review
   - match
   - guess
   - recall
   - fill
   (`lib/features/study/presentation/providers/*.dart`, `lib/features/study/presentation/screens/*_mode_screen.dart`).
3. Review and guess implement a real retry queue inside the current mode, which aligns with the docs' retry-pending concept at least for those two modes (`lib/features/study/presentation/providers/review_provider.dart:158-191`, `lib/features/study/presentation/providers/guess_provider.dart:193-219`).
4. The feature supports resuming an interrupted study run, albeit only as a per-mode snapshot. `StudyScreen` prompts to resume, and `ActiveStudySessionStore` persists the snapshot (`lib/features/study/presentation/screens/study_screen.dart:55-91`, `lib/features/study/presentation/providers/active_study_session_store.dart:89-117`).
5. The hub does implement loading/error/empty/success entry behavior:
   - loading and error through `AppAsyncBuilder`
   - empty through `EmptyStateView`
   - success through `StudyHubContent`
   (`lib/features/study/presentation/screens/study_screen.dart:101-109`, `lib/features/study/presentation/widgets/study_hub_content.dart:15-49`).
6. The feature does have a presentation-level factory, which partially matches the docs' desire to centralize mode selection rather than scattering `switch` logic (`lib/features/study/presentation/factories/study_mode_flow_factory.dart:30-62`).

# 5. Missing implementation

1. There is no docs-defined study-session aggregate. The runtime session model does not carry `learner`, `sessionType`, `modePlan`, `currentMode`, `currentItem`, `progress`, or `completion status` (`02_domain_model.md:31-45` versus `lib/features/study/domain/entities/study_session.dart:7-23`).
2. There is no generic session snapshot contract. The implementation does not expose `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted` as one normalized DTO (`02_domain_model.md:113-125` versus `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`).
3. Session creation does not implement eligibility checking, refusal reasons, item snapshotting, or first-snapshot return. It only persists a row (`03_session_lifecycle.md:14-36`, `07_use_cases_and_checklist.md:5-35` versus `lib/features/study/domain/usecases/start_study_session.dart:5-13`, `lib/features/study/data/repositories/study_repository_impl.dart:27-42`).
4. `modePlan` is not executable runtime state. The hub computes it, but starting study launches `primaryMode` directly rather than a session that traverses the plan (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:49-81`, `lib/features/study/presentation/widgets/study_recommendation_card.dart:46-57`, `lib/features/study/presentation/screens/study_screen.dart:97-109`).
5. The action-state contract is not normalized. There is no `allowedActions`, and legal interaction is enforced by provider-local early returns instead of a shared business-state model (`05_execution_rules.md:3-17` versus `lib/features/study/presentation/providers/review_provider.dart:304-348`, `guess_provider.dart:183-185`, `recall_provider.dart:168-173`, `fill_provider.dart:181-187`, `match_provider.dart:115-123`).
6. Session items and attempts are not modeled inside the feature-local persistence contract. The docs require them explicitly (`02_domain_model.md:47-77`), but the feature stores only one session row plus an opaque per-mode payload (`lib/features/study/data/mappers/study_session_mapper.dart:5-36`, `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`).
7. Session completion is not session-level. Each mode completes the persisted session independently when that single mode decides it is done (`03_session_lifecycle.md:61-72`, `07_use_cases_and_checklist.md:67-95` versus `review_provider.dart:243-263`, `guess_provider.dart:291-310`, `recall_provider.dart:238-259`, `fill_provider.dart:368-388`, `match_provider.dart:170-188`).
8. Match still does not implement the docs' board-level retry-pending completion rule. Recall now keeps missed cards in-session until the retry is resolved, but match still completes once each grouped board sequence is cleared and never models a board-level fail/retry contract (`04_mode_patterns.md:181-208`, `05_execution_rules.md:47-70` versus `lib/features/study/presentation/providers/recall_provider.dart:111-125`, `220-259`, `lib/features/study/presentation/providers/match_provider.dart:203-260`).
9. Long-term learning-state update is not clearly separated from short-term session outcome. The feature writes SRS/card-review data inside per-attempt mode handlers (`06_learning_lifecycle.md:30-37` versus `lib/features/study/presentation/providers/review_provider.dart:268-301`, `guess_provider.dart:342-379`, `recall_provider.dart:269-310`, `match_provider.dart:276-317`, `fill_provider.dart:167-175`, `272-289`).
10. No analytics/reporting contract is implemented under `lib/features/study/**`, despite explicit analytics expectations in the docs (`06_learning_lifecycle.md:75-103`).
11. Unauthorized, missing-container, invalid-payload, timeout, and interruption flows are not implemented as explicit study-feature contracts. The docs require these branches, but the implementation mostly uses silent guard returns or generic async error handling (`07_use_cases_and_checklist.md:26-35`, `57-65`; `04_mode_patterns.md:142-147`, `192-197`).
12. The docs require business-side factory resolution by business keys with fail-fast semantics. The implementation only has a UI-oriented `StudyModeFlowFactory` and no domain-side session type / evaluator / result presenter factories (`08_factory_pattern.md:36-60`, `128-160` versus `lib/features/study/presentation/factories/study_mode_flow_factory.dart:15-116`).

# 6. Extra implementation not specified by docs

1. Review-mode flagging is implemented in `ReviewSession.toggleFlag()` (`lib/features/study/presentation/providers/review_provider.dart:304-320`), but the docs never define flagging as a study-mode action or outcome.
2. Review-mode keyboard shortcuts exist in `review_rating_shortcuts.dart` (`lib/features/study/presentation/widgets/review_rating_shortcuts.dart:5-81`), but the docs intentionally avoid detailed UI controls and do not specify keyboard behavior.
4. Fill mode supports manual handling of `close` answers through `rejectClose()` and `acceptClose()` (`lib/features/study/presentation/providers/fill_provider.dart:144-176`). The docs mention close and reveal/remediation policies, but not this manual accept/reject UX.
5. Guess mode inserts placeholder distractors (`'???'`) when there are not enough real choices (`lib/features/study/domain/guess/guess_engine.dart:16-18`, `38-80`). The docs require reasonable distractors but do not authorize placeholder answers as a fallback policy.
6. Match mode includes gamification-style timer, combo count, and star rating (`lib/features/study/presentation/providers/match_provider.dart:41-49`, `203-206`; `lib/features/study/presentation/widgets/match_elapsed_timer_text.dart:7-47`; `lib/features/study/presentation/widgets/match_star_rating.dart:6-27`). None of these are described in the docs.

# 7. Ambiguities or contradictions across docs

1. `Exit Session` policy is intentionally unresolved. `06_learning_lifecycle.md:63-74` asks whether partial state should be saved, whether partial analytics should be written, and whether re-entry resumes or starts fresh. The docs therefore require the scenario but do not choose the policy.
2. `Reset Current Mode` exists as a required action, but the docs do not settle whether session identity is preserved or a new mode run is created (`06_learning_lifecycle.md:51-62`).
3. `Learning state update timing` is directionally clear but not fully closed. `06_learning_lifecycle.md:30-37` recommends separating session outcome from long-term learning state, while `03_session_lifecycle.md:68-72` places the update after session completion. The docs do not explicitly state whether immediate per-item writes are forbidden or whether a hybrid staged-write model is acceptable.
4. Several mode-specific policies are underspecified:
   - guess timeout policy is named but not quantified (`04_mode_patterns.md:142-147`)
   - recall reveal penalty is named but not quantified (`04_mode_patterns.md:192-197`)
   - fill reveal/remediation policy is named but not concretely resolved (`04_mode_patterns.md:238-247`)
   - match retry threshold and grouped-board completion policy are implied but not fully formalized (`04_mode_patterns.md:93-103`)
5. `08_factory_pattern.md` mixes generic design guidance with references to another project (`lumos`) and example factory names (`08_factory_pattern.md:162-190`). That section is still useful architecturally, but it is less direct as a MemoX-specific requirement source than `01` through `07`.
6. `09_adoption_template.md` is not contradictory, but it is meta-level guidance for porting the model to other projects. It should not be treated as a feature-specific contract on equal footing with `01` through `08`.

# 8. High-risk deviations

1. The docs describe a session-engine architecture with a normalized session aggregate and generic session snapshot, but the implementation is mode-first and single-mode at runtime. This is the highest-risk drift because it affects domain, data, UI flow, persistence, and future extensibility at once.
2. `modePlan` is visible to users as recommendation output but is not actual runtime state. That creates direct product drift: the UI implies a multi-step guided session while the code starts only one mode.
3. Session completion is implemented at the mode level, not the session level. This breaks the docs' completion model and makes completion metrics, analytics, and long-term update timing unreliable against the documented contract.
4. The implementation cannot restore the docs-defined resume state because persisted state lacks `sessionType`, `activeMode`, `allowedActions`, normalized progress, and session-item/audit data.
5. Long-term learning-state writes currently happen inside attempt handlers. If the docs remain the source of truth, this means the feature is mixing short-term session outcome and long-term scheduling policy in a way the spec explicitly warns against.
6. The absence of explicit refusal/unauthorized/invalid-payload/timeout contracts means negative paths are largely undefined in implementation even though they are first-class scenarios in the docs.

# 9. Suggested next actions

1. Freeze the source of truth.
   - Decide explicitly that `README.md` plus `01` through `08` are the normative contract for MemoX study, and treat `09` plus `docs/review/*.md` as secondary guidance.
2. Introduce one normalized session contract in code.
   - Add a domain-level session aggregate and resumable snapshot shape that can carry `sessionType`, `modePlan`, `activeMode`, `currentItem`, `progress`, `allowedActions`, and completion status.
3. Refactor start-session into a real orchestration boundary.
   - Replace `startSession(deckId, mode)` with a result-bearing use case that can refuse with explicit reasons and return the first session snapshot on success.
4. Resolve the `modePlan` product decision.
   - Either implement a session coordinator that actually traverses `modePlan`, or remove/de-emphasize `modePlan` from user-facing runtime claims until that exists.
5. Normalize action/state handling.
   - Stop relying on provider-local boolean guards as the only legality mechanism. Expose legal actions and state transitions explicitly from the business layer.
6. Align completion and retry policy across all modes.
   - Review, guess, recall, match, and fill should all fit one documented retry/completion model, or the docs must be narrowed to the chosen product behavior.
7. Define negative-path policy explicitly.
   - Close the open gaps for unauthorized, container-not-found, invalid-action, invalid-payload, timeout, interruption, reset, and exit behavior.
8. Decide and document long-term update timing.
   - Either move SRS writes behind a completion/finalization boundary or explicitly document a hybrid policy and implement it consistently.

# 10. Files inspected

## Docs

- `lib/features/study/docs/README.md`
- `lib/features/study/docs/01_business_context.md`
- `lib/features/study/docs/02_domain_model.md`
- `lib/features/study/docs/03_session_lifecycle.md`
- `lib/features/study/docs/04_mode_patterns.md`
- `lib/features/study/docs/05_execution_rules.md`
- `lib/features/study/docs/06_learning_lifecycle.md`
- `lib/features/study/docs/07_use_cases_and_checklist.md`
- `lib/features/study/docs/08_factory_pattern.md`
- `lib/features/study/docs/09_adoption_template.md`
- `lib/features/study/docs/review/study-compliance-checklist.md`
- `lib/features/study/docs/review/study-doc-vs-implementation-review.md`
- `lib/features/study/docs/review/study-remediation-plan.md`
- `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md`
- `lib/features/study/docs/review/study-ui-and-state-flow-review.md`

## Source

All `.dart` files under `lib/features/study/**` were included in the source sweep. The findings above are grounded primarily in the control-path files below, with render-only widgets consulted where they introduced behavior rather than pure presentation.

### Data

- `lib/features/study/data/datasources/study_local_datasource.dart`
- `lib/features/study/data/mappers/study_session_mapper.dart`
- `lib/features/study/data/repositories/study_repository_impl.dart`

### Domain

- `lib/features/study/domain/entities/study_session.dart`
- `lib/features/study/domain/fill/fill_engine.dart`
- `lib/features/study/domain/guess/guess_engine.dart`
- `lib/features/study/domain/match/match_engine.dart`
- `lib/features/study/domain/repositories/study_repository.dart`
- `lib/features/study/domain/srs/fuzzy_matcher.dart`
- `lib/features/study/domain/srs/srs_engine.dart`
- `lib/features/study/domain/support/study_session_type.dart`
- `lib/features/study/domain/usecases/build_study_deck_recommendation.dart`
- `lib/features/study/domain/usecases/complete_study_session.dart`
- `lib/features/study/domain/usecases/start_study_session.dart`

### Presentation state and routing

- `lib/features/study/presentation/factories/study_mode_flow_factory.dart`
- `lib/features/study/presentation/providers/active_study_session_store.dart`
- `lib/features/study/presentation/providers/fill_provider.dart`
- `lib/features/study/presentation/providers/guess_provider.dart`
- `lib/features/study/presentation/providers/match_provider.dart`
- `lib/features/study/presentation/providers/next_due_deck_provider.dart`
- `lib/features/study/presentation/providers/recall_provider.dart`
- `lib/features/study/presentation/providers/review_provider.dart`
- `lib/features/study/presentation/providers/study_engine_providers.dart`
- `lib/features/study/presentation/providers/study_hub_provider.dart`
- `lib/features/study/presentation/providers/study_session_active_provider.dart`
- `lib/features/study/presentation/screens/fill_mode_screen.dart`
- `lib/features/study/presentation/screens/guess_mode_screen.dart`
- `lib/features/study/presentation/screens/match_mode_screen.dart`
- `lib/features/study/presentation/screens/recall_mode_screen.dart`
- `lib/features/study/presentation/screens/review_mode_screen.dart`
- `lib/features/study/presentation/screens/study_screen.dart`

### Behavior-relevant widgets

- `lib/features/study/presentation/widgets/match_elapsed_timer_text.dart`
- `lib/features/study/presentation/widgets/match_star_rating.dart`
- `lib/features/study/presentation/widgets/review_rating_shortcuts.dart`
- `lib/features/study/presentation/widgets/study_active_session_card.dart`
- `lib/features/study/presentation/widgets/study_hub_content.dart`
- `lib/features/study/presentation/widgets/study_recommendation_card.dart`
