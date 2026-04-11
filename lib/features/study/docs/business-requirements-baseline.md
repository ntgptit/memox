# Business Requirements Baseline

## 1. Overview

This feature implements a guided study session that moves a learner through one or more interaction modes while the system tracks progress, exposes only allowed actions, and returns updated session state after each meaningful user decision.

Concrete code-level terms and their business meaning:

| Code term | Generic business meaning |
| --- | --- |
| `StudySessionData` | The active guided learning session |
| `sessionType` with `FIRST_LEARNING` or `REVIEW` | The business purpose of the session: initial exposure or follow-up practice |
| `activeMode` | The current interaction pattern used to study an item |
| `modePlan` | The ordered sequence of interaction patterns in the session |
| `allowedActions` | The backend-authorized actions available at the current point in the session |
| `modeState` | The current lifecycle state of the active interaction mode |


## 2. Business objective

- Help a learner study a deck through structured interaction patterns rather than a single static question type.
- Support both first-time learning and review-oriented learning.
- Keep the canonical session state authoritative in the backend while allowing the frontend to manage short-lived interaction feedback such as timers, input validation, and local animations.
- Let upstream business contexts launch study either as a direct deck action or as a reminder/recommendation follow-up.


## 3. Scope

Confirmed in current implementation:

- Launching a new session for a deck.
- Resuming an existing session by `sessionId`.
- Running the active session across review, guess, match, recall, and fill modes.
- Mutating session progress through reveal, remember, retry, next, answer submission, and pair submission.
- Resetting the current mode when allowed.
- Resetting overall deck study progress.
- Reading recommendation and analytics summaries from supporting features.
- Speech playback and optional autoplay for items with speech metadata.

Out of scope or only partially implemented in current code:

- A setup-first `/study` landing flow.
- Setup, history, result, and mode-picker screens as full business flows.
- Explicit study-session completion navigation.
- Session abandonment, pause, or exit rules.
- Study-specific permissions beyond global authenticated routing.


## 4. Actors and stakeholders

Primary actor:

- Learner: the authenticated user who starts, resumes, and progresses through a study session.

Supporting stakeholders:

- Product owner or BA: defines session purpose, rule intent, and expected learning outcomes.
- Frontend application: manages transient UI state, timing feedback, local validation, and error recovery.
- Backend study service: decides canonical state transitions, allowed actions, and authoritative progress updates.
- QA or tester: verifies each mode flow, edge case, and recovery path.


## 5. Business context

- The live production behavior is session-first rather than setup-first.
- The study runtime is entered from adjacent learning contexts or by direct session-route navigation, not from a standalone `/study` landing page.
- One upstream path can ask explicitly for first-learning or review behavior before session creation.
- Another upstream path can recommend a review opportunity, but the current launch handoff forwards only deck identity and leaves actual session-type resolution to backend defaults.
- The current implementation treats the backend as the source of truth for what should happen next, while the frontend supplements the experience with interaction-specific guidance and local timing.


## 6. Preconditions

Confirmed preconditions:

- The user must be authenticated at the application routing level.
- A valid deck identifier is required to start a session.
- A valid session identifier is required to resume a session.
- The backend must return an active session payload with current item data, mode information, and allowed actions.

Probable but not fully evidenced in this feature:

- The selected deck must contain study-eligible items.
- The backend likely determines whether first learning or review is available for the deck.


## 7. Triggers

Confirmed triggers:

- User selects a direct learning action from an upstream deck-oriented context.
- User selects a recommended deck from an upstream reminder or analytics context.
- User navigates directly to the study session route with deck data.
- User resumes a session by route parameter.
- User performs an allowed action inside an active study session.


## 8. Main business flows

### Flow A: Start or resume a session

- The actor enters the live session runtime from a deck-related context, a recommendation context, or a direct session route.
- The system decides whether to start a new session or resume an existing session based on the presence of `sessionId`.
- The backend returns canonical session data.
- The screen renders the active mode using the session payload and initializes local transient state for that item.


### Flow B: Execute an item inside the active mode

- The system presents the current item using the active interaction mode.
- The actor interacts using the controls available for that mode.
- The frontend may evaluate short-lived interaction rules locally.
- The canonical session is mutated only through repository-backed commands.
- The backend returns updated session data reflecting the next allowable state.


### Flow C: Progress to the next item or mode

- When the current step is complete, the actor or the frontend triggers `GO_NEXT`.
- The backend returns the next item in the same mode, the first item of the next mode, or a completed session.
- The frontend resets local transient state when item identity changes.


### Flow D: Reset the current mode

- When `RESET_CURRENT_MODE` is present in allowed actions, the system exposes a reset option.
- The actor must confirm the reset.
- The backend returns the mode reset to its initial state.


## 9. Alternate flows

- A session can be started with an explicitly preferred type from a specialized launch context, but the backend still decides the actual returned session type.
- A recommendation-driven launch starts a session without passing the recommended type to the launcher; the session type is therefore determined by backend defaults.
- In fill mode, the actor can reveal the answer, review the correct text, and retry the same item before moving on.
- In recall mode, the actor can reveal manually before timeout instead of waiting for the countdown to expire.
- In review mode, the actor can advance using gestures rather than a traditional action bar.
- In review mode, backward progression is unavailable on the first completed position even though forward swipe remains allowed.


## 10. Exception and failure flows

- If session loading fails, the screen shows an error state with a retry command that invalidates and reloads the provider.
- If a mutation fails while local feedback is in progress, the relevant local provider clears pending local success state so the item does not appear completed incorrectly.
- If recall reveal fails after countdown timeout, the countdown is restarted locally.
- If speech playback fails, the error is stored in local speech state rather than thrown as a hard session failure.
- If the user attempts a session action while canonical session data is missing, the screen throws a fail-fast state error.


## 11. Business rules

Confirmed rules:

- The presence of `sessionId` changes the entry behavior from new-session creation to session resumption.
- The backend-defined `allowedActions` list controls which canonical actions are available.
- Fill mode intentionally swaps clue and expected-entry fields: it displays `currentItem.answer` as the visible clue and validates learner input against `currentItem.prompt`.
- Fill-mode free text is validated locally before submission.
- Recall has a timed branch that automatically reveals the answer after countdown expiry.
- Guess and match use delayed local feedback before canonical progression.
- Current-mode reset requires both backend permission and explicit user confirmation.
- Review-mode backward navigation is not allowed on the first completed position.
- `/study` itself is not a live setup entry; only the session route is currently wired as a full runtime path.

Key inferred rule:

- The backend likely owns scoring, scheduling, and whether an action should lead to another item, another mode, or overall session completion, because every meaningful mutation replaces the canonical session state with backend data.


## 12. Validations and constraints

Confirmed validations:

- Fill mode rejects empty input and exposes a required-input error.
- Fill mode compares normalized strings rather than raw strings.
- Match mode can submit only when all required pairs are matched and no feedback lock is active.
- Guess mode blocks interaction while feedback or submission is pending.
- Recall mode reveals automatically only while countdown is active.
- Speech autoplay is skipped unless speech is available, item metadata requests autoplay, and speech actions include `play_speech`.
- Manual speech playback is exposed in current UI when speech is available, but the playback provider itself does not enforce `enabled` or speech action permissions.

Constraints with business impact:

- The frontend must not invent canonical actions not returned by the backend, except for one recall-timeout fallback where the UI can surface a next action even if `GO_NEXT` is missing.
- Local sub-mode state must be reset when item identity changes, otherwise stale feedback would bleed into the next item.
- The feature assumes stable item identity through `flashcardId`.


## 13. Inputs and outputs

Inputs:

- Deck identity: `deckId`, `deckName`
- Optional session identity: `sessionId`
- Optional preferred session type when launched from a specialized direct-start context
- Mode-specific learner responses:
  - free text
  - single choice label selection
  - matched pairs
  - reveal, remembered, retry, next, reset, and speech actions

Outputs:

- Updated canonical session payload from the backend
- Updated session progress summary
- Mode change or item change
- Local feedback such as validation errors, reveal state, speech status, countdown state, and success or failure animations
- Restart navigation from result flow fallback when deck context is missing


## 14. State model and transitions

Canonical states confirmed in code:

- Asynchronous screen state: loading, data, error
- Mode lifecycle: `INITIALIZED`, `IN_PROGRESS`, `WAITING_FEEDBACK`, `COMPLETED`
- Session completion field: `sessionCompleted` exists in the payload model, but no scanned in-scope flow or test demonstrates it becoming `true`

Local transient states confirmed in code:

- Fill: input value, required-input error, revealed answer, mismatch index, retry-ready state
- Guess: selected choice, pending submit, temporary success or error lock
- Match: selected left and right values, staged matched pairs, temporary wrong or success feedback, submit readiness
- Recall: countdown active or stopped, manual reveal, timeout reveal, remembered or retry pending submit, next-only branch after timeout
- Speech: idle, playing, stopped, error

High-level transition pattern:

- Session starts or resumes into a canonical active mode.
- Local provider state syncs to the current item.
- The actor performs a mode interaction.
- The frontend may create local feedback or validation state.
- A repository-backed action updates the canonical session.
- The next session payload resets local state as needed and may change item, mode, or session completion.


## 15. Data definitions with business meaning

| Data element | Business meaning |
| --- | --- |
| `StudyChoice` | A visible choice option; in current guess-mode runtime the submitted value is the displayed `label`, not `id` |
| `StudySessionData` | The authoritative current session snapshot |
| `StudySessionItemData` | The current study item and all content needed to render or answer it; field meaning is mode-dependent, and fill mode swaps the visible clue (`answer`) and expected entry (`prompt`) |
| `StudyProgressSummary` | Progress indicators for current session completion and item counts |
| `allowedActions` | The list of actions the learner is currently allowed to perform |
| `modePlan` | The ordered interaction plan spanning one or more study modes |
| `SpeechCapability` and `SpeechPreference` | Availability and preference controls for item speech playback |
| `StudyPreference.firstLearningCardLimit` | Business limit controlling first-learning session size, default 20 and bounded 1 to 100 |
| `ReminderRecommendation` | Suggested review opportunity derived from study reminders |

## 16. External dependencies and integrations

- Route layer: passes deck and session identifiers into the study feature.
- Study repository: all canonical mutations and reads flow through it.
- Remote study API: starts sessions, resumes sessions, mutates answers, resets mode, resets progress, and reads analytics summaries.
- Upstream direct-start context: can launch sessions and request deck progress reset.
- Upstream recommendation context: can surface reminder-based launch opportunities.
- Speech infrastructure: provides playback services through speech contracts and adapters.


## 17. Permissions or role-related behavior if relevant

Confirmed:

- The application router enforces authentication before allowing access to the study routes.

Not evidenced inside this feature:

- No study-specific role, ownership, or permission differences were found.
- No instructor, admin, moderator, or shared-session behaviors were found.


## 18. Edge cases

- Recommendation-driven launch may not preserve the recommended session type because the route does not pass it forward.
- Review backward swipe on the first position is rejected and only shows a notification.
- Fill reveal on empty input still marks the item incorrect and shows the correct answer.
- Guess incorrect feedback clears after a short delay and does not submit a backend mutation.
- Match selection on already-matched values is ignored.
- Recall timeout changes the visible action pattern and may expose a fallback next action.
- Speech sync on the same item is a no-op to avoid redundant restarts.
- The completion flag can change next-action wording to completion wording if the backend ever sends `sessionCompleted = true`, but that state is not observed in scanned runtime flows.
- Unknown active mode is handled inconsistently: the factory throws, while one widget switch has a silent empty fallback.
- A legacy duplicate route screen exists, but the live router uses the active session screen instead.


## 19. Assumptions

Strong assumptions grounded in code structure:

- The backend owns canonical correctness, scoring, and progression logic.
- `allowedActions` is the contract that should drive UI availability and supported commands.
- `flashcardId` is stable enough to be used as the item identity for local-state reset.
- The same session can span multiple modes in sequence.

Weaker assumptions:

- The backend likely decides whether a deck should start with first learning or review when the frontend does not specify a preferred type.
- Placeholder or duplicate study screens are reserved for future expansion or legacy cleanup rather than currently hidden runtime functionality.


## 20. Ambiguities and open questions

- What precise business rule determines whether a recommendation-driven launch should create a review session, given that the current launcher path does not forward the recommended session type?
- What should happen when `sessionCompleted` becomes true, given that the model and labels support it but no scanned in-scope flow produces that state?
- Is the recall-timeout fallback next action a deliberate product rule or only a UI resilience mechanism?
- What are the intended business responsibilities of setup, history, result, and mode-picker screens, given that setup is not in the live route tree and the others are only partially wired?
- Should manual speech playback also honor `SpeechCapability.enabled` and speech `allowedActions`, instead of relying mostly on `speech.available`?
- Which business outcome is expected for unsupported or newly added modes, given the current mismatch between fail-fast factory logic and silent empty UI fallback?
- Should the broader legacy study documentation continue to describe session types and state branches that are not represented in the owned runtime contract?


## 21. Developer notes for implementation alignment

- Treat the repository contract as the canonical business boundary. Local providers should manage only transient interaction state, not canonical scoring or progression.
- Preserve the distinction between backend-authorized actions and frontend convenience behavior. Any new mode should define how `allowedActions`, local validation, and auto-advance interact.
- Treat `prompt` and `answer` as mode-dependent fields rather than universal question/solution labels. Fill mode deliberately reverses the visible clue and the expected learner entry.
- Keep item-change synchronization strict. Any new local provider should reset stale feedback when `flashcardId` changes.
- Treat the session route as the live business entry. Do not design new behavior around `/study` base routing or placeholder setup screens unless those flows are implemented first.
- If adding session completion or result flows, decide whether navigation is backend-driven, route-driven, or user-confirmed, because the current code only proves completion-ready labeling and not a full completion journey.
- Resolve the unknown-mode inconsistency before introducing new modes.
- If recommendation-driven launch is expected to honor recommended type, pass that preference through the route or explicitly document that backend defaults override the recommendation.
- Align speech rules across payload, provider, and UI surfaces so autoplay, manual play, and replay use the same business gates.


## 22. Suggested test scenarios

- Start a new session from deck context with and without a preferred session type.
- Confirm `/study` base routing redirects away and that the live runtime starts only from the session route.
- Resume an existing session and confirm canonical state replacement.
- Verify each mode honors `allowedActions` and local locks.
- Confirm fill input validation, reveal, retry, and conditional auto-advance behavior.
- Confirm guess correct and incorrect timing behavior.
- Confirm match wrong-pair recovery, staged success feedback, and submit gating.
- Confirm recall manual reveal, timeout reveal, remembered, retry, and failure recovery.
- Confirm reset current mode requires confirmation and returns to an initial state.
- Confirm deck progress reset works only after explicit confirmation from launch context.
- Confirm loading failure shows retry and can recover.
- Confirm speech autoplay and manual replay honor availability and permission rules.
- Confirm the recommendation launch path either intentionally uses backend defaults or is corrected to pass the intended session type.
