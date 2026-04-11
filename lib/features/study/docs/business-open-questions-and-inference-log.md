# Business Open Questions and Inference Log

## Confirmed behaviors

- The live runtime starts from the session route; `/study` itself redirects away and does not expose a setup-first entry.
- Session entry switches between start and resume based on whether `sessionId` exists.
- The backend returns the canonical session payload and the frontend replaces local canonical state with that payload after every meaningful mutation.
- The active session can run through review, guess, match, recall, and fill interaction modes.
- Fill mode uses reversed field roles: the learner sees `answer` as the clue and submits text validated against `prompt`.
- Fill mode supports reveal and retry behavior, with reveal counting as an incorrect outcome.
- Guess and match rely on short local feedback delays before canonical progression.
- Recall uses a countdown and automatically reveals the answer on timeout.
- Reset current mode requires both backend authorization and explicit user confirmation.
- Speech auto-play is stricter than manual playback because autoplay checks action metadata during item sync, while manual playback is exposed by UI availability rules and a looser provider gate.
- A legacy duplicate route screen exists, but the live router uses the active session screen instead.

## Strong inferences

- The backend owns correctness scoring, study scheduling, and progression sequencing because every significant business mutation returns a fresh canonical session snapshot.
- `allowedActions` is intended to be the primary contract between backend business state and frontend action availability.
- The session can span multiple modes for the same deck, rather than being limited to a single question format.
- Placeholder or duplicate study screens are reserved for future expansion or legacy cleanup rather than intentionally hidden complete flows.

Evidence basis: repository contract behavior, canonical state replacement, multi-mode fixtures, and placeholder screen implementations.

## Weak inferences

- The backend may decide between first-learning and review automatically when the frontend does not specify a preferred type.
- `SpeechCapability.available` may already include the effect of `SpeechCapability.enabled`, making explicit frontend checking unnecessary.
- The result screen may eventually become the intended destination when `sessionCompleted` becomes true, but current code does not enforce that flow and no scanned fixture demonstrates the flag becoming true.
- Client-side profile updates may rely on backend validation or clamping for study-preference limits because no owned frontend validator was found.

Evidence basis: missing forwarding in recommendation flow, current speech gating implementation, and route presence without behavioral linkage.

## Ambiguities

- Recommendation flow intent is unclear because the recommendation can imply review, but the current launch path does not pass a review preference into the launch request.
- The business meaning of `sessionCompleted` is incomplete because the field exists and changes action labels, but no in-scope automatic completion flow or true-valued payload is wired.
- The recall timeout fallback next action may be a deliberate product rule or only a resilience patch for incomplete backend action data.
- Unsupported mode handling is inconsistent across the feature.
- Speech capability fields are only partially enforced in scope: `available` drives UI exposure, autoplay also checks action metadata, and `enabled` is unused.
- The business purpose of setup, history, result, and mode-picker screens is not inferable from current implementation, and setup is not part of the live route tree at all.
- Legacy study documentation describes a broader policy surface than the owned runtime contracts currently prove.

## Missing evidence areas

- No confirmed abandonment, pause, or resume-later workflow beyond session resume by identifier.
- No confirmed rule for when or how analytics summaries are refreshed after session completion.
- No confirmed study-specific permission model beyond global authentication.
- No confirmed backend-side explanation for scoring, spaced repetition scheduling, or success thresholds.
- No confirmed payload or test fixture that sets `sessionCompleted` to `true`.
- No confirmed detailed result-summary behavior in the study feature itself.
- No confirmed client-side enforcement for `StudyPreference.firstLearningCardLimit`, even though bounds are declared in the model.

## Suggested questions for BA/PO/dev clarification

1. Should recommendation-driven launch explicitly preserve the recommended session type?
2. What is the intended user journey when `sessionCompleted` becomes true, and which backend payload should prove it?
3. Is recall-timeout fallback next-action behavior a product requirement or a defensive UI fallback?
4. What are the required business outcomes for setup, history, result, and mode-picker screens, and should setup become a live route at all?
5. How should unsupported future modes fail: visible error, safe fallback, or route-level recovery?
6. Should the frontend treat speech enablement and speech action metadata as separate gates from speech availability for manual playback as well as autoplay?
7. Are there any study-specific permissions, ownership rules, or deck eligibility rules that are enforced elsewhere?
8. Should the frontend enforce `firstLearningCardLimit` bounds locally, or is backend clamping the intended contract?
9. Should the broader legacy markdown set be narrowed to only the contract branches that the owned code actually proves?
