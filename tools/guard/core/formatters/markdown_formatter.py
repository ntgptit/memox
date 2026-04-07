from __future__ import annotations

from tools.guard.core.formatters.base import OutputFormatter


class MarkdownFormatter(OutputFormatter):
    def render(self) -> str:
        summary = self.envelope.summary
        lines = [
            f'# {self.envelope.report_title}',
            '',
            f'- Guards: {summary.guards}',
            f'- Errors: {summary.errors}',
            f'- Warnings: {summary.warnings}',
            f'- Infos: {summary.infos}',
            '',
        ]

        for result in self.envelope.results:
            status = 'PASS' if result.passed else 'FAIL'
            lines.append(f'## {result.guard_id} [{status}]')
            lines.append('')
            lines.append(f'- Scope: `{result.scope.value}`')
            lines.append(f'- Files scanned: `{result.files_scanned}`')
            lines.append(f'- Duration: `{result.duration_ms:.2f}ms`')

            if not result.violations:
                lines.append('- No violations')
                lines.append('')
                continue

            lines.append('')

            for violation in result.violations:
                lines.append(
                    f'- `{violation.location}` [{violation.severity.value}] {violation.message}',
                )

            lines.append('')

        return '\n'.join(lines)
