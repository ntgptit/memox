# Business Flow Catalog

## BF-001 Start a new study session

- Flow ID: `BF-001`
- Flow name: Start new session from launch context
- Goal: Open a new study session for a specific deck.
- Actor: Learner
- Preconditions: Authenticated user; valid deck identifier; launch surface available.
- Trigger: User chooses a study action from an upstream launch context, or navigates directly to the session route without `sessionId`.
- Main steps:
  - Collect deck context and optional preferred session type.
  - Invoke session start through the launcher or route-backed provider.
  - Receive canonical session payload from the backend.
  - Render the active mode and initialize local state for the current item.
- Alternate steps:
  - A specialized direct-start path can pass a preferred session type.
  - A recommendation-driven path starts without a preferred type.
- Failure steps:
  - If session loading fails, show retryable error state.
- Outputs: Active study session screen with current item, progress, actions, and mode metadata.
- Related rules: `BR-001`, `BR-002`, `BR-016`
- Related states: Async loading, async data, active `modeState`

## BF-002 Resume an existing session

- Flow ID: `BF-002`
- Flow name: Resume existing session
- Goal: Re-open a previously started session without creating a new one.
- Actor: Learner
- Preconditions: Authenticated user; valid `sessionId`.
- Trigger: User navigates to the study route with `sessionId`.
- Main steps:
  - The provider detects the supplied session identifier.
  - The repository requests the existing session from the backend.
  - The session screen renders the returned active item and mode.
- Alternate steps: None evidenced.
- Failure steps:
  - If resume fails, show retryable error state.
- Outputs: Resumed canonical session payload and synchronized local state.
- Related rules: `BR-001`
- Related states: Async loading, async data, async error

## BF-003 Complete a review interaction

- Flow ID: `BF-003`
- Flow name: Review interaction
- Goal: Let the learner inspect an item and move through review cards with gesture-driven progression.
- Actor: Learner
- Preconditions: Active mode is review; session item present.
- Trigger: Review item is displayed.
- Main steps:
  - Show the review card and progress shell.
  - Actor swipes within the card viewport to move through the interaction.
  - Non-backward swipe maps to the configured review action and then progresses to next if needed.
- Alternate steps:
  - Review can show replay-audio menu when speech is available.
- Failure steps:
  - Backward swipe at the first boundary is rejected with a notification.
- Outputs: Updated canonical session or unchanged current position if boundary is hit.
- Related rules: `BR-004`, `BR-013`, `BR-015`
- Related states: Review mode active, progress position state

## BF-004 Complete a guess interaction

- Flow ID: `BF-004`
- Flow name: Guess answer evaluation
- Goal: Let the learner choose one answer option and receive short feedback before canonical progression.
- Actor: Learner
- Preconditions: Active mode is guess; item choices present.
- Trigger: Actor taps a guess option.
- Main steps:
  - Lock further interaction.
  - Evaluate whether the selected choice is correct.
  - Carry the selected visible choice label forward as the submission value.
  - If correct, stage success feedback and queue backend submission.
  - If backend response permits `GO_NEXT`, progress automatically.
- Alternate steps:
  - If the answer is incorrect, clear the temporary error after a short delay and allow another attempt.
- Failure steps:
  - If canonical submission fails after local success, clear local guess state.
- Outputs: Updated session or reset local guess state for another attempt.
- Related rules: `BR-008`, `BR-009`, `BR-019`
- Related states: Guess pending success, guess temporary error, guess unlocked

## BF-005 Complete a match interaction

- Flow ID: `BF-005`
- Flow name: Match-pair completion
- Goal: Let the learner connect corresponding pairs and submit only when the full set is complete.
- Actor: Learner
- Preconditions: Active mode is match; pair data present.
- Trigger: Actor selects left and right values to form pairs.
- Main steps:
  - Track current left and right selection.
  - Evaluate the proposed pair.
  - If correct, show short success feedback and commit the pair into matched state.
  - When all pairs are matched and no feedback lock remains, submit matched pairs to the backend.
  - If backend response permits `GO_NEXT`, progress automatically.
- Alternate steps:
  - Existing valid matched pairs are retained when local state syncs to the same item.
- Failure steps:
  - Wrong pairs show temporary error feedback and then clear.
  - If canonical submit fails, local pending completion state is cleared.
- Outputs: Updated session or current item with remaining unmatched pairs.
- Related rules: `BR-008`, `BR-010`
- Related states: Match selecting, match error feedback, match success feedback, match-ready-to-submit

## BF-006 Complete a recall interaction

- Flow ID: `BF-006`
- Flow name: Timed recall interaction
- Goal: Let the learner attempt recall within a countdown window and then mark remembered or retry.
- Actor: Learner
- Preconditions: Active mode is recall; current item present.
- Trigger: Recall item is shown.
- Main steps:
  - Start a countdown for the new item.
  - Let the learner reveal manually or wait for timeout.
  - After reveal, let the learner mark remembered or retry.
  - Submit the chosen outcome to the backend after short local feedback.
  - If backend permits `GO_NEXT`, progress automatically.
- Alternate steps:
  - Timeout reveal constrains visible actions differently from manual reveal.
- Failure steps:
  - If reveal fails after timeout, restart the countdown.
  - If remembered or retry submission fails, clear pending local state.
- Outputs: Updated session or recovered recall attempt state.
- Related rules: `BR-008`, `BR-011`, `BR-012`
- Related states: Countdown active, answer revealed, next-only timeout branch, remembered pending submit, retry pending submit

## BF-007 Complete a fill interaction

- Flow ID: `BF-007`
- Flow name: Fill answer and recovery interaction
- Goal: Let the learner type an answer, validate it, reveal help when needed, and retry before moving on.
- Actor: Learner
- Preconditions: Active mode is fill; free-text answer is expected.
- Trigger: Actor enters or submits text, or chooses reveal help.
- Main steps:
  - Display the answer-side clue and the answer-entry area.
  - Validate that input is present.
  - Compare normalized input with the prompt-side target text defined for fill validation.
  - Submit the answer if valid.
  - If backend returns `GO_NEXT`, progress automatically.
- Alternate steps:
  - The actor can reveal the answer, see mismatch comparison, and retry the same item.
  - Recovered retry input can remain visible after feedback.
- Failure steps:
  - Empty input shows a required-input error without submitting.
  - If canonical submission fails after local success, reset local fill result.
- Outputs: Updated session, revealed answer state, retry-ready state, or input validation message.
- Related rules: `BR-005`, `BR-006`, `BR-007`, `BR-008`, `BR-018`
- Related states: Fill input ready, required-input error, answer revealed, recovered retry

## BF-008 Reset the current mode

- Flow ID: `BF-008`
- Flow name: Current-mode reset
- Goal: Restart the current study mode from its initial state without leaving the session.
- Actor: Learner
- Preconditions: Active session exists; `RESET_CURRENT_MODE` is allowed.
- Trigger: Actor chooses reset-current-mode from the session menu.
- Main steps:
  - Show confirmation dialog.
  - On confirmation, invoke mode reset through the repository.
  - Replace canonical session state with the returned initial mode state.
- Alternate steps:
  - If reset is not allowed, no reset menu option is shown.
- Failure steps:
  - Standard mutation failure behavior applies and canonical state remains unchanged.
- Outputs: Current mode reset to an initial state.
- Related rules: `BR-014`
- Related states: Mode initial state, current session data

## BF-009 Reset deck progress from launch context

- Flow ID: `BF-009`
- Flow name: Deck progress reset
- Goal: Clear deck-level study progress before starting over.
- Actor: Learner
- Preconditions: Deck context available; reset option surfaced by a direct-start launch context.
- Trigger: Actor chooses reset-progress from learning options.
- Main steps:
  - Show destructive confirmation dialog.
  - If confirmed, call progress reset command.
  - Return control to launch surface so the actor can start again.
- Alternate steps:
  - If the actor cancels, no change occurs.
- Failure steps:
  - If reset fails, the caller shows an unavailable or failure message.
- Outputs: Deck progress reset or unchanged progress.
- Related rules: `BR-003`
- Related states: Deck progress before reset, deck progress after reset

## BF-010 Start from recommendation

- Flow ID: `BF-010`
- Flow name: Recommendation-driven session launch
- Goal: Let the learner act on a reminder recommendation from study analytics.
- Actor: Learner
- Preconditions: A reminder or analytics overview includes a recommendation.
- Trigger: Actor selects the recommendation call to action.
- Main steps:
  - Display recommended deck and reminder context.
  - Navigate to the study session route using deck identity.
  - Start the session using default route behavior.
- Alternate steps: None evidenced.
- Failure steps:
  - If the started session type differs from the recommendation, the discrepancy is not explained inside the flow.
- Outputs: Opened study session for the recommended deck.
- Related rules: `BR-002`, `BR-016`
- Related states: Recommendation present, session loading

## BF-011 Recover from session loading failure

- Flow ID: `BF-011`
- Flow name: Session load recovery
- Goal: Recover from failure to load or reload the active session.
- Actor: Learner
- Preconditions: Session provider is in error state.
- Trigger: Session load or resume request fails.
- Main steps:
  - Show error presentation with retry command.
  - Invalidate the session provider.
  - Reload canonical session data.
- Alternate steps:
  - If a cached prior session exists while a reload is in progress, keep rendering that stale session shell during loading.
- Failure steps:
  - If retry fails again, remain in error state.
- Outputs: Recovered session view or repeated error.
- Related rules: `BR-001`
- Related states: Async error, async loading with cached data, async data

## BF-012 Placeholder supporting screens

- Flow ID: `BF-012`
- Flow name: Placeholder support surfaces
- Goal: Reserve navigation locations for setup, history, result, and mode-picking concerns.
- Actor: Learner
- Preconditions: Navigation reaches those screens.
- Trigger: Route navigation to placeholder study screens.
- Main steps:
  - Render placeholder or skeletal screen content.
  - In the result placeholder, expose actions for restart, history, and return-to-deck navigation.
- Alternate steps:
  - Result restart uses deck context when available.
  - Result restart falls back to the deck list when deck context is missing.
- Failure steps: None evidenced.
- Outputs: Minimal placeholder UI without confirmed end-to-end business workflow.
- Related rules: None
- Related states: Not enough evidence to define meaningful state transitions

## BF-013 Play item speech

- Flow ID: `BF-013`
- Flow name: Speech playback support
- Goal: Provide spoken guidance for the current item when speech is available.
- Actor: Learner
- Preconditions: Current item exposes speech data; speech is available for playback.
- Trigger: A new item is synced for autoplay, or the actor presses play or replay.
- Main steps:
  - Sync speech state when item identity changes.
  - Stop any prior playback.
  - If autoplay is allowed by item metadata and speech capabilities, start playback automatically.
  - If the actor presses play or replay, speak the current speech text from the currently exposed UI control.
- Alternate steps:
  - If the same item is synced again, do nothing.
  - Replay can be surfaced from session menu or mode-specific controls when speech is available.
- Failure steps:
  - If speech is unavailable or speech text is empty, the request is ignored.
  - If payload field `enabled` is false but `available` stays true, current frontend scope does not add an extra block.
  - If playback throws an error, the error is stored in local speech state.
- Outputs: Spoken audio, updated playback state, or stored playback error.
- Related rules: `BR-015`
- Related states: Speech idle, busy, playing, error
