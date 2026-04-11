# Business Recursive Scan Summary

## Iteration count

- Total iterations performed: 6

## What was added in each iteration

### Iteration 1

- Identified the implemented feature boundary as active study-session orchestration rather than the full set of older study notes.
- Extracted core entry points, canonical repository commands, and session lifecycle behavior.
- Established the initial actor, trigger, and flow map.

### Iteration 2

- Rescanned mode-specific providers, widgets, and tests.
- Added hidden validation rules, local timing behavior, auto-submit and auto-advance conditions, no-op behavior, and edge-case handling.
- Expanded state and decision coverage for fill, guess, match, recall, and speech.

### Iteration 3

- Rescanned launch surfaces outside the feature and compared them with older documentation.
- Added recommendation-launch drift, placeholder screen limitations, and code-vs-doc contradictions.
- Tightened the distinction between confirmed behavior and inferred behavior.

### Iteration 4

- Reviewed the draft documentation for weak areas.
- Rescanned specifically for permissions, completion handling, fallback behavior, and unsupported-mode behavior.
- Clarified open questions, residual ambiguity, and limits of current evidence.

### Iteration 5

- Rescanned mode strategies, speech entry surfaces, and shared fixtures to validate field semantics and completion evidence.
- Added the fill-mode prompt or answer inversion rule and separated autoplay gating from manual playback exposure.
- Added the guess-mode payload mapping rule showing that visible choice labels, not choice identifiers, are submitted in the current frontend scope.
- Corrected documentation that had treated `sessionCompleted` as an observed runtime state instead of a modeled but unproven payload branch.

### Iteration 6

- Rescanned live route ownership, legacy duplicate screens, profile-preference support contracts, and older study markdown.
- Confirmed `/study` is not a setup-first business entry, corrected where shared contracts actually live, and documented stale-doc drift where older notes describe broader policy branches than the owned runtime contract proves.
- Added open questions around profile preference enforcement, missing speech locale transport, and incomplete completion semantics.

## Gaps found in each iteration

| Iteration | Gaps found |
| --- | --- |
| 1 | Hidden mode-specific rules and timing behavior were under-documented. |
| 2 | Launch-surface differences and placeholder-screen limitations were still weak. |
| 3 | Ambiguities around permissions, completion, fallback next action, and unsupported modes needed explicit separation. |
| 4 | No additional major in-scope business flow was found; remaining gaps were evidence limitations rather than missing scans. |
| 5 | Existing docs still overstated completion evidence and speech permission enforcement. |
| 6 | Route ownership, supporting-contract location, and legacy-doc scope drift still needed explicit correction. |

## Code areas rescanned

- Session route ownership and route entry behavior
- Session screen orchestration and shell behavior
- Fill, guess, match, recall, and speech providers
- Mode strategy and layout decision logic
- Reset actions and session menu behavior
- Placeholder support screens
- Shared study domain and repository contracts
- Profile preference support contracts
- Upstream direct-start and recommendation launch surfaces
- Study tests, fixtures, and older feature documentation

## Newly discovered business behavior

- Fill reveal is not only informational; it marks the attempt incorrect and still supports a retry branch.
- Guess and match behaviors rely on short local feedback timers before canonical progression.
- Recall timeout changes visible next-action behavior, not just reveal timing.
- Recommendation-driven launch can drift from the recommendation's stated intent.
- Fill mode intentionally reverses `prompt` and `answer` roles between the generic payload model and the learner-facing clue.
- Guess mode uses the displayed choice label as its submission payload, which is a contract detail not obvious from the generic choice model alone.
- Autoplay uses speech action metadata, while manual playback exposure is currently broader and mostly availability-driven.
- `sessionCompleted` influences action labeling in code but is not proven as an observed runtime state within scanned scope.
- Some supporting screens are present only as placeholders and should not be treated as confirmed business flows.
- `/study` is not a live setup entry; the production business path is `/study/session`.
- A legacy duplicate route screen exists but is not the live route target.
- Earlier scan assumptions about where shared contracts lived were corrected during rescanning.
- Older study documentation describes broader session types and lifecycle branches than the owned runtime contracts currently evidence.
- `SpeechPreference.locale` is modeled in memory but omitted from the current update payload contract.

## Contradictions resolved

- Older study docs imply a broader fully realized workflow, but current code confirms that the active session runtime is the only mature flow.
- Recommendation language suggests review, but the launch path does not explicitly preserve that intent.
- One layer fails fast on unsupported modes while another provides an empty fallback; this was documented as ambiguity rather than forced into a single false rule.
- Earlier documentation treated `sessionCompleted` as a confirmed final runtime transition; the rescanned fixtures only confirm a terminal `COMPLETED` mode state, not a true completion flag.
- Earlier documentation overstated speech permission enforcement; current code enforces stricter rules for autoplay than for manual playback.
- Earlier scope assumptions about shared contract ownership were too narrow and were corrected during rescanning.
- Older repo-authored study notes described broader policy vocabulary than the current transport and fixture contracts can prove, so the refreshed baseline now treats those branches as ambiguous rather than confirmed.

## Remaining limits

- Backend scoring, scheduling, and success policy are inferred from integration shape rather than directly visible in this feature.
- Session-completion outcome is incomplete because the feature exposes a completion flag and completion-oriented labels without an in-scope true-valued completion payload or result-navigation flow.
- Placeholder screens prevent deeper extraction for setup, history, result, and mode picking.
- No study-specific permission differences were found in scope.
- Preference enforcement is incomplete in owned scope because model bounds exist, but no local validator was found for `firstLearningCardLimit`, and speech locale is not sent in updates.

## Final confidence assessment

- Overall confidence for active-session runtime, mode rules, and local interaction behavior: medium-high
- Confidence for fill field semantics and speech gating details: medium-high
- Confidence for launch-surface intent, route ownership, and recommendation behavior: medium
- Confidence for completion flow, placeholder screens, and backend scoring semantics: low to medium because evidence is incomplete

Hard-stop assessment:

- No major implemented session flow remains undocumented.
- No confirmed major business rule remains uncataloged within the scanned scope.
- No major state or decision path in the active runtime remains obviously undocumented.
- Remaining gaps are explicit evidence limitations or placeholder implementations rather than missed extractions.
