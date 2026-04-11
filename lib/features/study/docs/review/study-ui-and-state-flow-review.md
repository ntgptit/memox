# Study UI And State Flow Review

Strict review of the study feature UI behavior and state flow against the markdown docs under `lib/features/study/docs/**`.

## 1. Expected UI behavior from docs

The docs do not define detailed layouts or exact Flutter screens. `lib/features/study/docs/01_business_context.md:25-30` explicitly excludes detailed UI layout. The markdown still implies a concrete set of UI surfaces and behaviors.

Expected surfaces implied by the docs:
- A session-entry surface where the learner selects a learning container and starts a study session. This is implied by `lib/features/study/docs/07_use_cases_and_checklist.md:17-24`.
- A study-mode surface that renders the current item in the active mode and only exposes valid actions for the current state. This is explicit in `lib/features/study/docs/03_session_lifecycle.md:38-47` and `lib/features/study/docs/05_execution_rules.md:9-17`.
- A retry surface or retry phase when failed items remain after the first pass. This is explicit in `lib/features/study/docs/03_session_lifecycle.md:49-60` and `lib/features/study/docs/05_execution_rules.md:56-64`.
- A completion surface that shows result summary after the final mode completes and the session ends. This is explicit in `lib/features/study/docs/03_session_lifecycle.md:63-72` and `lib/features/study/docs/07_use_cases_and_checklist.md:77-84`.
- Resume, reset-current-mode, and exit controls because those flows are part of the business contract in `lib/features/study/docs/06_learning_lifecycle.md:40-74`.

Expected user interactions from docs:
- Review mode: view item, then choose `MARK_REMEMBERED` or `RETRY_ITEM`, then go next. `lib/features/study/docs/04_mode_patterns.md:39-63`.
- Match mode: select left, select right, submit answer, then go next or retry. `lib/features/study/docs/04_mode_patterns.md:85-110`.
- Guess mode: choose an answer, submit, then go next; timeout and remediation are alternative flows. `lib/features/study/docs/04_mode_patterns.md:133-157`.
- Recall mode: attempt recall, reveal answer by user action or timeout, self-assess remembered or retry, then go next. `lib/features/study/docs/04_mode_patterns.md:181-208`.
- Fill mode: type answer, submit, system grades, then go next or retry/reveal per policy. `lib/features/study/docs/04_mode_patterns.md:230-260`.

Expected UI states from docs:
- `nothing to study` or equivalent refusal state when no eligible item exists. `lib/features/study/docs/03_session_lifecycle.md:22-25`.
- An unauthorized or no-access alternative state because learner access denial is an explicit alternative flow. `lib/features/study/docs/03_session_lifecycle.md:16-20`, `lib/features/study/docs/07_use_cases_and_checklist.md:26-30`.
- A success/completion state with result summary. `lib/features/study/docs/03_session_lifecycle.md:68-72`, `lib/features/study/docs/07_use_cases_and_checklist.md:77-84`.
- Retry-pending state behavior where failed items are not considered complete and must reappear before mode completion. `lib/features/study/docs/05_execution_rules.md:22-26`, `lib/features/study/docs/05_execution_rules.md:56-64`.

Expected conditional rendering rules from docs:
- UI should not infer flow on its own; system should return current state and `allowed actions`. `lib/features/study/docs/05_execution_rules.md:11-17`.
- Current mode, current item, progress, and allowed actions must be restored on resume. `lib/features/study/docs/06_learning_lifecycle.md:46-50`.
- Current mode reset should clear current-mode progress and possibly attempts according to policy. `lib/features/study/docs/06_learning_lifecycle.md:57-61`.

Expected navigation flow from docs:
- Learner selects container, session starts, first item is returned. `lib/features/study/docs/07_use_cases_and_checklist.md:17-24`.
- Session follows a `mode plan`, not just one isolated mode. `lib/features/study/docs/01_business_context.md:103-105`, `lib/features/study/docs/03_session_lifecycle.md:29-36`, `lib/features/study/docs/04_mode_patterns.md:26-27`.
- Retry happens inside the session before mode or session completion. `lib/features/study/docs/03_session_lifecycle.md:51-60`.
- Final navigation is to a result summary after long-term update and analytics recording. `lib/features/study/docs/03_session_lifecycle.md:68-72`.

Expected feedback behavior from docs:
- The docs require clear outcome recording and result summary, but they do not specify snackbar, toast, bottom sheet, or dialog patterns.
- The docs require explicit decision-making for exit, reset, reveal penalties, invalid payloads, and interruption handling, but they do not prescribe modal UX. `lib/features/study/docs/06_learning_lifecycle.md:63-74`, `lib/features/study/docs/07_use_cases_and_checklist.md:57-60`.

Unspecified by docs:
- Loading UI.
- Concrete async error UI.
- Offline UI.
- Exact dialog, toast, snackbar, or bottom-sheet mechanics.

## 2. Actual UI behavior in code

Route-level behavior:
- `StudyScreen` acts as both a hub screen and a direct single-mode route. If `deckId` and `mode` are provided, it immediately builds a specific mode screen through `StudyModeFlowFactory`; otherwise it renders the study hub. `lib/features/study/presentation/screens/study_screen.dart:93-109`.
- On direct mode routes, `StudyScreen` checks the stored mode-specific snapshot and shows a resume/start-over dialog when `deckId` and `mode` match the stored snapshot. `lib/features/study/presentation/screens/study_screen.dart:55-91`, `lib/features/study/presentation/widgets/study_resume_dialog.dart:20-37`.

Hub UI:
- `StudyHubContent` shows an empty state only when there is no recommendation and no active session. Otherwise it may render an active session card, a recommended deck card, and a deck picker section. `lib/features/study/presentation/widgets/study_hub_content.dart:17-47`.
- `StudyRecommendationCard` renders a session-type badge, deck title, `modePlan` chips, a primary CTA that launches only `primaryMode`, and a secondary CTA that opens a mode-choice bottom sheet. `lib/features/study/presentation/widgets/study_recommendation_card.dart:21-77`.
- `StudyActiveSessionCard` renders resume and start-over actions for the one stored active snapshot. `lib/features/study/presentation/widgets/study_active_session_card.dart:22-63`.

Shared screen behavior across modes:
- Every mode screen is wrapped in `AppAsyncBuilder` and exposes a retry callback that simply restarts that mode session. Examples: `review_mode_screen.dart:39-70`, `guess_mode_screen.dart:28-50`, `recall_mode_screen.dart:41-72`, `fill_mode_screen.dart:45-78`, `match_mode_screen.dart:29-71`.
- Every mode screen uses `StudyTopBar` and an exit confirmation dialog via `showExitSessionDialog`. Examples: `review_mode_screen.dart:47-67`, `guess_mode_screen.dart:37-49`, `recall_mode_screen.dart:54-69`, `fill_mode_screen.dart:57-76`, `match_mode_screen.dart:36-70`.
- Confirming exit pops the route. It does not clear the saved snapshot. Examples: `review_mode_screen.dart:73-85`, `guess_mode_screen.dart:53-65`, `recall_mode_screen.dart:75-87`, `fill_mode_screen.dart:103-115`, `match_mode_screen.dart:74-85`.

Review UI:
- Empty state: `EmptyStateView` with review-specific subtitle. `lib/features/study/presentation/screens/review_mode_screen.dart:149-155`.
- In-progress state: flip panel first, then rating panel after flip. `lib/features/study/presentation/widgets/review_round_view.dart:52-73`.
- Interaction helpers: keyboard shortcuts and swipe-to-rate via `ReviewRatingShortcuts` and `AppSwipeRegion`. `lib/features/study/presentation/widgets/review_round_view.dart:35-43`.
- Feedback: snackbar for flag/unflag. `lib/features/study/presentation/screens/review_mode_screen.dart`.
- Completion state: `SessionCompleteView` with rating counts, summary text, mistakes panel, and next-deck button. `lib/features/study/presentation/screens/review_mode_screen.dart:157-217`.

Guess UI:
- Empty state: `EmptyStateView`. `lib/features/study/presentation/screens/guess_mode_screen.dart:74-80`.
- In-progress state: question card plus options list. `lib/features/study/presentation/widgets/guess_round_view.dart:37-58`, `lib/features/study/presentation/widgets/guess_round_view.dart:77-119`.
- Conditional rendering: wrong answers show an explanation card; answered questions change footer action from skip to continue; small decks show a warning. `lib/features/study/presentation/widgets/guess_round_view.dart:100-103`, `lib/features/study/presentation/widgets/guess_round_view.dart:137-165`, `lib/features/study/presentation/widgets/guess_round_view.dart:40-45`.
- Completion state: `SessionCompleteView` with correct count, accuracy, streak, skipped summary, mistakes panel, next-deck button, and play-again button. `lib/features/study/presentation/screens/guess_mode_screen.dart:103-179`.

Recall UI:
- Empty state: `EmptyStateView`. `lib/features/study/presentation/screens/recall_mode_screen.dart:110-116`.
- In-progress state: prompt card plus an animated switch between writing area and reveal phase. `lib/features/study/presentation/widgets/recall_round_view.dart:47-79`.
- Conditional rendering: reveal phase only appears after `state.isRevealed`; before reveal the writing area shows reveal and mark-missed actions. `lib/features/study/presentation/widgets/recall_round_view.dart:63-78`.
- Extra interaction: reveal phase can navigate to card edit. `lib/features/study/presentation/screens/recall_mode_screen.dart:207-215`.
- Completion state: `SessionCompleteView` with self-rating stats, optional `practice missed cards` secondary action, hint text, mistakes panel, and next-deck button. `lib/features/study/presentation/screens/recall_mode_screen.dart:118-197`.

Fill UI:
- Empty state: `EmptyStateView`. `lib/features/study/presentation/screens/fill_mode_screen.dart:137-143`.
- Focus behavior: input auto-focuses while active, but focus is removed when complete or when result is `close` or `correct`. `lib/features/study/presentation/screens/fill_mode_screen.dart:80-101`.
- In-progress state: optional warning info bar, prompt card, answer input, and feedback panel. `lib/features/study/presentation/widgets/fill_round_view.dart:96-129`.
- Conditional rendering: warning info bar appears when some cards have no examples; prompt card can show hint and answer; feedback panel exposes accept/reject/skip according to state. `lib/features/study/presentation/screens/fill_mode_screen.dart:213-241`, `lib/features/study/presentation/widgets/fill_round_view.dart:98-128`.
- Completion state: `SessionCompleteView` with first-try accuracy, accepted-close count, retry-needed count, streak, mistakes panel, next-deck button, and the normal done action only. `lib/features/study/presentation/screens/fill_mode_screen.dart:145-210`.

Match UI:
- Empty state exists inside `MatchRoundView` only when the generated board has no pairs. `lib/features/study/presentation/widgets/match_round_view.dart:21-28`.
- In-progress state: top bar shows pairs left and timer; board is rendered through `MatchItemBoard` without a secondary deselect hint surface. `lib/features/study/presentation/screens/match_mode_screen.dart:37-52`, `lib/features/study/presentation/widgets/match_round_view.dart:30-40`.
- Completion state: `SessionCompleteView` with elapsed time, mistakes, star rating, mistakes panel, next-deck button, and play-again button. `lib/features/study/presentation/screens/match_mode_screen.dart:89-145`.

## 3. Expected state flow from docs

Generic state flow required by docs:
- Eligibility check.
- Session creation.
- Active learning.
- Retry handling.
- Session completion.
- Long-term update.
This lifecycle is explicit in `lib/features/study/docs/03_session_lifecycle.md:5-12`.

Generic state contract required by docs:
- UI should receive `current state` and `allowed actions` at every step. `lib/features/study/docs/05_execution_rules.md:9-17`.
- Generic mode states are `INITIALIZED`, `IN_PROGRESS`, `WAITING_FEEDBACK`, `RETRY_PENDING`, and `COMPLETED`. `lib/features/study/docs/05_execution_rules.md:18-26`.
- Generic actions are `SUBMIT_ANSWER`, `REVEAL_ANSWER`, `MARK_REMEMBERED`, `RETRY_ITEM`, `GO_NEXT`, and `RESET_CURRENT_MODE`. `lib/features/study/docs/05_execution_rules.md:28-37`.
- Generic outcomes are `PASSED`, `FAILED`, and `SKIPPED`. `lib/features/study/docs/05_execution_rules.md:39-45`.

Expected transition rules:
- When an item fails, it is not complete and becomes retry-pending. `lib/features/study/docs/05_execution_rules.md:56-59`.
- When the first pass ends, the mode enters retry loop if retry-pending items remain; otherwise mode completes. `lib/features/study/docs/05_execution_rules.md:61-64`.
- Session completes only after the final mode completes and no incomplete items remain. `lib/features/study/docs/03_session_lifecycle.md:63-67`.
- After completion, learning state updates and analytics happen after summary aggregation. `lib/features/study/docs/03_session_lifecycle.md:68-72`, `lib/features/study/docs/06_learning_lifecycle.md:30-37`.

Expected mode-specific transitions:
- Review: item shown -> learner self-assesses -> system records outcome -> item complete or retry -> next item. `lib/features/study/docs/04_mode_patterns.md:39-57`.
- Guess: prompt + choices -> learner selects -> system scores -> outcome recorded -> next item or remediation. `lib/features/study/docs/04_mode_patterns.md:133-152`.
- Recall: prompt only -> learner attempts -> reveal by user or timeout -> self-assessment -> outcome -> next item. `lib/features/study/docs/04_mode_patterns.md:181-201`.
- Fill: prompt -> typed answer -> policy grading -> pass and next, or fail and retry/reveal by policy. `lib/features/study/docs/04_mode_patterns.md:230-253`.
- Match: generate pair board -> learner matches -> system checks board -> board pass/fail -> next or retry. `lib/features/study/docs/04_mode_patterns.md:85-103`.

Expected resume/reset/exit transitions:
- Resume must restore current mode, current item, progress, and allowed actions. `lib/features/study/docs/06_learning_lifecycle.md:46-50`.
- Reset current mode must clear current-mode progress and maybe current-mode attempts. `lib/features/study/docs/06_learning_lifecycle.md:57-61`.
- Exit requires an explicit policy decision for save/resume/analytics behavior. `lib/features/study/docs/06_learning_lifecycle.md:69-73`.

## 4. Actual state flow in code

Route and navigation state flow:
- `StudyScreen` has a bifurcated flow: hub route or direct single-mode route. If `deckId` and `mode` exist, there is no generic session setup UI; the code immediately resolves one mode screen. `lib/features/study/presentation/screens/study_screen.dart:93-99`.
- The hub computes a recommendation, but the primary action routes to `primaryMode` only. `lib/features/study/presentation/widgets/study_recommendation_card.dart:46-57`.
- Choose-mode uses a bottom sheet and then also routes directly to one selected mode. `lib/features/study/presentation/widgets/study_recommendation_card.dart:67-77`.

Stored state flow:
- There is one global `ActiveStudySessionSnapshot` with `deckId`, `mode`, optional persisted `StudySession`, and opaque mode payload. `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`.
- Resume works only when requested `deckId + mode` match the saved snapshot. `lib/features/study/presentation/screens/study_screen.dart:63-90`.
- Start-over clears the matching snapshot and restarts that same mode. `lib/features/study/presentation/screens/study_screen.dart:84-90`, `lib/features/study/presentation/widgets/study_active_session_card.dart:59-63`.

Provider-level state flow:
- Review state is provider-local: `cards`, `currentIndex`, `isFlipped`, `selectedRating`, `results`, `retryPendingCardIds`, and `isComplete`. `lib/features/study/presentation/providers/review_provider.dart:29-42`.
- Review transitions:
  - build -> restore snapshot or `_startSession`. `lib/features/study/presentation/providers/review_provider.dart:93-102`.
  - `toggleFlip` toggles reveal state. `lib/features/study/presentation/providers/review_provider.dart:130-140`.
  - `rate` is ignored unless card exists, mode is active, card is flipped, and no rating is already selected. `lib/features/study/presentation/providers/review_provider.dart:104-127`.
  - `again` moves the card to the end and marks retry pending. `lib/features/study/presentation/providers/review_provider.dart:158-191`.
  - last card completion sets `isComplete` and persists a completed session row. `lib/features/study/presentation/providers/review_provider.dart:202-218`, `lib/features/study/presentation/providers/review_provider.dart:243-263`.
- Guess state is provider-local: `cards`, `currentQuestion`, `selectedOptionIndex`, `isAnswered`, `isCorrect`, `results`, `skipCounts`, `retryPendingCardIds`, and `isComplete`. `lib/features/study/presentation/providers/guess_provider.dart:25-40`.
- Guess transitions:
  - `selectOption` is ignored when answered, complete, or index is invalid. `lib/features/study/presentation/providers/guess_provider.dart:176-185`.
  - Correct answer sets answered state, persists review, then auto-advances after a delay if state still matches. `lib/features/study/presentation/providers/guess_provider.dart:193-247`.
  - Wrong answer on first pass only marks retry pending; wrong answer in retry round finalizes as wrong. `lib/features/study/presentation/providers/guess_provider.dart:194-219`.
  - `skipQuestion` is manual only and follows a per-card skip limit policy. `lib/features/study/presentation/providers/guess_provider.dart:249-339`.
  - `nextQuestion` handles reorder-on-retry, move-next, or final completion. `lib/features/study/presentation/providers/guess_provider.dart:115-174`.
- Recall transitions from the implementation pass:
  - build -> restore snapshot or start session.
  - pre-reveal state accepts free text, reveal, and immediate missed marking.
  - reveal is manual only.
  - post-reveal state accepts self-rating and then advances.
  - missed cards stay retry-pending inside the same session until the retry is resolved. Evidence: `lib/features/study/presentation/providers/recall_provider.dart:95-267` and the retry-focused tests in `test/features/study/presentation/providers/recall_provider_test.dart`.
- Fill state is provider-local: `userInput`, `result`, `firstAttemptResult`, `submittedAnswer`, `isRetrying`, `retryCount`, `showHint`, `results`, `streak`, and `isComplete`. `lib/features/study/presentation/providers/fill_provider.dart:31-48`.
- Fill transitions:
  - `submitAnswer` is ignored when input is blank or session is complete. `lib/features/study/presentation/providers/fill_provider.dart:240-260`.
  - Close results branch into accept/reject state. `lib/features/study/presentation/providers/fill_provider.dart:123-176`.
  - Wrong answers enter retry state; skip becomes available only after at least one retry. `lib/features/study/presentation/providers/fill_provider.dart:178-230`.
  - Completion stays on the summary surface after retry remediation; there is no separate practice-only branch. `lib/features/study/presentation/screens/fill_mode_screen.dart:145-210`.
- Match state is provider-local: selected ids, matched pairs, attempt counts, mistakes, combo count, `lastResult`, and `isComplete`. `lib/features/study/presentation/providers/match_provider.dart:32-50`.
- Match transitions:
  - selecting a term or definition updates the current side selection; selecting the opposite side resolves the pair. `lib/features/study/presentation/providers/match_provider.dart:125-139`.
  - once both sides are selected, `_resolveSelection` routes to `_handleCorrect` or `_handleWrong`.
  - wrong attempt sets `lastResult`, increments mistake count, and clears after an animation delay. `lib/features/study/presentation/providers/match_provider.dart:234-260`.
  - correct attempt adds the matched pair, advances across grouped boards, and only completes the game after the final grouped board is cleared. `lib/features/study/presentation/providers/match_provider.dart:190-231`, `lib/features/study/presentation/providers/match_provider.dart:238-260`.

Persistence and completion flow:
- Every mode persists snapshots independently and clears them only on that mode’s completion path.
- Long-term SRS updates happen inside mode providers per attempt, not after a session-level aggregate completion. Evidence across providers summarized in `review_provider.dart:118-127` + `_persistReview`, `guess_provider.dart:233-247`, `recall_provider.dart` implementation pass, `fill_provider.dart:131-176` and `submitAnswer` path, and `match_provider.dart:209-231`.

## 5. UI mismatches

- The docs imply a session-entry flow that starts from container selection and returns the first session snapshot, but the implementation exposes a recommendation hub plus direct single-mode routes instead of a session-start surface. Doc: `lib/features/study/docs/07_use_cases_and_checklist.md:17-24`. Code: `lib/features/study/presentation/screens/study_screen.dart:93-109`, `lib/features/study/presentation/widgets/study_recommendation_card.dart:46-77`.
- The docs treat `modePlan` as a real study progression, but the UI only renders it as decorative chips while launching one mode at a time. Doc: `lib/features/study/docs/01_business_context.md:103-105`, `lib/features/study/docs/03_session_lifecycle.md:29-36`, `lib/features/study/docs/04_mode_patterns.md:26-27`. Code: `lib/features/study/presentation/widgets/study_recommendation_card.dart:33-57`.
- The docs require an explicit unauthorized/no-access alternative flow, but there is no unauthorized UI state anywhere in the feature. Doc: `lib/features/study/docs/03_session_lifecycle.md:16-20`, `lib/features/study/docs/07_use_cases_and_checklist.md:26-30`. Code: no corresponding state or screen; hub/mode screens only render empty/in-progress/completed via `study_hub_content.dart:17-47`, `review_mode_screen.dart:149-217`, `guess_mode_screen.dart:74-179`, `recall_mode_screen.dart:110-197`, `fill_mode_screen.dart:137-210`, `match_mode_screen.dart:55-145`.
- The docs require UI affordances to be driven by `allowed actions`, but the implementation derives rendering from provider-local flags like `isAnswered`, `isFlipped`, `isRevealed`, `result`, and selected ids. Doc: `lib/features/study/docs/05_execution_rules.md:9-17`. Code: `lib/features/study/presentation/widgets/guess_round_view.dart:137-165`, `lib/features/study/presentation/widgets/review_round_view.dart:60-73`, `lib/features/study/presentation/widgets/recall_round_view.dart:63-78`, `lib/features/study/presentation/widgets/fill_round_view.dart:102-128`.
- The docs require retry to be a visible part of the flow when failed items remain, but there is no generic retry-phase UI. Review/guess/fill quietly requeue or retry within the same surface; recall now keeps missed cards in-session without a separate retry surface; match still does not present a docs-style board fail/retry phase. Doc: `lib/features/study/docs/03_session_lifecycle.md:49-60`, `lib/features/study/docs/05_execution_rules.md:56-64`. Code: review `review_provider.dart:158-191`; guess `guess_provider.dart:115-174`, `guess_provider.dart:249-339`; fill `fill_provider.dart:178-230`; recall retry handling `recall_provider.dart:111-125`, `recall_provider.dart:220-259`; match completion `match_mode_screen.dart:55-69`.
- The docs expect completion after the session, but the UI exposes completion per mode. That is a UI-level drift because users see a completed study flow after one mode, not after a full `modePlan`. Doc: `lib/features/study/docs/03_session_lifecycle.md:63-72`. Code: mode completion surfaces in `review_mode_screen.dart:157-217`, `guess_mode_screen.dart:103-179`, `recall_mode_screen.dart:118-197`, `fill_mode_screen.dart:145-210`, `match_mode_screen.dart:89-145`.
- Recall docs include timeout-driven reveal as an explicit alternative flow, but the UI only provides manual reveal and mark-missed. Doc: `lib/features/study/docs/04_mode_patterns.md:185-196`. Code: `lib/features/study/presentation/widgets/recall_round_view.dart:71-78`, `lib/features/study/presentation/screens/recall_mode_screen.dart:203-219`.
- Guess docs include timeout as an alternative flow, but the UI only provides manual select, skip, and continue. Doc: `lib/features/study/docs/04_mode_patterns.md:142-146`. Code: `lib/features/study/presentation/widgets/guess_round_view.dart:137-165`.
- Match docs describe board pass/fail and grouped boards. The current UI now surfaces grouped-board progress, but it still does not expose board-level fail/retry states. Doc: `lib/features/study/docs/04_mode_patterns.md:93-103`. Code: `lib/features/study/presentation/widgets/match_round_view.dart:21-53`, `lib/features/study/presentation/screens/match_mode_screen.dart:89-145`.

## 6. State flow mismatches

- The docs define one generic session lifecycle, but the code uses five disconnected provider state machines plus a hub. There is no feature-level state machine spanning eligibility, creation, active learning, retry, session completion, and long-term update. Doc: `lib/features/study/docs/03_session_lifecycle.md:5-12`. Code: direct mode routing in `study_screen.dart:93-99` and mode-local providers under `lib/features/study/presentation/providers/*_provider.dart`.
- The docs require a generic session snapshot with `allowedActions`, `modeState`, `currentItem`, and `sessionCompleted`; the code persists only `deckId`, `mode`, optional session row, and opaque payload. Doc: `lib/features/study/docs/05_execution_rules.md:13-17`, `lib/features/study/docs/02_domain_model.md:77-89`. Code: `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`.
- The docs require start-session eligibility checks and refusal reasons before session creation; the code starts sessions inside each mode provider or repository without permission/container validation. Doc: `lib/features/study/docs/03_session_lifecycle.md:16-25`, `lib/features/study/docs/07_use_cases_and_checklist.md:11-30`. Code: mode providers start directly; repository start contract summarized in `lib/features/study/domain/usecases/start_study_session.dart:10-13` and `lib/features/study/data/repositories/study_repository_impl.dart:27-42`.
- The docs require retry-pending items to block mode completion until resolved; recall now follows that rule by keeping missed cards in-session until the retry is resolved, but match still completes without a docs-defined board fail/retry state. Doc: `lib/features/study/docs/03_session_lifecycle.md:51-67`, `lib/features/study/docs/05_execution_rules.md:56-64`. Code: recall retry handling `recall_provider.dart:111-125`, `recall_provider.dart:220-259`; match completion `match_provider.dart:203-260`.
- The docs expect completion only after the final mode in the `modePlan`; the code marks a `StudySession` complete from inside each mode provider. Doc: `lib/features/study/docs/03_session_lifecycle.md:63-67`, `lib/features/study/docs/07_use_cases_and_checklist.md:73-84`. Code: `review_provider.dart:243-263`, `guess_provider.dart` completion path from implementation pass, `recall_provider.dart:238-259`, `fill_provider.dart` completion path from implementation pass, `match_provider.dart:170-188`.
- The docs recommend separating short-term session outcome from long-term learning-state update; the code updates long-term card state during mode interaction before any session-level completion decision. Doc: `lib/features/study/docs/06_learning_lifecycle.md:30-37`. Code: provider-level persistence and SRS update paths, e.g. `review_provider.dart:118-127`, `guess_provider.dart:233-247`, `fill_provider.dart:123-176`, plus implementation pass summary for recall and match.
- The docs define `RESET_CURRENT_MODE` as a generic action; the code implements reset only as route-level `Start over`, not as part of a generic state machine. Doc: `lib/features/study/docs/05_execution_rules.md:32-37`, `lib/features/study/docs/06_learning_lifecycle.md:57-61`. Code: `study_screen.dart:70-90`, `study_active_session_card.dart:59-63`.
- The docs require resume to restore `allowed actions`; the code restores enough payload to rebuild a mode screen but not a normalized legal-action set. Doc: `lib/features/study/docs/06_learning_lifecycle.md:46-50`. Code: `study_screen.dart:63-90`, `active_study_session_store.dart:23-49`, plus mode-specific restore methods in providers.
- The docs require invalid action and invalid payload handling as alternative flows; the code mostly uses silent early returns. Doc: `lib/features/study/docs/07_use_cases_and_checklist.md:57-60`. Code: `review_provider.dart:104-114`, `guess_provider.dart:176-185`, `fill_provider.dart:240-260`, `match_provider.dart:112-123`, and recall provider per implementation pass.

## 7. Silent assumptions in implementation

- One global active study snapshot exists for the whole app. The implementation assumes only one resumable study flow at a time. `lib/features/study/presentation/providers/active_study_session_store.dart:23-49`.
- Leaving a mode via the exit dialog always preserves resumable state. The dialog is confirmation-only; it does not offer discard/save variants. `review_mode_screen.dart:73-85`, `guess_mode_screen.dart:53-65`, `recall_mode_screen.dart:75-87`, `fill_mode_screen.dart:103-115`, `match_mode_screen.dart:74-85`.
- `modePlan` is treated as recommendation metadata, not runtime state. `study_recommendation_card.dart:33-57`.
- Review mode assumes richer UI than docs describe: keyboard shortcuts, swipe gestures, and flagging. `review_round_view.dart:35-43`, `review_mode_screen.dart`.
- Guess mode assumes a product policy of placeholder distractors and a small-deck warning instead of refusing to start or degrading differently. `guess_round_view.dart:40-45`.
- Fill assumes a product policy of manual accept/reject for close answers, but completion no longer branches into a separate practice-only loop. `fill_mode_screen.dart:145-210`, `fill_provider.dart:123-176`.
- Match assumes grouped boards with timer/stars scoring, but still no explicit board-level fail/retry state. `match_mode_screen.dart:89-145`, `match_provider.dart:203-260`.
- Card editing is reachable from recall reveal phase and completion mistake panels, but the docs never mention edit navigation as part of study flow. `recall_mode_screen.dart:207-215`, `review_mode_screen.dart:206-210`, `guess_mode_screen.dart:153-163`, `fill_mode_screen.dart:187-193`, `match_mode_screen.dart:123-130`.
- Loading and async error states are delegated to `AppAsyncBuilder` without a study-specific contract. `study_screen.dart:101-109`, mode screens listed above.

## 8. Fix priority

1. Implement or explicitly drop the generic session UI/state contract: `modePlan` execution, session snapshot, and `allowedActions`. This is the root cause of most UI and flow drift.
2. Add missing refusal/access states to the UI and state model: `nothing to study`, unauthorized/no-access, and invalid start reasons at the session-entry level.
3. Normalize retry and completion behavior across modes, especially recall and match, so visible UI flow matches the documented retry-pending contract.
4. Decide and document exit/reset/resume policy, then encode it consistently in UI. The current implementation hard-codes “leave and keep resumable state.”
5. Decide whether implementation-only affordances are real product requirements. If yes, add them to docs; if not, remove or reframe them so the UI does not silently drift further.
6. Only after the session contract is settled, tighten loading/error/mutation feedback behavior. Those states are currently framework-driven and feature-generic, not study-specific.
