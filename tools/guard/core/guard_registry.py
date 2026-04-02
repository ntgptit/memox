from __future__ import annotations

from pathlib import Path
import time

from tools.guard.core.file_scanner import FileScanner
from tools.guard.core.guard_result import GuardScope, Severity, Violation
from tools.guard.global_guards.family import GlobalGuardFamily
from tools.guard.local_guards.family import LocalGuardFamily


class GuardRegistry:
    def __init__(
        self,
        config: dict,
        path_constants: 'PathConstants',
        project_rules: dict,
    ) -> None:
        self.config = config
        self.paths = path_constants
        self.project_rules = project_rules
        self.scanner = FileScanner(path_constants)

    def create_guards(
        self,
        family: str = 'all',
        guard_ids: set[str] | None = None,
    ) -> list['BaseGuard']:
        families = []

        if family in {'all', 'global'}:
            families.append(
                GlobalGuardFamily(
                    config=self.config,
                    path_constants=self.paths,
                ),
            )

        if family in {'all', 'local'}:
            families.append(
                LocalGuardFamily(
                    config=self.config,
                    path_constants=self.paths,
                    project_rules=self.project_rules,
                ),
            )

        guards = [guard for family_instance in families for guard in family_instance.create_guards()]

        if not guard_ids:
            return guards

        return [guard for guard in guards if guard.GUARD_ID in guard_ids]

    def run(
        self,
        family: str = 'all',
        guard_ids: set[str] | None = None,
        scope: str = 'all',
    ) -> list['GuardResult']:
        files = self.scanner.scan(scope=scope)
        results = []

        for guard in self.create_guards(family=family, guard_ids=guard_ids):
            started_at = time.perf_counter()
            violations = []
            files_scanned = len(files)

            try:
                if guard.is_file_level:
                    for file_path in files:
                        violations.extend(guard.check_file(file_path, self._read_lines(file_path)))

                if not guard.is_file_level:
                    violations.extend(guard.check_project(files))
            except Exception as exc:  # pragma: no cover - safety net
                violations.append(
                    Violation(
                        file_path='<internal>',
                        line_number=0,
                        line_content='',
                        message=f'{guard.GUARD_ID} crashed: {exc}',
                        guard_id=guard.GUARD_ID,
                        severity=Severity.ERROR,
                        scope=guard.SCOPE,
                    ),
                )

            duration_ms = (time.perf_counter() - started_at) * 1000
            results.append(guard.create_result(violations, files_scanned, duration_ms))

        return results

    @staticmethod
    def _read_lines(file_path: Path) -> list[str]:
        return file_path.read_text(encoding='utf-8').splitlines()
