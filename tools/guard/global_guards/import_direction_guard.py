from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class ImportDirectionGuard(BaseGuard):
    GUARD_ID = 'import_direction'
    GUARD_NAME = 'Import direction'
    DESCRIPTION = 'Project layers must respect configured import direction rules.'
    DEFAULT_SEVERITY = Severity.ERROR

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)
        rules = self.project_rules.get(self.GUARD_ID, {})
        excluded_paths = tuple(rules.get('excluded_paths', []))

        if any(item in relative for item in excluded_paths):
            return []

        current_layer = self.paths.get_layer(file_path)

        if not current_layer:
            return []

        layers = tuple(rules.get('layers', []))
        forbidden_imports = {
            layer: set(imports)
            for layer, imports in rules.get('forbidden_imports', {}).items()
        }

        if not layers or current_layer not in forbidden_imports:
            return []

        import_pattern = self._compile_import_pattern(
            layers=layers,
            regex_template=rules.get(
                'import_path_regex_template',
                r"import\s+'package:[^']+/(?:[^']+/)+({layers})/",
            ),
        )
        message_template = rules.get(
            'message_template',
            '{current_layer}/ cannot import {imported_layer}/. Dependency Inversion violation.',
        )
        message_code = rules.get('message_code')
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            match = import_pattern.search(line)

            if not match:
                continue

            imported_layer = match.group(1)
            if imported_layer not in forbidden_imports[current_layer]:
                continue

            violations.append(
                self.create_violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message=message_template,
                    message_code=message_code,
                    message_args={
                        'current_layer': current_layer,
                        'imported_layer': imported_layer,
                        'file': relative,
                        'file_path': relative,
                        'file_name': file_path.name,
                        'line_number': index,
                    },
                    violation_code=message_code or self.GUARD_ID,
                    symbol=imported_layer,
                    ),
                )

        return violations

    @staticmethod
    def _compile_import_pattern(
        layers: tuple[str, ...],
        regex_template: str,
    ) -> re.Pattern:
        joined = '|'.join(re.escape(layer) for layer in layers)
        return re.compile(regex_template.format(layers=joined))
