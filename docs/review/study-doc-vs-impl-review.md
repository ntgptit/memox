## 1. Feature summary from doc

The markdown under `lib/features/study/docs/` describes a generic study engine, not just a collection of isolated screens.

- The core business object is a study session that should carry `learner`, `session type`, `mode plan`, `current mode`, `current item`, `progress`, and `completion status` (`lib/features/study/docs/02_domain_model.md:31-45`).
- The runtime contract for opening or resuming a session is a generic session snapshot that includes `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted` (`lib/features/study/docs/02_domain_model.md:113-125`).
- Session creation should perform eligibility checks, return `nothing to study` when appropriate, select items, determine `sessionType`, determine `modePlan`, snapshot items into the session, set the initial mode/item, and return the first snapshot (`lib/features/study/docs/03_session_lifecycle.md:14-36`, `lib/features/study/docs/07_use_cases_and_checklist.md:5-35`).
- Active learning is defined as an action-state contract: the system should always return current state plus `allowedActions`, and the UI should not infer the flow on its own (`lib/features/study/docs/05_execution_rules.md:3-17`).
- Failed items are supposed to remain incomplete, enter `retry pending`, and be revisited in a retry loop before a mode can complete (`lib/features/study/docs/03_session_lifecycle.md:49-60`, `lib/features/study/docs/05_execution_rules.md:47-73`).
- Session completion should happen only after the final mode completes and no retry-pending items remain, then the system should update long-term learning state, produce a result summary, and emit analytics/reporting data (`lib/features/study/docs/03_session_lifecycle.md:61-72`, `lib/features/study/docs/06_learning_lifecycle.md:75-104`, `lib/features/study/docs/07_use_cases_and_checklist.md:67-95`).
- The docs also expect factories to resolve business behavior by business keys such as `sessionType`, `activeMode`, `answerType`, and `resultType`, with fail-fast behavior if an implementation is missing (`lib/features/study/docs/08_factory_pattern.md:36-60`, `lib/features/study/docs/08_factory_pattern.md:128-160`).

There is no external HTTP/API spec in the study docs. The effective contract in this feature is the session/use-case/provider contract described above.

## 2. Implemented behavior found in code

The implemented feature is a mode-first study UI with a recommendation hub. It does not currently operate as a single multi-mode study session engine.

- `StudySession` is a small persistence model with only `id`, `mode`, `deckId`, timestamps, counts, and duration (`lib/features/study/domain/entities/study_session.dart:7-23`).
- `StartStudySessionUseCase` and `CompleteStudySessionUseCase` only delegate persistence to the repository (`lib/features/study/domain/usecases/start_study_session.dart:5-13`, `lib/features/study/domain/usecases/complete_study_session.dart:4-10`).
- `StudyRepository` only exposes `startSession(deckId, mode)`, `completeSession(session)`, and `watchAll()`; there is no session snapshot contract, no `nothing to study` result, and no session-type API (`lib/features/study/domain/repositories/study_repository.dart:4-13`).
- The recommendation layer computes a `sessionType` and `modePlan` per deck from card status and due dates (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:21-58`), and the hub orders and displays those recommendations (`lib/features/study/presentation/providers/study_hub_provider.dart:50-89`, `lib/features/study/presentation/widgets/study_hub_content.dart:15-47`).
- Starting from the hub still routes directly into a single mode screen using `recommendation.primaryMode`, not a multi-mode executor (`lib/features/study/presentation/widgets/study_recommendation_card.dart:46-57`, `lib/features/study/presentation/screens/study_screen.dart:93-109`).
- Active session persistence is stored as a per-mode snapshot with `deckId`, `mode`, an optional `StudySession`, and arbitrary mode-specific `payload` (`lib/features/study/presentation/providers/active_study_session_store.dart:23-49`).
- `StudyModeFlowFactory` only maps `StudyMode` to screen builders, progress extractors, and restart callbacks; it does not resolve study strategies, answer evaluators, session-type handlers, or result presenters (`lib/features/study/presentation/factories/study_mode_flow_factory.dart:17-59`).
- Each mode owns its own provider state machine:
  - Review supports flip, rating, retry-queue-on-`again`, undo, and card flagging (`lib/features/study/presentation/providers/review_provider.dart:104-240`, `lib/features/study/presentation/screens/review_mode_screen.dart:45-137`).
  - Guess supports generated choice sets, auto-advance, skip counts, and one retry round for wrong/skipped answers (`lib/features/study/presentation/providers/guess_provider.dart:115-340`, `lib/features/study/presentation/widgets/guess_round_view.dart:25-190`).
  - Recall supports free typing, immediate reveal, self-rating, and an optional post-completion missed-card practice session (`lib/features/study/presentation/providers/recall_provider.dart:95-267`, `lib/features/study/presentation/widgets/recall_round_view.dart:33-108`).
  - Fill supports fuzzy evaluation, close-answer accept/reject, retry, hint, skip-after-retry, and a post-completion mistakes practice flow (`lib/features/study/presentation/providers/fill_provider.dart:123-490`, `lib/features/study/presentation/widgets/fill_feedback_panel.dart:30-157`).
  - Match supports a single board, mistake counting, combo/stars/timer UI, and completion when all pairs are matched (`lib/features/study/presentation/providers/match_provider.dart:112-374`, `lib/features/study/presentation/screens/match_mode_screen.dart:89-185`).
- Long-term card updates are applied immediately on each mode attempt through `SRSEngine` adapters (`lib/features/study/domain/srs/srs_engine.dart:34-67`) and per-mode review persistence (`lib/features/study/presentation/providers/review_provider.dart:268-301`, `lib/features/study/presentation/providers/guess_provider.dart:342-379`, `lib/features/study/presentation/providers/recall_provider.dart:269-310`, `lib/features/study/presentation/providers/fill_provider.dart:447-489`, `lib/features/study/presentation/providers/match_provider.dart:276-317`).
- Tests mostly validate the per-mode flows and the hub/resume UX, not a cross-mode session lifecycle (`test/features/study/presentation/providers/*.dart`, `test/features/study/presentation/screens/*.dart`, `test/features/study/domain/usecases/*.dart`).

## 3. Matched items

- The implementation does derive a business-ish `sessionType` and `modePlan` recommendation from deck/card state, and the hub surfaces that recommendation in UI (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:27-58`, `test/features/study/domain/usecases/build_study_deck_recommendation_test.dart:13-85`).
- Review mode matches the doc's idea of self-assessment plus same-session retry. Rating `again` re-queues the card for one retry round instead of marking it complete immediately (`lib/features/study/presentation/providers/review_provider.dart:158-191`, `test/features/study/presentation/providers/review_provider_test.dart:129-162`).
- Guess mode matches the doc's multiple-choice recognition flow and now includes same-session remediation for wrong/skipped items (`lib/features/study/presentation/providers/guess_provider.dart:176-247`, `lib/features/study/presentation/providers/guess_provider.dart:312-339`, `test/features/study/presentation/providers/guess_provider_test.dart:87-156`).
- Fill mode clearly implements an answer-evaluation policy with exact/close/wrong outcomes, whitespace/case normalization, accent stripping, and typo tolerance (`lib/features/study/domain/fill/fill_engine.dart:22-34`, `lib/features/study/domain/srs/fuzzy_matcher.dart:22-45`, `test/features/study/domain/fill/fill_engine_test.dart:55-65`, `test/features/study/domain/srs/fuzzy_matcher_test.dart:7-29`).
- Recall mode does implement the doc's reveal-then-self-assess flow for the manual reveal path (`lib/features/study/presentation/providers/recall_provider.dart:95-109`, `lib/features/study/presentation/providers/recall_provider.dart:164-195`, `test/features/study/presentation/providers/recall_provider_test.dart:36-95`).
- All major mode screens implement explicit empty/in-progress/completed UI states and exit/resume persistence at the mode level (`lib/features/study/presentation/screens/review_mode_screen.dart:149-227`, `lib/features/study/presentation/screens/guess_mode_screen.dart:68-190`, `lib/features/study/presentation/screens/fill_mode_screen.dart:137-241`, `lib/features/study/presentation/screens/match_mode_screen.dart:55-145`, `test/features/study/presentation/screens/study_screen_test.dart:36-366`).

## 4. Missing from implementation

- Missing generic study-session model. The docs require session-level fields such as `sessionType`, `modePlan`, `currentMode`, `currentItem`, `progress`, `completion status`, and a generic resume snapshot (`lib/features/study/docs/02_domain_model.md:31-45`, `lib/features/study/docs/02_domain_model.md:113-125`), but the actual `StudySession` only stores mode/deck/timestamps/counts (`lib/features/study/domain/entities/study_session.dart:7-23`).
- Missing session-item snapshot and explicit attempt model. The docs call for per-session item snapshots, retry flags, and attempt logging for analytics/audit (`lib/features/study/docs/02_domain_model.md:47-77`), but the persisted model contains no session items or attempts; only mode-local transient state plus `CardReviewsTable` writes exist (`lib/features/study/presentation/providers/active_study_session_store.dart:23-49`, `lib/features/study/presentation/providers/review_provider.dart:268-301`).
- Missing start-session business flow. The docs require eligibility checks, refusal with `nothing to study`, session-type resolution, mode-plan resolution, and an initial session snapshot (`lib/features/study/docs/03_session_lifecycle.md:14-36`, `lib/features/study/docs/07_use_cases_and_checklist.md:11-35`). `StartStudySessionUseCase` just forwards `deckId` and `mode` to persistence (`lib/features/study/domain/usecases/start_study_session.dart:10-13`), and `StudyRepositoryImpl.startSession` just inserts a row (`lib/features/study/data/repositories/study_repository_impl.dart:27-42`).
- Missing explicit action-state contract. The docs say the system should always return current state plus `allowedActions` and the UI should not infer flow (`lib/features/study/docs/05_execution_rules.md:3-17`). No provider or snapshot type exposes `allowedActions`; each mode derives legality with ad hoc boolean checks such as `current.isAnswered`, `current.isRevealed`, `current.canSubmit`, and `current.lastResult != null` (`lib/features/study/presentation/providers/guess_provider.dart:119-123`, `lib/features/study/presentation/providers/recall_provider.dart:98-104`, `lib/features/study/presentation/providers/fill_provider.dart:244-259`, `lib/features/study/presentation/providers/match_provider.dart:100-118`).
- Missing multi-mode session execution. The docs consistently frame `modePlan` as part of the real session lifecycle (`lib/features/study/docs/02_domain_model.md:39-45`, `lib/features/study/docs/03_session_lifecycle.md:29-36`), but the implementation only shows the plan on the hub and then launches one mode at a time (`lib/features/study/presentation/widgets/study_recommendation_card.dart:33-57`, `lib/features/study/presentation/screens/study_screen.dart:97-99`).
- Missing session-type policy inputs beyond card status. The docs mention inputs such as often-failed items, learner preference, curriculum stage, and exam date (`lib/features/study/docs/03_session_lifecycle.md:99-109`), but recommendation logic only uses due/new/active counts (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:35-57`, `lib/features/study/domain/usecases/build_study_deck_recommendation.dart:83-101`).
- Missing generic completion-time learning-state update stage. The docs separate short-term session outcomes from long-term learning-state updates and place the long-term update after session completion (`lib/features/study/docs/06_learning_lifecycle.md:3-37`, `lib/features/study/docs/07_use_cases_and_checklist.md:67-95`). The implementation updates card SRS state on each attempt before session completion (`lib/features/study/presentation/providers/review_provider.dart:268-283`, `lib/features/study/presentation/providers/guess_provider.dart:342-359`, `lib/features/study/presentation/providers/recall_provider.dart:269-290`, `lib/features/study/presentation/providers/fill_provider.dart:447-468`, `lib/features/study/presentation/providers/match_provider.dart:276-299`).
- Missing analytics/reporting events. The docs expect events such as `session started`, `session resumed`, `mode entered`, `mode completed`, `retry count`, `reveal usage`, and `completion rate` (`lib/features/study/docs/06_learning_lifecycle.md:75-104`). I did not find an analytics service, event emitter, or test coverage for those events anywhere in the inspected study source files.
- Missing explicit invalid-action/error contract. The docs list alternative flows such as invalid action, invalid answer payload, interruption, and timeout (`lib/features/study/docs/07_use_cases_and_checklist.md:57-66`). The implementation mostly ignores invalid calls with early returns and does not produce structured rejection reasons (`lib/features/study/presentation/providers/review_provider.dart:108-114`, `lib/features/study/presentation/providers/guess_provider.dart:176-185`, `lib/features/study/presentation/providers/recall_provider.dart:168-173`, `lib/features/study/presentation/providers/fill_provider.dart:244-259`).
- Missing timeout-driven reveal and reveal penalty policy in recall. The docs explicitly mention timeout reveal and reveal penalties as alternative flows/policies (`lib/features/study/docs/04_mode_patterns.md:185-196`, `lib/features/study/docs/05_execution_rules.md:80-87`). Recall only supports manual reveal and does not model a penalty for reveal (`lib/features/study/presentation/providers/recall_provider.dart:95-109`).
- Missing mode-level retry loop in recall and match. The docs say failed items should become retry-pending and a mode should not complete until retry items are resolved (`lib/features/study/docs/03_session_lifecycle.md:49-60`, `lib/features/study/docs/05_execution_rules.md:54-73`). Recall completes after one pass and only offers a separate post-completion practice session (`lib/features/study/presentation/providers/recall_provider.dart:220-259`); match completes when all pairs are eventually matched and never declares board fail or retry-pending state (`lib/features/study/presentation/providers/match_provider.dart:170-231`).
- Missing factory coverage described by the docs. The docs expect factory resolution for session type, mode plan, study mode strategy, outcome evaluation, and result presentation (`lib/features/study/docs/08_factory_pattern.md:36-76`, `lib/features/study/docs/08_factory_pattern.md:128-160`). The only factory in the implementation is a UI routing/progress helper (`lib/features/study/presentation/factories/study_mode_flow_factory.dart:17-59`).

## 5. Implemented but not specified in doc

- Review-mode undo is implemented and tested, but the markdown does not mention undoing a recorded outcome (`lib/features/study/presentation/screens/review_mode_screen.dart:87-137`, `test/features/study/presentation/providers/review_provider_test.dart:164-195`, `test/features/study/presentation/screens/review_mode_screen_test.dart:164-200`).
- Review-mode card flagging is implemented and tested, but the markdown spec does not mention flagging or reserved tags as part of study behavior (`lib/features/study/presentation/providers/review_provider.dart:304-340`, `test/features/study/presentation/providers/review_provider_test.dart:197-215`, `test/features/study/presentation/screens/review_mode_screen_test.dart:202-228`).
- Guess mode uses placeholder answers when the deck is too small and shows a small-deck warning, which is a product behavior absent from the docs (`lib/features/study/domain/guess/guess_engine.dart:38-81`, `lib/features/study/presentation/widgets/guess_question_card.dart:9-48`, `test/features/study/domain/guess/guess_engine_test.dart:27-39`, `test/features/study/presentation/screens/guess_mode_screen_test.dart:58-69`).
- Guess mode has a concrete skip-limit policy: two skips reorder the card, the third skip marks it wrong and queues retry, and the next skip finalizes it as skipped. The docs mention remediation generically but do not define this exact rule (`lib/features/study/presentation/providers/guess_provider.dart:249-339`, `test/features/study/presentation/providers/guess_provider_test.dart:121-156`).
- Recall mode adds a post-completion "practice missed cards" flow that intentionally does not create a new statistics session. The docs do not describe a post-session practice-only mode (`lib/features/study/presentation/providers/recall_provider.dart:111-125`, `lib/features/study/presentation/providers/recall_provider.dart:238-259`, `test/features/study/presentation/providers/recall_provider_test.dart:160-209`).
- Fill mode adds manual acceptance/rejection of "close" answers, plus an example-sentence quality warning. The docs mention normalization/fuzzy policy questions, but not this exact UI/UX flow (`lib/features/study/presentation/providers/fill_provider.dart:123-176`, `lib/features/study/presentation/screens/fill_mode_screen.dart:213-241`, `test/features/study/presentation/providers/fill_provider_test.dart:38-159`, `test/features/study/presentation/screens/fill_mode_screen_test.dart:29-189`).
- Match mode adds a timer, star rating, combo count, and animated board affordances that are not described in the markdown (`lib/features/study/presentation/screens/match_mode_screen.dart:96-165`, `lib/features/study/presentation/widgets/match_item_card.dart:30-81`, `lib/features/study/presentation/widgets/match_star_rating.dart:6-27`).
- Review mode also ships keyboard shortcuts and swipe shortcuts, which are not specified in the docs (`lib/features/study/presentation/widgets/review_rating_shortcuts.dart:20-80`, `lib/features/study/presentation/widgets/review_round_view.dart:35-93`, `test/features/study/presentation/screens/review_mode_screen_test.dart:92-162`).

## 6. Ambiguous points in doc

- The docs present `Remedial` and `Exam Prep` as generic examples, not as mandatory session types (`lib/features/study/docs/03_session_lifecycle.md:88-97`). The implementation only defines `firstLearning`, `review`, `reinforcement`, and `quickDrill` (`lib/features/study/domain/support/study_session_type.dart:3-14`). This is a mismatch in breadth, but the docs do not state that every example must be implemented.
- The docs clearly separate short-term session outcomes from long-term learning state (`lib/features/study/docs/06_learning_lifecycle.md:30-37`), but they do not explicitly say whether per-item SRS updates are forbidden before session completion. That makes the current per-attempt updates risky, but not unambiguously invalid.
- The docs say failed items should retry within the mode (`lib/features/study/docs/03_session_lifecycle.md:49-60`), yet the remediation section also allows other options such as an easier mode or a future remedial session (`lib/features/study/docs/05_execution_rules.md:66-73`). Recall's post-completion missed-card practice violates the generic retry-loop wording, but the remediation section leaves room for alternate product choices if explicitly documented.
- The docs define an action-state contract but do not prescribe the exact shape of `modeState`, `progress`, or `allowedActions` payloads (`lib/features/study/docs/02_domain_model.md:113-125`, `lib/features/study/docs/05_execution_rules.md:18-45`). The implementation is therefore missing the contract entirely, but the exact DTO schema remains underspecified.
- The docs mention board pass/fail in match mode (`lib/features/study/docs/04_mode_patterns.md:99-103`) without defining a pass threshold, failure threshold, or whether eventual success after mistakes should still count as pass. The current "complete when all pairs matched" rule is narrower than the prose, but the prose does not fully define the intended scoring policy.

## 7. Risky deviations

- Highest risk: the product surfaces a `modePlan` recommendation but never executes that plan as a session. Users are shown multi-step plans like `review -> recall -> fill`, but tapping the main CTA launches only `primaryMode` (`lib/features/study/domain/usecases/build_study_deck_recommendation.dart:49-57`, `lib/features/study/presentation/widgets/study_recommendation_card.dart:46-57`). This is a direct expectation gap against the session-lifecycle docs (`lib/features/study/docs/03_session_lifecycle.md:29-36`).
- High risk: the persisted session shape is too narrow to support the spec's resume, action-contract, analytics, and multi-mode orchestration requirements (`lib/features/study/domain/entities/study_session.dart:7-23`, `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`). This is structural, not cosmetic.
- High risk: learning-state updates happen on each attempt before the session is known to be complete (`lib/features/study/presentation/providers/review_provider.dart:268-283`, `lib/features/study/presentation/providers/guess_provider.dart:342-359`, `lib/features/study/presentation/providers/recall_provider.dart:269-290`, `lib/features/study/presentation/providers/fill_provider.dart:447-468`, `lib/features/study/presentation/providers/match_provider.dart:276-299`). If the intended policy is "finalize after session completion", the current approach makes rollback, remedial routing, and analytics attribution harder.
- High risk: recall and match use completion rules that can mark a mode complete without a retry-pending loop, despite the docs making retry resolution part of completion (`lib/features/study/docs/03_session_lifecycle.md:49-72`). This can overstate mastery or completion quality for the two modes that most need strong signal handling.
- Medium-high risk: the UI derives legal actions from local booleans rather than reading an explicit `allowedActions` contract. That increases the chance of drift between mode logic, persisted snapshot shape, and tests as the feature grows (`lib/features/study/docs/05_execution_rules.md:9-17`, `lib/features/study/presentation/providers/fill_provider.dart:244-259`, `lib/features/study/presentation/widgets/guess_round_view.dart:122-165`, `lib/features/study/presentation/widgets/recall_writing_area.dart:27-63`).
- Medium risk: the docs call for analytics/reporting signals, but there is no analytics layer in the study feature. That means the current implementation cannot satisfy the documented KPI/reporting intent even if the UI feels complete (`lib/features/study/docs/06_learning_lifecycle.md:75-104`).

## 8. Recommended fixes

- Decide first whether the markdown is the target architecture or historical design notes. If the current product is intentionally single-mode with a recommendation hub, narrow the docs. If the docs are the target, the implementation needs a real session orchestrator.
- Introduce a session aggregate and snapshot contract that matches the docs: `sessionId`, `sessionType`, `modePlan`, `activeMode`, `modeState`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted`. Without that, the current feature cannot honestly claim conformance.
- Expand the start-session contract from `startSession(deckId, mode)` to a result-bearing use case that performs eligibility checks and can return explicit refusal reasons such as `nothing to study`, invalid container, or permission denial.
- Convert `modePlan` from display-only metadata into actual execution state, or remove it from the user-facing recommendation copy until it is real.
- Standardize retry behavior across modes. If recall and match intentionally diverge from the generic retry loop, document the exception explicitly in `lib/features/study/docs/04_mode_patterns.md` and `lib/features/study/docs/05_execution_rules.md`; otherwise, rework those modes to keep failed items pending before completion.
- Add an explicit `allowedActions` representation to each mode state and persisted snapshot. That will make resume safer and align the implementation with the stated business contract.
- Decide and document when long-term learning state is committed. If the current per-attempt SRS write is correct, update the docs. If session-completion commit is the real target, move/aggregate updates accordingly.
- Add analytics/reporting instrumentation or trim the docs. At minimum, the feature needs session started/resumed/completed, mode entered/completed, retry count, reveal usage, and completion-rate signals to satisfy the documented non-functional expectations.
- Update tests to assert the chosen contract. Today the tests strongly lock in the simplified repository contract (`test/features/study/domain/usecases/start_study_session_test.dart:8-18`, `test/features/study/domain/usecases/complete_study_session_test.dart:8-31`) and the recall practice-only deviation (`test/features/study/presentation/providers/recall_provider_test.dart:160-209`), but there are no tests for generic session snapshots, `allowedActions`, session refusal reasons, analytics, or cross-mode execution.

## 9. Files inspected

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
- `lib/features/study/docs/09_adoption_template.md`
- `lib/features/study/data/datasources/study_local_datasource.dart`
- `lib/features/study/data/mappers/study_session_mapper.dart`
- `lib/features/study/data/repositories/study_repository_impl.dart`
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
- `lib/features/study/presentation/widgets/fill_answer_input.dart`
- `lib/features/study/presentation/widgets/fill_diff_text.dart`
- `lib/features/study/presentation/widgets/fill_feedback_panel.dart`
- `lib/features/study/presentation/widgets/fill_mistakes_panel.dart`
- `lib/features/study/presentation/widgets/fill_prompt_card.dart`
- `lib/features/study/presentation/widgets/fill_prompt_sentence.dart`
- `lib/features/study/presentation/widgets/fill_round_view.dart`
- `lib/features/study/presentation/widgets/fill_submit_button.dart`
- `lib/features/study/presentation/widgets/guess_feedback_card.dart`
- `lib/features/study/presentation/widgets/guess_option_button.dart`
- `lib/features/study/presentation/widgets/guess_question_card.dart`
- `lib/features/study/presentation/widgets/guess_round_view.dart`
- `lib/features/study/presentation/widgets/match_elapsed_timer_text.dart`
- `lib/features/study/presentation/widgets/match_item_board.dart`
- `lib/features/study/presentation/widgets/match_item_card.dart`
- `lib/features/study/presentation/widgets/match_round_view.dart`
- `lib/features/study/presentation/widgets/match_star_rating.dart`
- `lib/features/study/presentation/widgets/recall_comparison_view.dart`
- `lib/features/study/presentation/widgets/recall_highlighted_text.dart`
- `lib/features/study/presentation/widgets/recall_prompt_card.dart`
- `lib/features/study/presentation/widgets/recall_rating_guidance.dart`
- `lib/features/study/presentation/widgets/recall_reveal_phase.dart`
- `lib/features/study/presentation/widgets/recall_round_view.dart`
- `lib/features/study/presentation/widgets/recall_self_assessment.dart`
- `lib/features/study/presentation/widgets/recall_writing_area.dart`
- `lib/features/study/presentation/widgets/review_card_face.dart`
- `lib/features/study/presentation/widgets/review_flip_panel.dart`
- `lib/features/study/presentation/widgets/review_rating_button.dart`
- `lib/features/study/presentation/widgets/review_rating_grid.dart`
- `lib/features/study/presentation/widgets/review_rating_shortcuts.dart`
- `lib/features/study/presentation/widgets/review_round_view.dart`
- `lib/features/study/presentation/widgets/study_active_session_card.dart`
- `lib/features/study/presentation/widgets/study_deck_picker_section.dart`
- `lib/features/study/presentation/widgets/study_deck_recommendation_tile.dart`
- `lib/features/study/presentation/widgets/study_hub_content.dart`
- `lib/features/study/presentation/widgets/study_mistakes_panel.dart`
- `lib/features/study/presentation/widgets/study_next_deck_button.dart`
- `lib/features/study/presentation/widgets/study_placeholder_view.dart`
- `lib/features/study/presentation/widgets/study_recommendation_card.dart`
- `lib/features/study/presentation/widgets/study_resume_dialog.dart`
- `test/features/study/domain/fill/fill_engine_test.dart`
- `test/features/study/domain/guess/guess_engine_test.dart`
- `test/features/study/domain/match/match_engine_test.dart`
- `test/features/study/domain/srs/fuzzy_matcher_test.dart`
- `test/features/study/domain/srs/srs_engine_test.dart`
- `test/features/study/domain/usecases/build_study_deck_recommendation_test.dart`
- `test/features/study/domain/usecases/complete_study_session_test.dart`
- `test/features/study/domain/usecases/start_study_session_test.dart`
- `test/features/study/presentation/providers/fill_provider_test.dart`
- `test/features/study/presentation/providers/guess_provider_test.dart`
- `test/features/study/presentation/providers/match_provider_test.dart`
- `test/features/study/presentation/providers/recall_provider_test.dart`
- `test/features/study/presentation/providers/review_provider_test.dart`
- `test/features/study/presentation/screens/fill_mode_screen_test.dart`
- `test/features/study/presentation/screens/guess_mode_screen_test.dart`
- `test/features/study/presentation/screens/match_mode_screen_test.dart`
- `test/features/study/presentation/screens/recall_mode_screen_test.dart`
- `test/features/study/presentation/screens/review_mode_screen_test.dart`
- `test/features/study/presentation/screens/study_screen_test.dart`
- `test/features/study/presentation/widgets/fill_submit_button_test.dart`
