# MemoX Typography Usage Rules

MemoX uses a constrained app type scale only:

- `48` — XXL
- `32` — XL
- `24` — LG
- `20` — MD+
- `16` — MD
- `14` — SM
- `12` — XS

## Usage by hierarchy

### `48` — dominant stat only

Use only for one core numeric stat on a surface.

Examples:

- mastery percentage hero
- exam countdown
- final study score

### `32` — hero title

Use only for the first thing the user should notice on a screen or card.

Examples:

- home greeting hero
- main flashcard term
- deck hero title in a large header

### `24` — headline and navigation title

Use for large section titles, AppBar titles, dialog titles, and medium-emphasis stat values.

Examples:

- AppBar title
- dialog or bottom-sheet title
- deck stats grid number

### `20` — bridge headline

Use for in-body headers or emphasized section titles that need more hierarchy
than 16px text but should not compete with a 24px navigation or dialog title.

Examples:

- deck detail header title inside the scrollable body
- section title inside a dense settings or statistics surface
- emphasized card header that still sits under a larger page title

### `16` — base reading and interaction size

Use for any primary text the user must read or interact with.

Examples:

- list tile title
- text field input
- flashcard back content
- primary and secondary button labels

### `14` — supporting subtitle and chip text

Use for supporting text directly under 16px content, as well as compact interactive labels.

Examples:

- subtitle under list tile titles
- breadcrumb text
- chip and tag text
- secondary supporting copy

### `12` — metadata and overline

Use only for metadata, helper text, badges, timestamps, and all-caps overlines with extra tracking.

Examples:

- section overline labels
- helper timestamps
- compact badge counts
- subtle status metadata

## Implementation rules

- Never hardcode font sizes in feature UI.
- Use `context.textTheme.*` or `context.appTextStyles.*`.
- If a role needs a different size, update the shared theme mapping in `lib/core/theme/**`.
- Do not introduce new size steps outside `48 / 32 / 24 / 20 / 16 / 14 / 12`.
