# 1. Confirmed mismatches

- `M1. Generic session aggregate and snapshot contract is missing.`
  Doc evidence: `lib/features/study/docs/02_domain_model.md:31-45` requires `learner`, `session type`, `mode plan`, `current mode`, `current item`, `progress`, and `completion status` on the session. `lib/features/study/docs/02_domain_model.md:113-125` requires a generic snapshot with `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted`.
  Code evidence: `StudySession` only contains `id`, `mode`, `deckId`, timestamps, counts, and duration in `lib/features/study/domain/entities/study_session.dart:7-23`. `ActiveStudySessionSnapshot` only stores `deckId`, `mode`, optional `session`, and opaque `payload` in `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`.

- `M2. Start-session orchestration does not enforce the documented business contract.`
  Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:14-36` requires eligibility check, refusal with `nothing to study`, item selection, `sessionType` resolution, `modePlan` resolution, item snapshotting, and first snapshot creation. `lib/features/study/docs/07_use_cases_and_checklist.md` describes the same contract.
  Code evidence: `StartStudySessionUseCase` only forwards `deckId` and `mode` to the repository in `lib/features/study/domain/usecases/start_study_session.dart:5-13`. `StudyRepository` only exposes `startSession(deckId, mode)` in `lib/features/study/domain/repositories/study_repository.dart:4-13`. `StudyRepositoryImpl.startSession` only inserts a row in `lib/features/study/data/repositories/study_repository_impl.dart:27-42`.

- `M3. sessionType and modePlan are recommendation metadata, not runtime session state.`
  Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:27-36` and `lib/features/study/docs/03_session_lifecycle.md:61-72` treat `modePlan` as part of real session creation and completion. `lib/features/study/docs/01_business_context.md` and `lib/features/study/docs/04_mode_patterns.md` also frame study as a session that can span multiple modes.
  Code evidence: `BuildStudyDeckRecommendationUseCase` derives `sessionType` and `modePlan` in `lib/features/study/domain/usecases/build_study_deck_recommendation.dart:27-58`, but `StudyRecommendationCard` launches `primaryMode` directly in `lib/features/study/presentation/widgets/study_recommendation_card.dart:46-57`, and `StudyScreen` resolves directly to one mode screen in `lib/features/study/presentation/screens/study_screen.dart:93-109`.

- `M4. The docs-defined action/state contract is absent, and UI flow is inferred from local booleans.`
  Doc evidence: `lib/features/study/docs/05_execution_rules.md:3-17` says UI should not infer flow and the system should always return `current state` plus `allowed actions`. `lib/features/study/docs/05_execution_rules.md:18-45` defines generic states, actions, and outcomes.
  Code evidence: there is no `allowedActions` field in session or mode snapshot types. `review_provider.dart:104-114`, `guess_provider.dart:176-185`, `recall_provider.dart:168-173`, and `match_provider.dart:115-123` enforce legality through early returns. `study_mode_flow_factory.dart:17-59` is only a screen/progress helper, not a business-state resolver.

- `M5. Retry and completion semantics still drift from the docs in session-level completion and match-board failure handling.`
  Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:49-72` and `lib/features/study/docs/05_execution_rules.md:47-73` require failed items to stay retry-pending and block mode completion until resolved. Session completion should happen only after the final mode completes and no unresolved items remain.
  Code evidence: review, guess, fill, and recall now keep retry behavior inside the active mode, but every mode still calls `completeStudySessionUseCase` independently in `review_provider.dart:243-263`, `guess_provider.dart:291-310`, `recall_provider.dart:238-259`, `fill_provider.dart:368-388`, and `match_provider.dart:170-188`. Match also still completes through grouped-board progression without a docs-defined board fail/retry threshold in `lib/features/study/presentation/providers/match_provider.dart:203-260`.

- `M6. Persistence shape is too narrow for the documented resume and audit model.`
  Doc evidence: `lib/features/study/docs/02_domain_model.md:47-77` requires `Session Item` snapshots and `Attempt` records for analytics, audit, progress review, and reporting. `lib/features/study/docs/06_learning_lifecycle.md:40-50` requires resume to restore current mode, current item, progress, and allowed actions.
  Code evidence: persisted study session rows only mirror `StudySession` fields through `lib/features/study/data/mappers/study_session_mapper.dart` and `lib/features/study/data/repositories/study_repository_impl.dart:18-47`. Resume relies on one global SharedPreferences record keyed by `active_study_session_v1` with mode-specific opaque payload in `lib/features/study/presentation/providers/active_study_session_store.dart:11-117`.

- `M7. Long-term learning-state updates and analytics do not follow the documented completion boundary.`
  Doc evidence: `lib/features/study/docs/06_learning_lifecycle.md:30-37` says session outcome is short-term and learning state is long-term, and they should not be mixed. `lib/features/study/docs/03_session_lifecycle.md:68-72` and `lib/features/study/docs/06_learning_lifecycle.md:75-104` place learning-state update and analytics after session completion.
  Code evidence: mode providers write SRS updates and card reviews per attempt in `review_provider.dart:268-301`, `guess_provider.dart:342-379`, `recall_provider.dart:269-310`, and `match_provider.dart:276-317`. No analytics service, event contract, or event emission exists anywhere under `lib/features/study/**`.

- `M8. Negative paths, access/error states, factory coverage, and test coverage do not match the docs.`
  Doc evidence: `lib/features/study/docs/03_session_lifecycle.md:16-25` and `lib/features/study/docs/07_use_cases_and_checklist.md:20-30` require access denial and `nothing to study` handling. `lib/features/study/docs/07_use_cases_and_checklist.md:57-60` requires invalid action, invalid payload, timeout, and interruption flows. `lib/features/study/docs/08_factory_pattern.md` requires factory resolution by business key.
  Code evidence: `StudyScreen` and mode screens only expose hub, empty, in-progress, and completion states, with no unauthorized or container-not-found state in `lib/features/study/presentation/screens/study_screen.dart:93-109` and mode screens. The only factory is `StudyModeFlowFactory` in `lib/features/study/presentation/factories/study_mode_flow_factory.dart:17-59`. Existing tests lock in the simplified contract: `test/features/study/domain/usecases/start_study_session_test.dart:8-18`, `test/features/study/domain/usecases/complete_study_session_test.dart:8-31`, `test/features/study/presentation/screens/study_screen_test.dart:121-258`, `test/features/study/presentation/providers/recall_provider_test.dart:160-209`, and `test/features/study/presentation/providers/match_provider_test.dart:133-162`.

# 2. Root cause hypothesis for each mismatch

1. `M1`
   The feature was implemented from mode screens upward. A minimal persistence entity was enough for statistics, so the docs-defined session aggregate was never introduced as the runtime source of truth.

2. `M2`
   Session creation stayed coupled to mode-specific providers. That let each provider start quickly from existing deck/card queries, but it bypassed the documented start-session policy boundary.

3. `M3`
   Recommendation logic was added after the mode screens already existed. `modePlan` became a hub-ranking/output concern instead of becoming an executable session plan with its own state machine.

4. `M4`
   The implementation chose provider-local booleans because each mode already had unique interaction states. No normalized `allowedActions` or `modeState` DTO was introduced, so the UI and persistence layers now infer legality independently.

5. `M5`
   Retry behavior was implemented separately per mode for UX reasons. Review and guess got remediation loops first, while recall and match kept simpler completion rules. The missing session orchestrator made per-mode completion the path of least resistance.

6. `M6`
   Resume was optimized as a single SharedPreferences snapshot keyed by `deckId + mode`, not as a normalized session model. That shortcut made mode-level resume easy but left no place for session items, attempt logs, or multi-mode execution state.

7. `M7`
   Existing SRS and `CardReview` pipelines were reused directly inside mode providers. That avoided a separate completion/finalization layer, but it collapsed short-term session outcome and long-term learning-state decisions into the same write path.

8. `M8`
   The feature matured around happy-path UX and statistics screens. Negative business flows, factory fail-fast behavior, and analytics reporting stayed undocumented in code because there was no central session contract forcing those branches to exist and no tests demanding them.

# 3. Required code changes

1. `Introduce a docs-aligned session aggregate and snapshot contract`
- Why it is needed: The current `StudySession` and `ActiveStudySessionSnapshot` cannot represent the documented business contract for multi-mode execution, resume, allowed actions, progress, or completion status.
- Target files: `lib/features/study/domain/entities/study_session.dart`, `lib/features/study/domain/repositories/study_repository.dart`, `lib/features/study/data/mappers/study_session_mapper.dart`, `lib/features/study/presentation/providers/active_study_session_store.dart`, plus new session snapshot/value objects under `lib/features/study/domain/**` if needed.
- Expected change: Expand or replace the runtime session model so it can carry `sessionType`, `modePlan`, `activeMode`, `currentItem`, `progress`, `sessionCompleted`, `allowedActions`, and enough normalized mode state to resume safely across screens.
- Risk level: `high`

2. `Replace mode-local start with a real start-session orchestration boundary`
- Why it is needed: The docs require eligibility check, start refusal, item snapshotting, and first-snapshot return before any mode UI starts.
- Target files: `lib/features/study/domain/usecases/start_study_session.dart`, `lib/features/study/domain/repositories/study_repository.dart`, `lib/features/study/data/repositories/study_repository_impl.dart`, `lib/features/study/data/datasources/study_local_datasource.dart`, `lib/features/study/presentation/providers/study_hub_provider.dart`, `lib/features/study/presentation/screens/study_screen.dart`.
- Expected change: Replace `startSession(deckId, mode)` with a result-bearing start contract that can return explicit refusal reasons such as `nothingToStudy`, `unauthorized`, or `containerNotFound`, and return the first session snapshot on success.
- Risk level: `high`

3. `Turn modePlan into executable session state or remove it from user-facing runtime`
- Why it is needed: The docs and current hub copy imply a multi-mode study flow, but the runtime launches exactly one mode.
- Target files: `lib/features/study/domain/usecases/build_study_deck_recommendation.dart`, `lib/features/study/presentation/widgets/study_recommendation_card.dart`, `lib/features/study/presentation/screens/study_screen.dart`, `lib/features/study/presentation/providers/study_hub_provider.dart`, `lib/features/study/presentation/factories/study_mode_flow_factory.dart`.
- Expected change: Either add a session coordinator that executes `modePlan` across modes and only completes at the session level, or remove/de-emphasize `modePlan` from the hub until that runtime exists. The implementation path should favor the session coordinator because that is what the docs currently specify.
- Risk level: `high`

4. `Normalize legal actions and state transitions across modes`
- Why it is needed: The docs define `allowedActions`, generic states, generic outcomes, and `RESET_CURRENT_MODE`. Current UI and providers infer these separately.
- Target files: `lib/features/study/presentation/providers/review_provider.dart`, `lib/features/study/presentation/providers/guess_provider.dart`, `lib/features/study/presentation/providers/recall_provider.dart`, `lib/features/study/presentation/providers/fill_provider.dart`, `lib/features/study/presentation/providers/match_provider.dart`, `lib/features/study/presentation/factories/study_mode_flow_factory.dart`.
- Expected change: Add a normalized action/state layer so providers expose legal next actions explicitly, invalid actions can be rejected structurally, and resume/reset can restore the same legal state instead of recreating it from ad hoc flags.
- Risk level: `high`

5. `Align retry and completion semantics with the documented session rules`
- Why it is needed: Recall and match currently allow completion without a docs-style retry-pending loop, and every mode completes the persisted session independently.
- Target files: `lib/features/study/presentation/providers/review_provider.dart`, `lib/features/study/presentation/providers/guess_provider.dart`, `lib/features/study/presentation/providers/recall_provider.dart`, `lib/features/study/presentation/providers/fill_provider.dart`, `lib/features/study/presentation/providers/match_provider.dart`, `lib/features/study/presentation/screens/recall_mode_screen.dart`, `lib/features/study/presentation/screens/match_mode_screen.dart`.
- Expected change: Make retry-pending resolution part of the mode contract for all modes, remove per-mode final session completion, and let a session-level coordinator decide when the whole session is complete.
- Risk level: `high`

6. `Separate resumable session persistence from per-mode opaque payloads`
- Why it is needed: The current single-key SharedPreferences payload is too weak for documented resume, item snapshotting, and auditability.
- Target files: `lib/features/study/presentation/providers/active_study_session_store.dart`, `lib/features/study/data/datasources/study_local_datasource.dart`, `lib/features/study/data/repositories/study_repository_impl.dart`, `lib/features/study/domain/entities/study_session.dart`.
- Expected change: Version the persisted session snapshot, store normalized session progress instead of mode-specific opaque payloads, and ensure resume can restore current mode, current item, progress, and legal actions without depending on UI-specific state shape.
- Risk level: `high`

7. `Move analytics and long-term learning-state writes behind an explicit finalization boundary`
- Why it is needed: The docs separate short-term outcome from long-term learning-state update and require analytics signals that do not exist.
- Target files: `lib/features/study/domain/usecases/complete_study_session.dart`, `lib/features/study/domain/repositories/study_repository.dart`, `lib/features/study/presentation/providers/review_provider.dart`, `lib/features/study/presentation/providers/guess_provider.dart`, `lib/features/study/presentation/providers/recall_provider.dart`, `lib/features/study/presentation/providers/fill_provider.dart`, `lib/features/study/presentation/providers/match_provider.dart`.
- Expected change: Introduce a completion/finalization step that aggregates session outcomes, writes or confirms long-term learning-state updates, and emits session/mode/item analytics. If immediate per-attempt writes must remain, that choice needs to become an explicit policy with compensating analytics and rollback semantics.
- Risk level: `high`

8. `Add explicit refusal and error states to the study entry and mode flows`
- Why it is needed: The docs require `nothing to study`, access denial, invalid action, invalid payload, timeout, and interruption branches. The current implementation mostly returns early or falls back to generic async UI.
- Target files: `lib/features/study/presentation/screens/study_screen.dart`, `lib/features/study/presentation/widgets/study_hub_content.dart`, `lib/features/study/presentation/screens/review_mode_screen.dart`, `lib/features/study/presentation/screens/guess_mode_screen.dart`, `lib/features/study/presentation/screens/recall_mode_screen.dart`, `lib/features/study/presentation/screens/fill_mode_screen.dart`, `lib/features/study/presentation/screens/match_mode_screen.dart`.
- Expected change: Add explicit rendering and state branches for start refusal, unauthorized/no-access, structured invalid-action failures, and mode-specific timeout/error states instead of silent no-ops.
- Risk level: `medium`

9. `Replace the current UI-only factory with business-key resolution where the docs require it`
- Why it is needed: The docs define factory resolution for business handlers, not only for choosing a screen widget.
- Target files: `lib/features/study/presentation/factories/study_mode_flow_factory.dart`, `lib/features/study/domain/usecases/build_study_deck_recommendation.dart`, `lib/features/study/domain/support/study_session_type.dart`, plus new domain-side factory/resolver files under `lib/features/study/domain/**` if needed.
- Expected change: Reserve `StudyModeFlowFactory` for presentation concerns and introduce fail-fast resolution for business policy by `sessionType`, `activeMode`, outcome/evaluation policy, and result presentation where the docs demand it.
- Risk level: `medium`

# 4. Required test changes

1. `Replace the simple start/complete use-case tests with contract-level session tests`
- Why it is needed: `start_study_session_test.dart` and `complete_study_session_test.dart` currently prove only repository delegation, which hard-codes the wrong contract.
- Target files: `test/features/study/domain/usecases/start_study_session_test.dart`, `test/features/study/domain/usecases/complete_study_session_test.dart`, plus new tests under `test/features/study/domain/session/**`.
- Expected change: Add tests for eligibility refusal, `nothingToStudy`, `unauthorized`, `containerNotFound`, first snapshot creation, final-mode-only completion, retry-pending blocking, and completion-time finalization.
- Risk level: `high`

2. `Add persistence and resume tests for the docs-defined snapshot shape`
- Why it is needed: There are no tests guarding session-item snapshots, normalized resume state, or snapshot versioning.
- Target files: new `test/features/study/data/**` coverage for `study_local_datasource.dart`, `study_repository_impl.dart`, and `active_study_session_store.dart`.
- Expected change: Add integration-style tests that verify session aggregate persistence, resume restoration of `activeMode` and `allowedActions`, and safe behavior when snapshot schema changes.
- Risk level: `high`

3. `Add session-level UI and navigation tests`
- Why it is needed: `study_screen_test.dart` currently locks in direct single-mode routing and resume by `deckId + mode`.
- Target files: `test/features/study/presentation/screens/study_screen_test.dart`, plus new `test/features/study/presentation/screens/study_error_states_test.dart` if separation helps.
- Expected change: Cover session-start refusal UI, unauthorized UI, session-plan execution, resume of normalized session state, reset-current-mode behavior, and completion after the final mode rather than after one mode.
- Risk level: `high`

4. `Add negative-path tests for invalid action, invalid payload, timeout, and interruption`
- Why it is needed: The docs call these out explicitly, but provider tests only cover happy paths and a few local guard returns.
- Target files: `test/features/study/presentation/providers/review_provider_test.dart`, `guess_provider_test.dart`, `recall_provider_test.dart`, `fill_provider_test.dart`, `match_provider_test.dart`.
- Expected change: Add explicit assertions for structured rejection or timeout behavior instead of silent no-ops, especially for guess timeout, recall timeout/reveal penalty, fill empty-input policy, and match invalid selections.
- Risk level: `medium`

5. `Rewrite tests that currently encode divergent product behavior`
- Why it is needed: Some existing tests would block docs-aligned fixes by treating drift as the expected behavior.
- Target files: `test/features/study/presentation/providers/recall_provider_test.dart`, `test/features/study/presentation/providers/match_provider_test.dart`, `test/features/study/presentation/screens/study_screen_test.dart`.
- Expected change: Replace assumptions like post-completion recall practice and immediate match completion with the chosen session-level retry/completion policy.
- Risk level: `high`

6. `Add analytics contract tests`
- Why it is needed: The docs require event/reporting signals, but there is no testable contract today.
- Target files: new `test/features/study/domain/analytics/**` or `test/features/study/domain/session/**` coverage, depending on the chosen placement.
- Expected change: Verify emission of `session started`, `session resumed`, `session completed`, `mode entered`, `mode completed`, `item passed`, `item failed`, `item skipped`, `retry count`, `reveal usage`, and completion metrics.
- Risk level: `medium`

# 5. Required doc changes

1. `Clarify whether the docs describe the target architecture or historical design notes`
- Why it is needed: The current code is mode-first, while the docs are session-engine-first. Engineers need one source of truth before implementation work starts.
- Target files: `lib/features/study/docs/README.md`, `lib/features/study/docs/01_business_context.md`.
- Expected change: Add an explicit statement about whether `modePlan` and the session engine are current requirements or future-state architecture. If the docs remain the source of truth, say so directly.
- Risk level: `medium`

2. `Tighten the session contract wording around completion-time learning-state updates`
- Why it is needed: The docs recommend separation between session outcome and learning state, but they do not explicitly forbid per-attempt writes. That ambiguity blocks remediation choices.
- Target files: `lib/features/study/docs/03_session_lifecycle.md`, `lib/features/study/docs/06_learning_lifecycle.md`, `lib/features/study/docs/07_use_cases_and_checklist.md`.
- Expected change: State clearly whether long-term updates happen only after session completion, after each item, or via a hybrid model with explicit rollback/analytics semantics.
- Risk level: `medium`

3. `Clarify mode-specific edge policies that are currently open or drifting`
- Why it is needed: Guess timeout, recall timeout/reveal penalty, fill empty-input semantics, and match board grouping/failure thresholds are not specific enough to drive implementation or tests cleanly.
- Target files: `lib/features/study/docs/04_mode_patterns.md`, `lib/features/study/docs/05_execution_rules.md`.
- Expected change: Add explicit rules for timeout behavior, reveal penalty, empty input classification, retry loop boundaries, grouped boards, and match failure/completion thresholds.
- Risk level: `medium`

4. `Document or remove implementation-only UX behaviors`
- Why it is needed: Review flagging, recall post-completion practice, fill close-answer manual acceptance, guess small-deck warning, and match timer/star/combo UX are live behaviors with no doc backing.
- Target files: `lib/features/study/docs/04_mode_patterns.md`, `lib/features/study/docs/06_learning_lifecycle.md`.
- Expected change: Decide which current behaviors are intended product scope. Document the approved ones and explicitly drop the rest from code during remediation.
- Risk level: `low`

5. `Add an explicit analytics contract`
- Why it is needed: The docs list suggested analytics, but not event timing, payload ownership, or minimum required fields.
- Target files: `lib/features/study/docs/06_learning_lifecycle.md`, `lib/features/study/docs/07_use_cases_and_checklist.md`.
- Expected change: Define the minimum event list, when each event fires, and which event fields are required for BA/product reporting.
- Risk level: `low`

# 6. Recommended implementation order

1. Freeze the product decision on `modePlan`: executable session flow or single-mode recommendation only.
2. Define the session aggregate, snapshot, refusal result types, and completion policy in the domain contract.
3. Refactor repository and start/complete use cases to implement the new contract before touching mode UIs.
4. Replace the SharedPreferences opaque snapshot with the normalized resumable session shape.
5. Introduce a session coordinator over `modePlan` and move completion decisions there.
6. Rework mode providers to expose explicit legal actions and align retry/completion semantics, starting with recall and match because they diverge most from the docs.
7. Add start refusal, unauthorized, invalid-action, and timeout UI states on top of the new contract.
8. Add analytics/finalization behavior after the completion boundary is stable.
9. Rewrite and add tests after each contract stage so old simplified tests stop blocking the session-engine path.
10. Update markdown docs last, but before merge, so docs reflect the chosen implementation rather than the pre-remediation drift.

# 7. Low-risk quick wins

1. `Stop overstating modePlan in the hub until runtime supports it`
- Why it is needed: The current UI suggests a multi-step session that does not actually happen.
- Target files: `lib/features/study/presentation/widgets/study_recommendation_card.dart`, `lib/features/study/domain/usecases/build_study_deck_recommendation.dart`.
- Expected change: Either relabel the chips as a recommendation preview or reduce the primary CTA copy so it no longer implies the whole plan will run.
- Risk level: `low`

2. `Add explicit start refusal states before the full session refactor`
- Why it is needed: `nothing to study` and no-access are already required by docs and can be introduced without finishing the full multi-mode coordinator.
- Target files: `lib/features/study/presentation/screens/study_screen.dart`, `lib/features/study/presentation/widgets/study_hub_content.dart`, `lib/features/study/domain/usecases/start_study_session.dart`.
- Expected change: Return and render clear refusal reasons instead of falling through to mode-local empties or silent starts.
- Risk level: `low`

3. `Replace silent guard returns with visible invalid-action handling`
- Why it is needed: The current no-op behavior hides contract violations and makes debugging harder.
- Target files: `lib/features/study/presentation/providers/review_provider.dart`, `guess_provider.dart`, `recall_provider.dart`, `fill_provider.dart`, `match_provider.dart`.
- Expected change: Emit a structured invalid-action result or debug-visible failure path when an illegal action is attempted, even before the full `allowedActions` contract is in place.
- Risk level: `low`

4. `Add missing negative-path tests now`
- Why it is needed: Tests for unauthorized, invalid action, timeout, and resume-state restoration can be written incrementally and will expose hidden assumptions early.
- Target files: `test/features/study/domain/usecases/start_study_session_test.dart`, `test/features/study/presentation/screens/study_screen_test.dart`, `test/features/study/presentation/providers/*_provider_test.dart`.
- Expected change: Add failing tests for the highest-risk negative branches so the later implementation work is guided by executable expectations.
- Risk level: `low`

# 8. High-risk changes needing caution

1. `Persistence-schema and snapshot-shape migration`
- Why it is needed: Normalized session persistence is impossible without changing the current runtime shape.
- Target files: `lib/features/study/domain/entities/study_session.dart`, `lib/features/study/data/mappers/study_session_mapper.dart`, `lib/features/study/data/datasources/study_local_datasource.dart`, `lib/features/study/presentation/providers/active_study_session_store.dart`.
- Expected change: Introduce versioned snapshot handling and any required storage migration so existing in-progress sessions do not crash or silently corrupt resume.
- Risk level: `high`

2. `Session coordinator introduction across routing and provider ownership`
- Why it is needed: The current architecture routes directly to one mode and lets each provider own completion.
- Target files: `lib/features/study/presentation/screens/study_screen.dart`, `lib/features/study/presentation/factories/study_mode_flow_factory.dart`, all `*_provider.dart` files under `lib/features/study/presentation/providers/`.
- Expected change: Shift authority for progression, completion, and resume from individual mode providers to a session-level owner without creating provider-graph overlap or broken navigation.
- Risk level: `high`

3. `Moving long-term learning-state writes away from per-attempt updates`
- Why it is needed: If the docs remain correct, the current immediate writes have to move or be staged.
- Target files: `lib/features/study/presentation/providers/review_provider.dart`, `guess_provider.dart`, `recall_provider.dart`, `fill_provider.dart`, `match_provider.dart`, `lib/features/study/domain/usecases/complete_study_session.dart`.
- Expected change: Introduce staged outcomes, delayed finalization, or compensating writes. This can affect card scheduling, statistics, and failure recovery.
- Risk level: `high`

4. `Reworking recall and match completion semantics`
- Why it is needed: These two modes diverge most sharply from the docs and already have tests and UI flows built around the divergence.
- Target files: `lib/features/study/presentation/providers/recall_provider.dart`, `lib/features/study/presentation/providers/match_provider.dart`, `lib/features/study/presentation/screens/recall_mode_screen.dart`, `lib/features/study/presentation/screens/match_mode_screen.dart`, related tests.
- Expected change: Replace post-completion practice and immediate board completion with the chosen retry-pending/session-completion model, while preserving good UX and not regressing existing feedback surfaces.
- Risk level: `high`

# 9. Definition of done

- There is one explicit study-session contract in code that matches the chosen doc direction.
- Starting study returns either a valid first session snapshot or an explicit refusal reason such as `nothingToStudy`, `unauthorized`, or `containerNotFound`.
- Resume restores `activeMode`, `currentItem`, `progress`, and legal next actions from persisted state.
- `modePlan` is either executed as real runtime session state or removed from user-facing claims and docs.
- Mode completion no longer finalizes the overall session unless the documented session-completion rule is actually satisfied.
- Recall and match follow the chosen retry/completion policy, and that policy is documented.
- Long-term learning-state update timing is explicit and consistent between docs, code, and tests.
- Analytics has a defined minimum event contract and corresponding coverage, or the docs are trimmed so they no longer claim that contract.
- Negative paths for invalid action, invalid payload, timeout, interruption, unauthorized access, and empty eligibility are implemented or explicitly removed from the docs.
- Tests cover the session contract, persistence/resume behavior, mode execution, negative paths, and the highest-risk edge cases.
