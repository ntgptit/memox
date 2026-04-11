# 1. Logic mismatches fixed

- Direct mode entry now resolves an explicit business outcome before rendering a mode screen. `studyEntryProvider` returns `containerNotFound` for a missing deck, `nothingToStudy` for an ineligible start, and `ready` when a matching saved snapshot exists (`lib/features/study/presentation/providers/study_entry_provider.dart:10-101`). `StudyScreen` now renders those refusal states instead of falling through into a mode-local empty screen (`lib/features/study/presentation/screens/study_screen.dart:107-135`).
- The hub no longer overclaims that the full `modePlan` will execute. The primary CTA now says "start with" the recommended primary mode, while the rest of the plan is shown only as a recommended preview (`lib/features/study/presentation/widgets/study_recommendation_card.dart:34-44`, `lib/features/study/presentation/widgets/study_recommendation_card.dart:123-141`).
- Recall now keeps missed cards unresolved inside the same session instead of treating the first miss as terminal. `retryPendingCardIds` is part of `RecallState`, misses enter that set on the first failure, retry success replaces the missed result, and only a second miss in the retry round finalizes the card as missed (`lib/features/study/presentation/providers/recall_provider.dart:33-35`, `lib/features/study/presentation/providers/recall_provider.dart:121-182`, `lib/features/study/presentation/providers/recall_provider.dart:307-335`).
- Match now handles decks larger than one board without prematurely ending the mode. The provider tracks `boardIndex` and `completedPairCount`, advances to the next grouped board when the current board is cleared, and persists grouped-board progress across resume (`lib/features/study/presentation/providers/match_provider.dart:43-63`, `lib/features/study/presentation/providers/match_provider.dart:229-260`, `lib/features/study/presentation/providers/match_provider.dart:424-488`).
- Fill completion no longer exposes a separate post-completion "practice mistakes" action. The completion state now ends with the summary, mistakes panel, next-deck action, and the normal done action only (`lib/features/study/presentation/screens/fill_mode_screen.dart:149-200`).

# 2. Scenario gaps fixed

- Documented start-refusal scenarios are now covered in the direct entry flow: review with no due cards, non-review with no available cards, and missing deck/container (`lib/features/study/presentation/providers/study_entry_provider.dart:56-89`, `lib/features/study/presentation/screens/study_screen.dart:120-132`).
- Resume now has a deterministic rule for in-progress study: if the saved snapshot matches the requested `deckId + mode`, resume is allowed even when a fresh eligibility check would now fail (`lib/features/study/presentation/providers/study_entry_provider.dart:64-69`).
- Recall now covers the documented retry-pending scenario instead of exiting the mode after the first miss (`lib/features/study/presentation/providers/recall_provider.dart:317-335`).
- Match now covers the documented oversized-board grouping scenario by continuing into subsequent grouped boards and by restoring grouped progress from snapshot state (`lib/features/study/presentation/providers/match_provider.dart:243-260`, `lib/features/study/presentation/providers/match_provider.dart:487-488`, `lib/features/study/presentation/providers/match_provider.dart:522-526`).
- Fill completion now closes the documented remediation loop without an extra undocumented practice-only branch after completion (`lib/features/study/presentation/screens/fill_mode_screen.dart:187-200`).

# 3. Edge cases addressed

- Matching snapshot beats fresh eligibility refusal for the same `deckId + mode`, which preserves in-progress work instead of discarding it when due-card state changes mid-session (`lib/features/study/presentation/providers/study_entry_provider.dart:64-69`).
- A recall card that is missed again during its retry round now finalizes deterministically as missed and allows the session to complete instead of remaining stuck in an unresolved state (`lib/features/study/presentation/providers/recall_provider.dart:318-325`).
- Grouped match progress survives restore because `boardIndex` and `completedPairCount` are serialized into the active-session payload (`lib/features/study/presentation/providers/match_provider.dart:423-425`, `lib/features/study/presentation/providers/match_provider.dart:487-488`).
- Fill retry remediation now completes cleanly without leaving a dangling practice CTA on the completion screen (`lib/features/study/presentation/screens/fill_mode_screen.dart:187-200`).

# 4. Tests added or updated

- `test/features/study/presentation/providers/study_entry_provider_test.dart:45-94` now covers review no-due refusal, missing deck refusal, and matching-snapshot bypass.
- `test/features/study/presentation/screens/study_screen_test.dart:180-264` now covers the direct review refusal UI and the resume-over-refusal path for a matching saved snapshot.
- `test/features/study/presentation/providers/recall_provider_test.dart:139-249` now covers retry-pending retention, retry success replacing the missed result, second-miss finalization, and retry-state restore.
- `test/features/study/presentation/providers/match_provider_test.dart:171-207` now covers grouped boards and grouped-progress restore.
- `test/features/study/presentation/screens/fill_mode_screen_test.dart:161-192` now covers completion without a practice-only action.
- Reverification completed with `flutter test test/features/study`, `python tools/guard/run.py --scope features`, and `flutter analyze`. The study tests and guard passed. `flutter analyze` only reported one pre-existing `info` outside the study scope at `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart:62`.

# 5. Remaining ambiguous rules

- The docs require resume support but do not state whether resume should take precedence over a fresh eligibility failure. The implemented safe assumption is to resume a matching snapshot first so the user does not lose an in-progress session (`lib/features/study/presentation/providers/study_entry_provider.dart:64-69`).
- The docs require retry/remediation for failed recall items, but they do not specify the retry ceiling. The implemented safe assumption is one in-session retry; a second miss in that retry round finalizes the card as missed (`lib/features/study/presentation/providers/recall_provider.dart:318-325`).
- The docs mention grouped boards and board pass/fail semantics for match mode, but they do not define a board-level failure threshold. The current implementation uses grouped progression plus eventual completion once all pairs are matched (`lib/features/study/presentation/providers/match_provider.dart:229-260`).
- The docs still suggest a session-completion boundary for long-term learning-state updates, but the code still writes SRS state per attempt in each mode provider. That product rule remains unresolved in the docs-versus-code contract.

# 6. Deferred items

- The docs-defined generic session aggregate and normalized snapshot are still not implemented. `StudySession` and the active-session store are still mode-first rather than `sessionType`/`modePlan`/`allowedActions` driven.
- Start/complete session use cases still delegate repository persistence rather than owning the full docs-defined session orchestration contract.
- Multi-mode `modePlan` execution is still not implemented. The hub wording was corrected, but runtime execution remains single-mode.
- Unauthorized access, invalid-action, invalid-payload, timeout, interruption, and analytics contracts remain deferred because they require a broader session-engine decision than was safe for this focused remediation pass.
- No doc changes were made in this pass. Any future change to resume precedence, retry ceilings, or completion-time SRS policy should be reflected in `lib/features/study/docs/**` once product decisions are explicit.
