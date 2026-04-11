# Business Scan Index

## Scope scanned

- Primary scope: the study feature runtime, including screens, widgets, providers, mode strategies, and supporting feature-local documentation.
- Supporting scope outside the feature: routing, upstream launch surfaces, shared study contracts, repository integrations, profile preference support, and tests or fixtures that reveal intended behavior.
- Scope correction from recursive scan: shared study contracts are owned in the app-level domain and data layers, not only inside the feature folder.

## Code areas analyzed

| Area | Purpose in business extraction |
| --- | --- |
| Session screen and shell | Main session orchestration, action dispatch, loading handling, and business outcomes |
| Mode-specific widgets | Review, guess, match, recall, and fill interactions |
| Session and launcher providers | Canonical session lifecycle, mutation flow, launch behavior, and reset commands |
| Mode providers | Local validation, timers, staged feedback, and transient interaction rules |
| Mode strategy layer | Action ordering, reveal semantics, and layout or state decisions |
| Placeholder support screens | Checked to avoid overstating incomplete flows |
| Routing and upstream launch surfaces | Identified the real business entry paths |
| Domain, repository, and preference contracts | Confirmed shared study terminology and external dependencies |
| Tests and fixtures | Confirmed intended behavior, edge cases, and timing semantics |
| Existing study documentation | Used only as supporting context and cross-check material, not as unquestioned truth |

## Entry points identified

| Entry point | Status | Business meaning |
| --- | --- | --- |
| Session route data object | Confirmed | Opens the live study-session runtime for a deck and can also resume by `sessionId` |
| Specialized launch action from an upstream deck/detail context | Confirmed | Can request `FIRST_LEARNING` or `REVIEW` before opening the live session route |
| Recommendation call to action from an upstream reminder or analytics context | Confirmed | Opens the live session route using deck identity only |
| `/study` root route | Confirmed non-entry | Redirects away and does not expose a setup-first workflow |
| Setup screen | Placeholder only | Exists as a shell surface and is not part of the live route tree |
| History, mode-picker, and result screens | Partial only | Ancillary surfaces with placeholder or limited fallback behavior, but not proven as part of the live completion path |

## Major flows identified

- Start a new study session for a deck.
- Resume an existing session by session identifier.
- Use the live session screen as the actual production business path, rather than a setup-first landing flow.
- Execute a review interaction by swiping or choosing an action.
- Execute a guess interaction with delayed feedback and conditional auto-submit.
- Execute a match interaction with pair validation and staged completion.
- Execute a recall interaction with countdown-driven reveal and recovery behavior.
- Execute a fill interaction with validation, reveal, retry, and conditional auto-advance.
- Reset the current mode when the backend allows it and the user confirms.
- Reset deck progress before restarting learning from the beginning.
- Start a session from reminder or analytics recommendations.
- Recover from loading or session mutation failures.
- Play or auto-play speech guidance when speech is available and permitted.

## Artifacts generated

- `business-scan-index.md`
- `business-requirements-baseline.md`
- `business-rules-catalog.md`
- `business-flow-catalog.md`
- `business-state-and-decision-model.md`
- `business-open-questions-and-inference-log.md`
- `business-recursive-scan-summary.md`

## Iteration summary

| Iteration | Focus | Material added |
| --- | --- | --- |
| 1 | Core route, provider, repository, and session screen scan | Baseline session purpose, actors, entry points, main flows, and canonical commands |
| 2 | Mode widgets, local providers, and tests | Hidden validation rules, timed feedback behavior, no-op paths, fallback behavior, and edge cases |
| 3 | Supporting launch surfaces, older study docs, and contradiction check | Recommendation-launch drift, placeholder flow limits, and code-vs-doc mismatches |
| 4 | Documentation gap review and targeted rescan | Clarified ambiguities, separated confirmed vs inferred behavior, and tightened state or decision coverage |
| 5 | Strategy, app-bar, and fixture verification pass | Corrected completion-state assumptions, captured fill field-role inversion, and narrowed speech autoplay vs manual-play gating |
| 6 | Contract-location and live-route correction pass | Confirmed `/study` is not a live setup entry, identified a legacy duplicate route screen, and corrected where the owned shared contracts live |
