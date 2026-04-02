from __future__ import annotations

import json
from pathlib import Path

from tools.guard.core.guard_result import GuardResult, Severity

try:  # pragma: no cover - optional dependency
    from rich.console import Console
    from rich.table import Table
except ImportError:  # pragma: no cover - optional dependency
    Console = None
    Table = None


class Reporter:
    def __init__(self) -> None:
        self.console = Console() if Console else None

    def render_terminal(self, results: list[GuardResult]) -> None:
        if self.console and Table:
            self._render_rich(results)
            return

        self._render_plain(results)

    def write_json(self, results: list[GuardResult], target: Path) -> None:
        payload = {
            'summary': self._summary(results),
            'results': [result.to_dict() for result in results],
        }
        target.write_text(json.dumps(payload, indent=2), encoding='utf-8')

    def write_markdown(self, results: list[GuardResult], target: Path) -> None:
        summary = self._summary(results)
        lines = [
            '# MemoX Guard Report',
            '',
            f"- Guards: {summary['guards']}",
            f"- Errors: {summary['errors']}",
            f"- Warnings: {summary['warnings']}",
            f"- Infos: {summary['infos']}",
            '',
        ]

        for result in results:
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
                    f"- `{violation.location}` [{violation.severity.value}] {violation.message}",
                )

            lines.append('')

        target.write_text('\n'.join(lines), encoding='utf-8')

    @staticmethod
    def has_errors(results: list[GuardResult]) -> bool:
        return any(result.error_count for result in results)

    @staticmethod
    def has_warnings(results: list[GuardResult]) -> bool:
        return any(result.warning_count for result in results)

    def _render_rich(self, results: list[GuardResult]) -> None:
        summary = self._summary(results)
        table = Table(title='MemoX Guard Summary')
        table.add_column('Guard')
        table.add_column('Scope')
        table.add_column('Errors', justify='right')
        table.add_column('Warnings', justify='right')
        table.add_column('Infos', justify='right')
        table.add_column('Files', justify='right')

        for result in results:
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
            f"errors={summary['errors']} warnings={summary['warnings']} infos={summary['infos']}",
        )

        for result in results:
            if not result.violations:
                continue

            self.console.print(f'\n[{result.guard_id}] {result.description}')

            for violation in result.violations:
                self.console.print(
                    f'- {violation.location} [{violation.severity.value}] {violation.message}',
                )

    @staticmethod
    def _render_plain(results: list[GuardResult]) -> None:
        summary = Reporter._summary(results)
        print('MemoX Guard Summary')
        print(
            f"guards={summary['guards']} errors={summary['errors']} warnings={summary['warnings']} infos={summary['infos']}",
        )

        for result in results:
            print(
                f'- {result.guard_id} scope={result.scope.value} errors={result.error_count} '
                f'warnings={result.warning_count} infos={result.info_count}',
            )

            for violation in result.violations:
                print(
                    f'  - {violation.location} [{violation.severity.value}] {violation.message}',
                )

    @staticmethod
    def _summary(results: list[GuardResult]) -> dict[str, int]:
        return {
            'guards': len(results),
            'errors': sum(result.error_count for result in results),
            'warnings': sum(result.warning_count for result in results),
            'infos': sum(result.info_count for result in results),
        }
