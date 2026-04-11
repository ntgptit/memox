# Business State and Decision Model

## States identified

### Canonical session states

| State group | State | Business meaning |
| --- | --- | --- |
| Screen async state | Loading | Session data is being fetched or refreshed after a mutation. |
| Screen async state | Data | Session data is available and the learner can interact with the current item. |
| Screen async state | Error | The session could not be loaded or refreshed. |
| Mode lifecycle | `INITIALIZED` | The active mode is ready to start. |
| Mode lifecycle | `IN_PROGRESS` | The learner is actively attempting the current item. |
| Mode lifecycle | `WAITING_FEEDBACK` | The answer has been revealed or submitted and the system is waiting for follow-up action. |
| Mode lifecycle | `COMPLETED` | The current mode or its current step has completed. |
| Session-level flag | `sessionCompleted` payload field | A completion indicator exists in the payload model, but the scanned runtime does not prove a fully realized completed-session journey. |

### Local transient states

| Local controller | State highlights | Business meaning |
| --- | --- | --- |
| Fill | input, mismatch, required-input error, revealed answer, retry-ready | Free-text attempt and feedback state. |
| Guess | unlocked, temporary error, success pending submit | Choice evaluation state. |
| Match | active selections, temporary error, success feedback, can-submit | Pairing and staged completion state. |
| Recall | countdown active, answer revealed, next-only timeout branch, pending remembered or retry submit | Timed self-recall state. |
| Speech | idle, playing, error | Item speech playback state. |

## State transition table

| From state | Trigger | To state | Notes |
| --- | --- | --- | --- |
| Loading | Session fetch succeeds | Data | Canonical session becomes available. |
| Loading | Session fetch fails | Error | Retry is surfaced in the UI. |
| Error | Retry | Loading | Session loading is retried after provider invalidation. |
| Any data state | Canonical mutation begins | Loading with cached data | The shell can keep rendering the last resolved session while refresh is in progress. |
| `INITIALIZED` | Learner begins interaction | `IN_PROGRESS` or local active state | Exact canonical change is backend-driven; local providers may also start timers or selection logic. |
| `IN_PROGRESS` | Reveal or submit | `WAITING_FEEDBACK` | Reveal and answer submission typically move the interaction into feedback. |
| `WAITING_FEEDBACK` | Next or mode completion | `INITIALIZED` of next item or next mode | Backend decides the next canonical snapshot. |
| Last active step | Next after final item | `COMPLETED` mode state or backend-defined completion payload | Mode completion is evidenced more strongly than full session-completion behavior. |
| Any item | Item identity changes | Local state reset | Prevents stale feedback from leaking across items. |

## Decision points

| Decision point | Business question |
| --- | --- |
| Session start vs resume | Should the system create a new session or reopen an existing one? |
| Action visibility | Which canonical actions may the learner use now? |
| Fill validation | Is the typed answer acceptable, empty, or mismatched? |
| Guess evaluation | Is the selected choice correct or incorrect? |
| Match evaluation | Is the proposed pair valid, and is the full set complete? |
| Recall branch | Did reveal happen manually or because time expired? |
| Auto-advance | Is the updated session ready for automatic `GO_NEXT`? |
| Speech playback gating | Should speech auto-play, allow manual playback, or remain silent for this item? |

## Decision inputs

| Decision | Inputs |
| --- | --- |
| Session start vs resume | `sessionId` presence |
| Action visibility | `allowedActions`, `activeMode`, `modeState`, session completion flag |
| Fill validation | typed input, normalized target text, reveal state |
| Guess evaluation | selected choice, correct answer, pending feedback state |
| Match evaluation | selected left value, selected right value, known valid pairs, current feedback lock |
| Recall branch | countdown state, manual reveal command, timeout event |
| Auto-advance | updated canonical `allowedActions` after mutation |
| Speech playback gating | speech availability, speech content, autoplay preference, speech action metadata for autoplay, and UI exposure rules for manual playback |

## Decision outcomes

| Decision | Outcomes |
| --- | --- |
| Session start vs resume | Start a new backend session or fetch an existing session |
| Action visibility | Show buttons, show menu options, or hide unsupported controls |
| Fill validation | Submit answer, show required-input error, or show mismatch or reveal state |
| Guess evaluation | Temporary success then submit, or temporary error then retry |
| Match evaluation | Commit matched pair, show temporary error, or submit the full set |
| Recall branch | Show normal reveal actions, or show the timeout-driven next-only branch |
| Auto-advance | Trigger `GO_NEXT` automatically or wait for explicit next action |
| Speech playback gating | Auto-play speech, allow manual playback, do nothing, or store an error |

## Invalid transitions

- Executing a session action while no canonical session exists throws a fail-fast error instead of silently doing nothing.
- Selecting a guess choice while feedback is locked is ignored.
- Selecting already-matched items in match mode is ignored.
- Submitting match mode before all pairs are complete is not allowed.
- Queueing a manual recall reveal after countdown state is already inactive with no remaining time is ignored.
- Moving backward in review mode before the first completed position is rejected.
- Playing speech when speech is unavailable or there is no speech text becomes a no-op.

## Fallback behavior

- Loading can continue to display the last resolved session rather than a blank shell.
- Recall timeout can expose a fallback next action if the backend omits `GO_NEXT`.
- Result restart falls back to a generic deck-list destination when deck context is missing.
- Review gesture detection ignores swipes outside the intended card viewport.

## Recovery behavior

- Provider invalidation retries session loading after an error.
- Fill mode lets the learner retry after reveal or mismatch.
- Guess mode clears temporary error state after a delay.
- Match mode clears wrong-pair feedback after a delay.
- Recall restarts countdown if reveal processing fails after timeout.
- Local sub-mode state is resynchronized whenever item identity changes.

## Evidence

- Session route and routing behavior
- Session orchestration provider and mutation flow
- Mode-specific providers for fill, guess, match, recall, and speech
- Session shell, menu, and active-mode widgets
- Domain models and repository contract
- Tests and fixtures covering provider behavior, screen behavior, and session fixtures
