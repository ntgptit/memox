# Typography Usage Rules

MemoX uses a constrained app type scale only: `48 / 32 / 24 / 20 / 16 / 14 / 12`.

- `48` (`statDisplay`) is reserved for one dominant numeric stat on a surface. Never use it for body copy or repeated labels.
- `32` (`displayLarge`, `displayMedium`) is for a single hero title or hero term per screen or card. Do not stack multiple 32px texts in the same viewport.
- `24` (`headlineLarge`, `titleLarge`) is for AppBar titles, dialog or bottom-sheet titles, and strong stat values that need navigation-level emphasis.
- `20` — bridge headline. (`headlineMedium`) is the bridge headline size for in-body headers and emphasized section titles that must sit between a 24px navigation title and 16px body text.
- `16` (`titleMedium`, `titleSmall`, `bodyLarge`, `bodyMedium`) is the base reading and interaction size. Use it for long-form readable text, list item titles, form input text, and primary or secondary button labels.
- `14` (`bodySmall`, `labelLarge`) is for subtitles, supporting copy directly under a 16px title, filter or tag text, and breadcrumb-level metadata that must remain readable.
- `12` (`labelMedium`, `labelSmall`, `caption`) is for metadata, helper labels, section overlines, all-caps micro labels, timestamps, and compact badges only.

If a text role does not clearly fit one of the buckets above, adjust the shared theme mapping in `lib/core/theme/**` instead of inventing a one-off size in feature UI.
