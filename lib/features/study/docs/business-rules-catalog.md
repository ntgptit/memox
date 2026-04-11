# Business Rules Catalog

## BR-001 Session entry is determined by session identity

- Rule ID: `BR-001`
- Rule name: Session entry path resolution
- Description: The study feature starts a new session when no session identifier is supplied and resumes an existing session when a session identifier is present.
- Trigger condition: The actor enters the session route or provider is created.
- Applicable scope: Session initialization
- Decision logic: If `sessionId` is `null`, call start-session behavior; otherwise call resume-session behavior.
- Expected outcome: The canonical session is loaded from the correct backend endpoint.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-002 Preferred session type is advisory, not authoritative

- Rule ID: `BR-002`
- Rule name: Preferred session type delegation
- Description: The frontend may request a preferred session type, but the backend remains authoritative because the returned session payload determines the actual session type.
- Trigger condition: Session launch from a specialized direct-start context with a preferred type.
- Applicable scope: Session start
- Decision logic: Pass `preferredSessionType` when available; accept returned `sessionType` from backend as truth.
- Expected outcome: The session starts in the backend-chosen session type.
- Exceptions: The recommendation-driven launch path currently does not forward the recommendation type at all.
- Confidence level: confirmed

## BR-003 Deck progress reset requires explicit confirmation

- Rule ID: `BR-003`
- Rule name: Reset-progress confirmation
- Description: Resetting a deck's study progress is a destructive action and requires explicit user confirmation before execution.
- Trigger condition: The actor chooses the reset-progress option from a direct-start launch context.
- Applicable scope: Deck-level learning progress
- Decision logic: Show confirmation dialog; execute reset only on affirmative response.
- Expected outcome: Deck progress is reset and the deck can restart first-learning flow.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-004 Allowed actions govern canonical study commands

- Rule ID: `BR-004`
- Rule name: Backend-authorized action control
- Description: The frontend should expose and execute only those canonical commands that are present in `allowedActions`.
- Trigger condition: Session screen renders controls or processes actions.
- Applicable scope: All study modes
- Decision logic: Build action availability from `allowedActions` and mode-specific strategy rules.
- Expected outcome: The actor sees only actions currently allowed for the active business state.
- Exceptions: Recall timeout UI may synthesize a next action when backend data is incomplete.
- Confidence level: confirmed

## BR-005 Fill-mode free text uses normalized comparison

- Rule ID: `BR-005`
- Rule name: Normalized text comparison
- Description: Fill-mode answers are validated by normalized string comparison rather than raw exact text equality.
- Trigger condition: The actor submits a fill-mode answer.
- Applicable scope: Fill mode
- Decision logic: Normalize input and target text; determine exact match and first mismatch index from normalized values.
- Expected outcome: Equivalent text variants can match even when raw formatting differs.
- Exceptions: Exact normalization rules are implementation-defined rather than explicitly documented.
- Confidence level: confirmed

## BR-006 Empty fill input is invalid

- Rule ID: `BR-006`
- Rule name: Required free-text input
- Description: A fill response cannot be submitted when the input is empty.
- Trigger condition: The actor tries to submit fill-mode input with no value.
- Applicable scope: Fill mode
- Decision logic: Detect empty input and set a required-input error instead of submitting.
- Expected outcome: The actor receives immediate validation feedback and the backend is not called.
- Exceptions: Revealing the answer is still possible even when input is empty.
- Confidence level: confirmed

## BR-007 Fill reveal counts the attempt as incorrect

- Rule ID: `BR-007`
- Rule name: Reveal-is-incorrect policy
- Description: Using reveal in fill mode marks the current attempt as incorrect and exposes the correct answer, but the actor may still retry before leaving the item.
- Trigger condition: The actor chooses help or reveal in fill mode.
- Applicable scope: Fill mode
- Decision logic: Local fill state marks the item incorrect; canonical reveal action is invoked.
- Expected outcome: The answer becomes visible and retry is made available when supported by the session state.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-008 Auto-advance is conditional on backend readiness

- Rule ID: `BR-008`
- Rule name: Conditional auto-advance
- Description: Local success feedback may trigger automatic progression only when the returned canonical session allows `GO_NEXT`.
- Trigger condition: A mode-specific local interaction completes successfully.
- Applicable scope: Guess, match, recall, and fill modes
- Decision logic: Perform local success handling, then inspect updated canonical session for `GO_NEXT` before invoking next.
- Expected outcome: The item advances automatically only when backend state is ready.
- Exceptions: If mutation fails, local pending success state is cleared.
- Confidence level: confirmed

## BR-009 Guess mode locks interaction during feedback

- Rule ID: `BR-009`
- Rule name: Guess interaction lock
- Description: Once a guess is being evaluated, further selection is blocked until feedback resolves.
- Trigger condition: The actor selects a choice in guess mode.
- Applicable scope: Guess mode
- Decision logic: Correct choice enters success-pending-submit; incorrect choice enters temporary error state; both lock further interaction.
- Expected outcome: The actor cannot change the answer while feedback is active.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-010 Match submission requires full pair completion

- Rule ID: `BR-010`
- Rule name: Full-pair completion gate
- Description: Match-mode submission is allowed only when all required pairs are matched and no active feedback state is blocking submission.
- Trigger condition: The actor is matching left and right values.
- Applicable scope: Match mode
- Decision logic: Maintain selected values and matched pairs; compute `canSubmit` only when all pairs are complete and stable.
- Expected outcome: The system submits matched pairs only after full completion.
- Exceptions: Wrong pair selection produces temporary error feedback and clears without submission.
- Confidence level: confirmed

## BR-011 Recall auto-reveals on timeout

- Rule ID: `BR-011`
- Rule name: Timed recall reveal
- Description: Recall mode starts a countdown for a new item and automatically reveals the answer when time expires.
- Trigger condition: A new recall item is shown and countdown is active.
- Applicable scope: Recall mode
- Decision logic: Start a 15-second timer; when it reaches zero, set reveal state and pending reveal behavior.
- Expected outcome: The actor moves from attempt phase to feedback phase even without manual action.
- Exceptions: If reveal processing fails, the countdown can restart.
- Confidence level: confirmed

## BR-012 Manual recall reveal differs from timeout reveal

- Rule ID: `BR-012`
- Rule name: Recall reveal branch split
- Description: Manual reveal and timeout reveal produce different follow-up action behavior.
- Trigger condition: The actor reveals manually or countdown reaches zero.
- Applicable scope: Recall mode
- Decision logic: Manual reveal keeps standard reveal branch behavior; timeout reveal sets `showsNextActionOnly` and may change visible actions.
- Expected outcome: Timeout produces a more constrained follow-up action pattern than manual reveal.
- Exceptions: Fallback next action may be synthesized by the UI if the backend omits `GO_NEXT`.
- Confidence level: confirmed

## BR-013 Review backward movement is blocked at the starting boundary

- Rule ID: `BR-013`
- Rule name: Review backward boundary
- Description: The actor cannot move backward before the first completed review position.
- Trigger condition: The actor swipes backward on the first review card position.
- Applicable scope: Review mode
- Decision logic: Detect zero completed items and reject backward navigation.
- Expected outcome: The actor stays on the current card and receives a notification.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-014 Current-mode reset requires permission and confirmation

- Rule ID: `BR-014`
- Rule name: Mode reset authorization
- Description: Resetting the current mode is allowed only when the backend says it is allowed and the user confirms.
- Trigger condition: The actor opens the session menu.
- Applicable scope: Active study session
- Decision logic: Show the reset option only if `RESET_CURRENT_MODE` is present; require confirmation before executing.
- Expected outcome: The current mode returns to its initial business state.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-015 Speech playback is gated by availability and permission

- Rule ID: `BR-015`
- Rule name: Speech playback gating
- Description: Autoplay is more tightly gated than manual playback. Autoplay requires available speech, the item's autoplay flag, and a `play_speech` capability, while manual playback in current UI is exposed mainly when speech is available and the provider itself only requires available speech text.
- Trigger condition: A new item is shown or the actor requests playback.
- Applicable scope: Any item with speech support
- Decision logic: On item sync, autoplay runs only when `available`, `autoPlay`, and `play_speech` are all present. Manual playback requests are surfaced by current UI when `speech.available` is true, and the playback provider skips only when speech is unavailable or speech text is empty.
- Expected outcome: Autoplay is conservative; manual playback is broader unless UI layers add extra gating.
- Exceptions: `SpeechCapability.enabled` exists in payloads but is not enforced in the scanned frontend scope. Playback errors are captured in local state.
- Confidence level: confirmed

## BR-016 Recommendation launch can drift from recommendation intent

- Rule ID: `BR-016`
- Rule name: Recommendation-type drift
- Description: A recommendation can tell the actor that review is suggested, but the current launch path does not forward the suggested session type into the study start request.
- Trigger condition: The actor starts study from a reminder or analytics recommendation.
- Applicable scope: Recommendation-driven launch
- Decision logic: Navigate with deck identity only; omit `preferredSessionType`.
- Expected outcome: Backend defaults determine the actual started session type.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-017 Unknown-mode handling is inconsistent

- Rule ID: `BR-017`
- Rule name: Unsupported mode inconsistency
- Description: The current implementation does not define a single business outcome for an unsupported mode because one layer throws while another layer has an empty fallback.
- Trigger condition: The session returns an unknown `activeMode`.
- Applicable scope: Mode dispatch
- Decision logic: Strategy factory throws; one widget switch returns an empty box.
- Expected outcome: Business outcome is ambiguous and should be clarified before extending modes.
- Exceptions: None evidenced.
- Confidence level: ambiguous

## BR-018 Fill mode reverses clue and expected-entry fields

- Rule ID: `BR-018`
- Rule name: Fill prompt-answer inversion
- Description: Fill mode does not use the study item's text fields in the same way as other modes. It displays the answer-side text as the visible clue and expects the learner to type the prompt-side text.
- Trigger condition: The active mode is fill and the view model is built.
- Applicable scope: Fill mode
- Decision logic: The fill strategy maps `currentItem.answer` into the visible prompt field and `currentItem.prompt` into the reveal or expected-answer field; submission is evaluated against `currentItem.prompt`.
- Expected outcome: The learner sees one side of the card as the clue and types the opposite side, even though the generic data model names remain `prompt` and `answer`.
- Exceptions: None evidenced.
- Confidence level: confirmed

## BR-019 Guess mode submits the displayed choice label

- Rule ID: `BR-019`
- Rule name: Guess submission payload mapping
- Description: In the current guess-mode runtime, the learner's selected visible label becomes the submitted answer payload. The `StudyChoice.id` field is not used during selection or submission in this frontend scope.
- Trigger condition: The actor presses a guess choice and local success feedback completes.
- Applicable scope: Guess mode
- Decision logic: Choice cards emit `choice.label`; the session screen evaluates correctness and submits that same label value.
- Expected outcome: Backend answer submission receives the displayed label string rather than a separate choice identifier.
- Exceptions: None evidenced.
- Confidence level: confirmed
