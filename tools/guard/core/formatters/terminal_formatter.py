from __future__ import annotations

from tools.guard.core.formatters.base import OutputFormatter

try:  # pragma: no cover - optional dependency
    from rich.console import Console
    from rich.table import Table
except ImportError:  # pragma: no cover - optional dependency
    Console = None
    Table = None


class TerminalFormatter(OutputFormatter):
    def __init__(self, envelope, *, console: Console | None = None) -> None:
        super().__init__(envelope)
        self.console = console

    def render(self) -> None:
        if self.console and Table:
            self._render_rich()
            return

        print(self.render_plain(), end='')

    def render_plain(self) -> str:
        summary = self.envelope.summary
        lines = [
            self.envelope.summary_title,
            (
                f'guards={summary.guards} errors={summary.errors} '
                f'warnings={summary.warnings} infos={summary.infos}'
            ),
        ]

        for result in self.envelope.results:
            lines.append(
                f'- {result.guard_id} scope={result.scope.value} '
                f'errors={result.error_count} warnings={result.warning_count} '
                f'infos={result.info_count}',
            )

            for violation in result.violations:
                lines.append(
                    f'  - {violation.location} '
                    f'[{violation.severity.value}] {violation.message}',
                )

        return '\n'.join(lines) + '\n'

    def _render_rich(self) -> None:
        summary = self.envelope.summary
        table = Table(title=self.envelope.summary_title)
        table.add_column('Guard')
        table.add_column('Scope')
        table.add_column('Errors', justify='right')
        table.add_column('Warnings', justify='right')
        table.add_column('Infos', justify='right')
        table.add_column('Files', justify='right')

        for result in self.envelope.results:
            table.add_row(
                result.guard_id,
                result.scope.value,
                str(result.error_count),
                str(result.warning_count),
                str(result.info_count),
                str(result.files_scanned),
            )

        self.console.print(table)
        self.console.print(
            f'errors={summary.errors} warnings={summary.warnings} infos={summary.infos}',
        )

        for result in self.envelope.results:
            if not result.violations:
                continue

            self.console.print(f'\n[{result.guard_id}] {result.description}')

            for violation in result.violations:
                self.console.print(
                    f'- {violation.location} '
                    f'[{violation.severity.value}] {violation.message}',
                )
