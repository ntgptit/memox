# Output Formatter Architecture

Date: 2026-04-07

This document describes the phase-2 output formatter abstraction for
`tools/guard`.

The goal of this step is limited:

- keep current terminal, JSON, and Markdown outputs working
- move output generation behind a formatter layer
- make all formatters consume the same normalized report envelope
- keep the CLI integration compatibility-safe through `Reporter`

## Design overview

Guard execution still produces `GuardResult` objects containing normalized
`Violation` objects.

Output generation now happens in two stages:

1. build a shared `ReportEnvelope`
2. render that envelope through a formatter

```text
GuardRegistry / RuleExecutor / legacy guards
  -> list[GuardResult]
  -> ReportEnvelope.from_results(...)
  -> TerminalFormatter | JsonFormatter | MarkdownFormatter
  -> Reporter compatibility facade
  -> CLI / files / stdout
```

## Core types

### `ReportEnvelope`

Defined in `tools/guard/core/formatters/report_envelope.py`.

Responsibilities:

- hold the normalized `GuardResult` list
- compute one shared `ReportSummary`
- expose stable report titles
- provide a canonical dictionary payload for structured formats

### `ReportSummary`

Also defined in
`tools/guard/core/formatters/report_envelope.py`.

Responsibilities:

- count:
  - guards
  - errors
  - warnings
  - infos
- provide a shared `to_dict()` shape used by structured output

## Formatter layer

All formatters inherit from the minimal
`OutputFormatter`
base class.

Current formatters:

- `tools/guard/core/formatters/terminal_formatter.py`
- `tools/guard/core/formatters/json_formatter.py`
- `tools/guard/core/formatters/markdown_formatter.py`

### Terminal formatter

Consumes the shared envelope and renders:

- rich table output when `rich` is available and a console is configured
- plain text output otherwise

The plain-text contract remains the compatibility fallback used by tests and
minimal environments.

### JSON formatter

Consumes the shared envelope and renders a JSON string built from:

```json
{
  "summary": { "...": "..." },
  "results": [ ... ]
}
```

The `results` array still comes from `GuardResult.to_dict()`, so structured
finding payloads continue to reflect the canonical violation schema.

### Markdown formatter

Consumes the shared envelope and renders the same summary and per-guard finding
sections as before, using the normalized `GuardResult` / `Violation` data.

## Reporter compatibility facade

`tools/guard/core/reporter.py` remains the
public integration point used by `run.py`.

It now acts only as a facade:

- builds the `ReportEnvelope`
- dispatches to the requested formatter
- preserves existing methods:
  - `render_terminal(...)`
  - `write_json(...)`
  - `write_markdown(...)`
  - `has_errors(...)`
  - `has_warnings(...)`

This keeps CLI behavior stable while removing formatter logic from the facade
itself.

## Why this is safer than a reporter rewrite

This design avoids changing execution flow or CLI contracts:

- no change to how guards run
- no change to CLI flags
- no change to `GuardResult` production
- no new output format dependencies

Only the rendering boundary changed.

## Extension points

Future formatters can be added by following the same pattern:

- accept a `ReportEnvelope`
- render only from normalized result data
- avoid reaching back into guard execution internals

Examples intentionally deferred:

- SARIF formatter
- GitHub annotations formatter
- JUnit XML formatter

Those can be added without changing `GuardRegistry`, `RuleExecutor`, or the
normalized violation schema.

## Testing

Current coverage comes from:

- golden output tests in
  `tools/guard/tests/core/test_reporter.py`
- envelope/formatter consistency tests in that same file

The intent is:

- reporter tests protect the public compatibility contract
- formatter tests protect the internal abstraction contract

## Intentionally deferred

This step does not introduce:

- a new report schema version
- richer renderer-specific layouts
- exit-policy-driven output filtering
- suppression or baseline-aware rendering
- non-terminal structured formats beyond JSON and Markdown
