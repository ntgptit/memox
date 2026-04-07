from __future__ import annotations

from pathlib import Path

from tools.guard.core.formatters import (
    JsonFormatter,
    MarkdownFormatter,
    ReportEnvelope,
    TerminalFormatter,
)
from tools.guard.core.formatters.terminal_formatter import Console
from tools.guard.core.guard_result import GuardResult


class Reporter:
    """Compatibility facade over the formatter abstraction."""

    def __init__(self, project_name: str | None = None) -> None:
        self.project_name = project_name
        self.console = Console() if Console else None

    @property
    def report_title(self) -> str:
        return self._build_envelope([]).report_title

    @property
    def summary_title(self) -> str:
        return self._build_envelope([]).summary_title

    def render_terminal(self, results: list[GuardResult]) -> None:
        TerminalFormatter(
            self._build_envelope(results),
            console=self.console,
        ).render()

    def write_json(self, results: list[GuardResult], target: Path) -> None:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(
            JsonFormatter(self._build_envelope(results)).render(),
            encoding='utf-8',
        )

    def write_markdown(self, results: list[GuardResult], target: Path) -> None:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(
            MarkdownFormatter(self._build_envelope(results)).render(),
            encoding='utf-8',
        )

    @staticmethod
    def has_errors(results: list[GuardResult]) -> bool:
        return Reporter._build_summary(results).errors > 0

    @staticmethod
    def has_warnings(results: list[GuardResult]) -> bool:
        return Reporter._build_summary(results).warnings > 0

    def _build_envelope(self, results: list[GuardResult]) -> ReportEnvelope:
        return ReportEnvelope.from_results(results, project_name=self.project_name)

    @staticmethod
    def _build_summary(results: list[GuardResult]):
        return ReportEnvelope.from_results(results).summary
