from __future__ import annotations

from dataclasses import asdict, dataclass, field
from enum import Enum


class Severity(str, Enum):
    ERROR = 'error'
    WARNING = 'warning'
    INFO = 'info'


class GuardScope(str, Enum):
    GLOBAL = 'global'
    LOCAL = 'local'


@dataclass(slots=True)
class Violation:
    file_path: str
    line_number: int
    line_content: str
    message: str
    guard_id: str
    severity: Severity
    scope: GuardScope = GuardScope.GLOBAL

    @property
    def location(self) -> str:
        return f'{self.file_path}:{self.line_number}'

    def to_dict(self) -> dict[str, object]:
        data = asdict(self)
        data['severity'] = self.severity.value
        data['scope'] = self.scope.value
        data['location'] = self.location
        return data


@dataclass(slots=True)
class GuardResult:
    guard_id: str
    guard_name: str
    description: str
    scope: GuardScope
    violations: list[Violation] = field(default_factory=list)
    files_scanned: int = 0
    duration_ms: float = 0.0

    @property
    def passed(self) -> bool:
        return self.error_count == 0

    @property
    def error_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.ERROR)

    @property
    def warning_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.WARNING)

    @property
    def info_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.INFO)

    def to_dict(self) -> dict[str, object]:
        return {
            'guard_id': self.guard_id,
            'guard_name': self.guard_name,
            'description': self.description,
            'scope': self.scope.value,
            'passed': self.passed,
            'files_scanned': self.files_scanned,
            'duration_ms': self.duration_ms,
            'error_count': self.error_count,
            'warning_count': self.warning_count,
            'info_count': self.info_count,
            'violations': [violation.to_dict() for violation in self.violations],
        }
